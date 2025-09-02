# CodeQL Configuration Status and Troubleshooting

## Current Configuration Status

### ✅ Working Configuration
- **Query Suite**: `security-extended` (built-in)
- **Languages**: Python, JavaScript
- **Path Filtering**: Container-focused (Dockerfiles, shell scripts, source code)
- **Pre-Analysis**: Hadolint (Dockerfile linting) and ShellCheck (shell script analysis)

### ⚠️ Temporarily Disabled Features
- **Custom Container Query Suite**: Disabled due to path resolution issues
- **Multiple Query Suites**: Simplified to single query suite to ensure reliability

## Issue Resolution

### Original Problem
```
A fatal error occurred: security-extended
security-and-quality is not a .ql file, .qls file, a directory, or a query pack specification.
```

### Root Cause
The issue was caused by improper YAML formatting in the workflow file where multiple query suites were specified using a multi-line string format (`|`) instead of proper YAML array syntax or single query specification.

### Solution Applied
1. **Removed multi-line query specification** from workflow file
2. **Simplified to single query suite** (`security-extended`)
3. **Moved complex query logic** to config file (when working properly)
4. **Added proper error handling** and documentation

## Re-enabling Custom Queries

### Step 1: Verify Query Files
Ensure all custom query files are valid:
```bash
# Test individual queries
codeql query compile .github/codeql/custom-queries/hardcoded-credentials.ql
codeql query compile .github/codeql/custom-queries/shell-injection.ql
```

### Step 2: Test Query Suite
Validate the custom query suite file:
```bash
# Test the query suite compilation
codeql resolve queries .github/codeql/custom-container-security.qls
```

### Step 3: Update Configuration
Once queries are verified, update the config file:
```yaml
# In .github/codeql/codeql-config.yml
queries:
  - uses: security-extended
  - uses: security-and-quality
  - name: "Container Security Suite"
    uses: ./.github/codeql/custom-container-security.qls
```

### Step 4: Test Workflow
Update the workflow to use multiple query suites:
```yaml
# In workflow file
queries: |
  security-extended
  ./.github/codeql/custom-container-security.qls
```

## Best Practices for CodeQL Configuration

### 1. Start Simple
- Begin with built-in query suites
- Add custom queries incrementally
- Test each addition thoroughly

### 2. Path Management
- Use relative paths from repository root
- Verify file existence before referencing
- Test path resolution in CI environment

### 3. Query Suite Structure
```yaml
# Recommended query suite structure
description: "Brief description of the query suite"
queries:
  - include:
      kind: problem
      suite: codeql/python-queries/Security
  - query: custom-queries/specific-check.ql
```

### 4. Error Handling
- Always include error handling in workflow steps
- Use non-blocking analysis where appropriate
- Provide clear error messages and debugging information

## Testing and Validation

### Local Testing
```bash
# Initialize CodeQL database
codeql database create test-db --language=python --source-root=.

# Run queries against test database
codeql database analyze test-db security-extended --format=sarif-latest --output=results.sarif

# Test custom queries
codeql database analyze test-db .github/codeql/custom-queries/ --format=sarif-latest --output=custom-results.sarif
```

### CI/CD Testing
1. **Enable debug mode** in workflow for detailed logs
2. **Test with minimal query set** first
3. **Gradually add complexity** after basic functionality works
4. **Monitor resource usage** and timeout settings

## Current Security Coverage

Even with the simplified configuration, the current setup provides:

- **CWE Coverage**: 50+ Common Weakness Enumeration categories
- **OWASP Top 10**: Web application security risks
- **Container Security**: Path filtering focuses on container-relevant files
- **Pre-Analysis**: Dockerfile and shell script security validation
- **Supply Chain**: Dependency and build process security

## Future Enhancements

1. **Custom Query Integration**: Re-enable container-specific custom queries
2. **Advanced Query Suites**: Create specialized query suites for different container types
3. **Integration Testing**: Add query validation to CI/CD pipeline
4. **Performance Optimization**: Fine-tune resource allocation and timeouts
5. **Reporting Enhancement**: Custom SARIF processing and enhanced reporting

## Support and Troubleshooting

### Common Issues
- **Path Resolution**: Verify all file paths are correct and accessible
- **Query Compilation**: Test individual queries before adding to suites
- **Resource Limits**: Monitor memory and CPU usage for large repositories
- **Timeout Issues**: Adjust timeout values for comprehensive analysis

### Debug Mode
Enable debug mode in workflow for detailed troubleshooting:
```yaml
debug: true
```

### Contact
For additional support or questions about CodeQL configuration:
- Check GitHub Actions logs for detailed error messages
- Review CodeQL documentation for query suite specifications
- Test configurations locally before deploying to CI/CD
