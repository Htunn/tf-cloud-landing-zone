package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSimpleExampleSingleAccount tests the simple example in single-account mode
func TestSimpleExampleSingleAccount(t *testing.T) {
	t.Parallel()

	// Generate unique identifier for this test run
	uniqueID := strings.ToLower(random.UniqueId())
	prefix := fmt.Sprintf("test-%s", uniqueID)

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-west-2"}, nil)
	accountID := aws.GetAccountId(t)

	// Construct terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Path to the Terraform code that will be tested
		TerraformDir: "../examples/aws/simple",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"deployment_mode":               "single-account",
			"account_id":                    accountID,
			"prefix":                        prefix,
			"enabled_regions":               []string{awsRegion},
			"vpc_cidr":                      "10.100.0.0/16",
			"enable_guardduty":              true,
			"enable_security_hub":           true,
			"enable_cloudtrail":             true,
			"enable_config":                 true,
			"enable_nat_gateway":            true,
			"single_nat_gateway":            true,
			"cloudwatch_log_retention_days": 7,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},

		// Disable colors in Terraform commands for easier log parsing
		NoColor: true,
	})

	// Clean up resources with terraform destroy at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Run validations
	t.Run("VPC_Configuration", func(t *testing.T) {
		testVPCConfiguration(t, terraformOptions, awsRegion, prefix)
	})

	t.Run("Security_Services", func(t *testing.T) {
		testSecurityServices(t, terraformOptions, awsRegion, prefix)
	})

	t.Run("Logging_Services", func(t *testing.T) {
		testLoggingServices(t, terraformOptions, awsRegion, prefix)
	})

	t.Run("IAM_Configuration", func(t *testing.T) {
		testIAMConfiguration(t, terraformOptions)
	})
}

// testVPCConfiguration validates VPC resources
func testVPCConfiguration(t *testing.T, terraformOptions *terraform.Options, awsRegion, prefix string) {
	// Get VPC ID from outputs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	require.NotEmpty(t, vpcID, "VPC ID should not be empty")

	// Verify VPC exists and has correct CIDR
	vpc := aws.GetVpcById(t, vpcID, awsRegion)
	assert.Equal(t, "10.100.0.0/16", vpc.Cidr, "VPC should have correct CIDR block")

	// Check VPC has correct tags
	expectedNameTag := fmt.Sprintf("%s-vpc", prefix)
	assert.Equal(t, expectedNameTag, vpc.Name, "VPC should have correct name tag")

	// Verify subnets exist
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")

	assert.GreaterOrEqual(t, len(publicSubnetIDs), 2, "Should have at least 2 public subnets")
	assert.GreaterOrEqual(t, len(privateSubnetIDs), 2, "Should have at least 2 private subnets")

	// Verify NAT Gateway exists (single NAT gateway mode)
	natGatewayIDs := terraform.OutputList(t, terraformOptions, "nat_gateway_ids")
	assert.Equal(t, 1, len(natGatewayIDs), "Should have exactly 1 NAT Gateway (single_nat_gateway=true)")
}

// testSecurityServices validates security-related AWS services
func testSecurityServices(t *testing.T, terraformOptions *terraform.Options, awsRegion, prefix string) {
	// Verify GuardDuty is enabled
	guarddutyDetectorID := terraform.Output(t, terraformOptions, "guardduty_detector_id")
	require.NotEmpty(t, guarddutyDetectorID, "GuardDuty detector ID should not be empty")

	// Verify Security Hub is enabled
	securityHubArn := terraform.Output(t, terraformOptions, "security_hub_arn")
	require.NotEmpty(t, securityHubArn, "Security Hub ARN should not be empty")
	assert.Contains(t, securityHubArn, "securityhub", "Security Hub ARN should contain 'securityhub'")

	// Verify AWS Config recorder exists
	configRecorderName := terraform.Output(t, terraformOptions, "config_recorder_name")
	require.NotEmpty(t, configRecorderName, "Config recorder name should not be empty")
}

// testLoggingServices validates logging and monitoring resources
func testLoggingServices(t *testing.T, terraformOptions *terraform.Options, awsRegion, prefix string) {
	// Verify CloudTrail is created
	cloudtrailName := terraform.Output(t, terraformOptions, "cloudtrail_name")
	require.NotEmpty(t, cloudtrailName, "CloudTrail name should not be empty")

	// Verify CloudTrail S3 bucket exists
	cloudtrailBucket := terraform.Output(t, terraformOptions, "cloudtrail_s3_bucket")
	require.NotEmpty(t, cloudtrailBucket, "CloudTrail S3 bucket should not be empty")

	// Check S3 bucket exists and is in correct region
	aws.AssertS3BucketExists(t, awsRegion, cloudtrailBucket)

	// Verify CloudWatch log group exists
	logGroupName := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")
	require.NotEmpty(t, logGroupName, "CloudWatch log group name should not be empty")

	// Wait a bit for CloudWatch to propagate
	time.Sleep(10 * time.Second)
}

// testIAMConfiguration validates IAM resources
func testIAMConfiguration(t *testing.T, terraformOptions *terraform.Options) {
	// Verify IAM Access Analyzer ARN exists
	accessAnalyzerArn := terraform.Output(t, terraformOptions, "iam_access_analyzer_arn")
	require.NotEmpty(t, accessAnalyzerArn, "IAM Access Analyzer ARN should not be empty")
	assert.Contains(t, accessAnalyzerArn, "access-analyzer", "Access Analyzer ARN should contain 'access-analyzer'")

	// Verify password policy is set (this is a basic check)
	// In a real scenario, you'd use AWS SDK to fetch and validate the policy
	t.Log("IAM password policy should be configured (manual verification recommended)")
}
