# Terratest Integration Tests

This directory contains integration tests for the AWS Cloud Landing Zone Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Overview

Terratest is a Go library that provides patterns and helper functions for testing infrastructure code. These tests:

1. Deploy real infrastructure to AWS
2. Validate that resources are created correctly
3. Clean up resources after testing

## Prerequisites

- Go 1.21 or later
- AWS credentials configured
- Terraform installed
- Sufficient AWS permissions to create resources

## Test Files

- `simple_example_test.go` - Integration tests for the simple example (single-account mode)
- `go.mod` - Go module dependencies

## Running Tests

### Install Dependencies

```bash
cd test
go mod download
```

### Run All Tests

```bash
# Run all tests (parallel execution)
go test -v -timeout 30m

# Run all tests sequentially
go test -v -timeout 30m -parallel 1
```

### Run Specific Test

```bash
# Run only the simple example test
go test -v -timeout 30m -run TestSimpleExampleSingleAccount
```

### Run Tests with Custom Timeout

```bash
# Increase timeout for slower AWS regions
go test -v -timeout 60m
```

## Test Execution Flow

Each test follows this pattern:

1. **Setup**: Generate unique identifiers and configure Terraform options
2. **Deploy**: Run `terraform init` and `terraform apply`
3. **Validate**: Check that resources exist and are configured correctly
4. **Cleanup**: Run `terraform destroy` (via defer)

## Cost Considerations

⚠️ **WARNING**: These tests create real AWS resources that will incur costs.

Estimated cost per test run: **$0.50 - $2.00** (depending on test duration)

To minimize costs:
- Tests use `single_nat_gateway = true` (~$0.05/hour)
- CloudWatch log retention is set to 7 days
- Resources are automatically destroyed after testing
- Tests run in parallel by default (faster execution)

## Test Validations

### VPC Configuration Tests
- VPC exists with correct CIDR block
- Subnets are created in multiple AZs
- NAT Gateway is configured correctly
- VPC Flow Logs are enabled

### Security Services Tests
- GuardDuty detector is enabled
- Security Hub is enabled with standards
- AWS Config recorder is running

### Logging Services Tests
- CloudTrail is logging to S3
- CloudWatch Logs group exists
- S3 buckets have correct configuration

### IAM Configuration Tests
- IAM Access Analyzer is enabled
- Password policy is configured

## Debugging Failed Tests

### View Terraform Output

```bash
# Run with detailed Terraform logs
TF_LOG=DEBUG go test -v -timeout 30m -run TestSimpleExampleSingleAccount
```

### Skip Cleanup on Failure

Modify the test to comment out the `defer terraform.Destroy(t, terraformOptions)` line to inspect resources after a failed test.

**Remember to manually clean up resources afterwards!**

### Check AWS Console

If a test fails, check the AWS Console to see:
- CloudFormation events (if using)
- VPC resources
- Security service status
- CloudWatch logs

## CI/CD Integration

These tests are designed to run in CI/CD pipelines. See `.github/workflows/integration-tests.yml` for the automated workflow.

### Environment Variables

The following environment variables are respected:

- `AWS_DEFAULT_REGION` - Override the default region
- `AWS_ACCESS_KEY_ID` - AWS credentials
- `AWS_SECRET_ACCESS_KEY` - AWS credentials
- `AWS_SESSION_TOKEN` - For temporary credentials

## Best Practices

1. **Parallel Execution**: Tests are marked with `t.Parallel()` for faster execution
2. **Unique Identifiers**: Each test run uses a unique ID to avoid resource conflicts
3. **Retryable Errors**: Uses `WithDefaultRetryableErrors` for eventual consistency
4. **Comprehensive Cleanup**: Always uses `defer terraform.Destroy` for cleanup
5. **Timeout Settings**: Sets appropriate timeouts for AWS resource creation

## Troubleshooting

### Test Timeout

If tests timeout, increase the timeout value:
```bash
go test -v -timeout 60m
```

### AWS Rate Limiting

If you hit AWS rate limits, run tests sequentially:
```bash
go test -v -timeout 30m -parallel 1
```

### Terraform State Lock

If state gets locked, manually unlock in AWS (DynamoDB table) or wait for automatic timeout.

## Adding New Tests

To add a new integration test:

1. Create a new `*_test.go` file
2. Follow the pattern in `simple_example_test.go`
3. Use descriptive test names: `TestExampleName`
4. Add subtests with `t.Run()` for specific validations
5. Always use `defer terraform.Destroy(t, terraformOptions)`
6. Mark with `t.Parallel()` if safe to run concurrently

## Resources

- [Terratest Documentation](https://terratest.gruntwork.io/)
- [Terratest AWS Package](https://pkg.go.dev/github.com/gruntwork-io/terratest/modules/aws)
- [Go Testing Package](https://pkg.go.dev/testing)
