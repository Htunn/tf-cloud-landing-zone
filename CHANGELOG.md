# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of AWS Cloud Landing Zone Terraform module
- Support for dual deployment modes (single-account and organization)
- Networking module with VPC, subnets, NAT Gateway, Transit Gateway
- IAM module with password policies, Access Analyzer, cross-account roles
- Security module with GuardDuty, Security Hub, AWS Config, Macie
- Logging module with CloudTrail, CloudWatch Logs, S3 log aggregation
- Organization module with OU management and SCP support
- Terraform native unit tests
- GitHub Actions CI/CD workflows
- Pre-commit hooks for code quality
- Example configurations (simple, complete, multi-account)
- Comprehensive documentation

## [1.0.0] - 2026-01-24

### Added
- Initial release
- Single-account deployment mode
- Organization deployment mode with multi-account support
- Comprehensive security baseline
- Production-ready networking architecture
- Centralized logging and monitoring
- KMS encryption with key rotation
- Complete test coverage
- CI/CD integration

[Unreleased]: https://github.com/yourusername/tf-cloud-landing-zone/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/tf-cloud-landing-zone/releases/tag/v1.0.0
