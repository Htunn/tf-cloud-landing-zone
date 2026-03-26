# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-03-26

### Added
- New unit test files covering previously untested areas:
  - `tests/iam.tftest.hcl` — IAM password policy defaults (all 8 fields), custom policy values, Access Analyzer, cross-account roles (19 tests)
  - `tests/security-services.tftest.hcl` — Security Hub standards (CIS + AWS Foundational), Macie, CloudTrail log validation, GuardDuty delegated admin, enabled-regions validation, combined security stacks (20 tests)
  - `tests/logging.tftest.hcl` — Centralized logging bucket, CloudTrail, all valid CloudWatch retention boundary values, VPC Flow Logs interaction (17 tests)
  - `tests/outputs.tftest.hcl` — `landing_zone_config` composite output (security_services, logging, encryption, organization blocks), prefix validation, custom tags (24 tests)

### Changed
- Tightened `required_version` from `>= 1.6.0` to `~> 1.8` in all 11 `versions.tf` files (aws root, azure root, and all 9 sub-modules) to prevent silent breakage from a future Terraform 2.0 release
- Upgraded AWS provider lock file (`aws/.terraform.lock.hcl`) from **6.37.0 → 6.38.0** (latest patch)

### Fixed
- Removed stale root-level `.terraform.lock.hcl` that incorrectly pinned `hashicorp/aws` at **v5.100.0** with constraint `< 6.0.0`, conflicting with the v6 migration

### Infrastructure
- Generated `azure/.terraform.lock.hcl` (previously missing); pinned `hashicorp/azurerm` at **4.65.0** (latest)

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

[Unreleased]: https://github.com/htunn/tf-cloud-landing-zone/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/htunn/tf-cloud-landing-zone/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/htunn/tf-cloud-landing-zone/releases/tag/v1.0.0
