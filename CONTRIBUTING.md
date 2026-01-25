# Contributing to AWS Cloud Landing Zone

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment.

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker
- Include detailed description of the problem
- Provide steps to reproduce
- Include Terraform version and AWS provider version
- Share relevant logs (redact sensitive information)

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/tf-cloud-landing-zone.git
   cd tf-cloud-landing-zone
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **Make your changes**
   - Follow the coding standards below
   - Add tests for new functionality
   - Update documentation

4. **Run pre-commit hooks**
   ```bash
   pre-commit install
   pre-commit run --all-files
   ```

5. **Run tests**
   ```bash
   terraform init
   terraform test
   ```

6. **Commit your changes**
   ```bash
   git commit -m "feat: add new feature"
   ```

7. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

8. **Create a Pull Request**

## Coding Standards

### Terraform Style

- Use `terraform fmt` for formatting
- Follow [HashiCorp Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Use meaningful variable and resource names
- Add descriptions to all variables and outputs
- Use validation blocks for input validation

### Documentation

- Update README.md for new features
- Add examples for new functionality
- Document breaking changes in CHANGELOG.md
- Include inline comments for complex logic

### Testing

- Add Terraform tests for new features
- Ensure all tests pass before submitting PR
- Test both deployment modes when applicable

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `test:` Test additions or modifications
- `refactor:` Code refactoring
- `chore:` Maintenance tasks

## Pull Request Process

1. Update README.md with details of changes
2. Update CHANGELOG.md under [Unreleased] section
3. Ensure all CI checks pass
4. Request review from maintainers
5. Address review feedback

## Development Setup

### Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured
- Pre-commit installed
- TFLint installed

### Setup

```bash
# Install pre-commit hooks
pre-commit install

# Initialize Terraform
terraform init

# Run tests
terraform test

# Run linting
tflint --recursive
```

## Questions?

Feel free to open an issue for questions or clarifications.

Thank you for contributing! 🎉
