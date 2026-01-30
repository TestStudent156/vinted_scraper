# OCI Deployment with Retry Logic

This directory contains scripts and configurations for deploying infrastructure to Oracle Cloud Infrastructure (OCI) with automatic retry logic.

## Overview

The `deploy-with-retry.sh` script automates the deployment of OCI Resource Manager stacks with built-in retry logic and exponential backoff. This ensures that temporary failures don't prevent successful deployments.

## Features

- **Automatic Retry**: Retries deployment up to a configurable number of times
- **Exponential Backoff**: Increases wait time between retries to handle rate limiting
- **Detailed Logging**: Color-coded output with timestamps for easy debugging
- **Error Handling**: Comprehensive error detection and reporting
- **Job Monitoring**: Tracks deployment job status until completion

## Prerequisites

1. **OCI CLI**: Install the Oracle Cloud Infrastructure CLI
   ```bash
   # Install OCI CLI
   bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
   ```

2. **OCI Configuration**: Configure your OCI credentials
   ```bash
   oci setup config
   ```

3. **OCI Stack**: Create a Resource Manager stack in your OCI tenancy
   - You can create a stack from the OCI Console
   - Or use the provided example Terraform files

## Usage

### Basic Usage

```bash
# Set your stack ID
export OCI_STACK_ID="ocid1.ormstack.oc1..<your-stack-id>"

# Run the deployment script
./deploy-with-retry.sh
```

### Advanced Configuration

The script supports several environment variables for customization:

```bash
# Maximum number of retry attempts (default: 10)
export OCI_MAX_RETRIES=15

# Initial wait time in seconds between retries (default: 30)
export OCI_INITIAL_WAIT=60

# Maximum wait time in seconds (default: 300)
export OCI_MAX_WAIT=600

# Your OCI Stack ID (required)
export OCI_STACK_ID="ocid1.ormstack.oc1..<your-stack-id>"

# Your OCI Compartment ID (optional)
export OCI_COMPARTMENT_ID="ocid1.compartment.oc1..<your-compartment-id>"

# Run the deployment
./deploy-with-retry.sh
```

### Example: Full Configuration

```bash
#!/bin/bash

# Configure retry behavior
export OCI_MAX_RETRIES=20
export OCI_INITIAL_WAIT=30
export OCI_MAX_WAIT=300

# Set your OCI credentials (if not using default config)
export OCI_CLI_PROFILE="DEFAULT"

# Set your stack ID
export OCI_STACK_ID="ocid1.ormstack.oc1.iad.xxxxxxxxxxxxxxxxxxxxxx"

# Optional: Set compartment ID
export OCI_COMPARTMENT_ID="ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxx"

# Run deployment
./deploy-with-retry.sh
```

## How It Works

1. **Initialization**: The script checks for OCI CLI installation and configuration
2. **Job Creation**: Creates an OCI Resource Manager apply job for the specified stack
3. **Job Monitoring**: Monitors the job status every 30 seconds
4. **Retry Logic**: If the job fails, waits with exponential backoff before retrying
5. **Success/Failure**: Reports final status and exits with appropriate code

### Retry Behavior

The script uses exponential backoff for retries:

- Attempt 1: Fail → Wait 30 seconds
- Attempt 2: Fail → Wait 60 seconds  
- Attempt 3: Fail → Wait 120 seconds
- Attempt 4: Fail → Wait 240 seconds
- Attempt 5+: Fail → Wait 300 seconds (capped at MAX_WAIT)

## Creating an OCI Stack

### Option 1: Using OCI Console

1. Go to OCI Console → Developer Services → Resource Manager → Stacks
2. Click "Create Stack"
3. Upload your Terraform configuration or use a Git repository
4. Configure variables
5. Note the Stack OCID for use with the deployment script

### Option 2: Using OCI CLI

```bash
# Create a stack from local Terraform files
oci resource-manager stack create \
  --compartment-id <compartment-ocid> \
  --config-source terraform/ \
  --display-name "My Application Stack" \
  --description "Application deployment stack"
```

### Option 3: Using Example Terraform

See the `terraform-example/` directory for a basic OCI stack configuration.

## Troubleshooting

### Script fails immediately

**Problem**: `OCI CLI is not configured properly`

**Solution**: Run `oci setup config` to configure your OCI credentials

### Stack ID not set

**Problem**: `STACK_ID is not set`

**Solution**: Export the `OCI_STACK_ID` environment variable with your stack OCID

### All retries exhausted

**Problem**: Deployment fails after all retry attempts

**Solution**: 
- Check OCI Console for detailed error messages
- Review stack logs in Resource Manager
- Verify Terraform configuration is valid
- Check OCI service limits and quotas
- Ensure IAM permissions are correct

### Job timeout

**Problem**: Job times out waiting for completion

**Solution**:
- Increase the timeout by modifying `max_wait_iterations` in the script
- Check if the job is actually running in OCI Console
- Review job logs for blocking issues

## Integration with CI/CD

### GitHub Actions

```yaml
name: Deploy to OCI

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup OCI CLI
        run: |
          bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
          
      - name: Configure OCI
        env:
          OCI_CLI_USER: ${{ secrets.OCI_USER_OCID }}
          OCI_CLI_FINGERPRINT: ${{ secrets.OCI_FINGERPRINT }}
          OCI_CLI_TENANCY: ${{ secrets.OCI_TENANCY_OCID }}
          OCI_CLI_REGION: ${{ secrets.OCI_REGION }}
          OCI_CLI_KEY_CONTENT: ${{ secrets.OCI_PRIVATE_KEY }}
        run: |
          mkdir -p ~/.oci
          echo "$OCI_CLI_KEY_CONTENT" > ~/.oci/key.pem
          chmod 600 ~/.oci/key.pem
          
      - name: Deploy to OCI
        env:
          OCI_STACK_ID: ${{ secrets.OCI_STACK_ID }}
          OCI_MAX_RETRIES: 15
        run: |
          cd oci-deployment
          ./deploy-with-retry.sh
```

### GitLab CI

```yaml
deploy_to_oci:
  stage: deploy
  image: python:3.9
  before_script:
    - pip install oci-cli
    - mkdir -p ~/.oci
    - echo "$OCI_PRIVATE_KEY" > ~/.oci/key.pem
    - chmod 600 ~/.oci/key.pem
  script:
    - export OCI_STACK_ID="$OCI_STACK_ID"
    - export OCI_MAX_RETRIES=15
    - cd oci-deployment
    - ./deploy-with-retry.sh
  only:
    - main
```

## Advanced Features

### Custom Retry Strategy

You can modify the `calculate_wait_time()` function in the script to implement different retry strategies:

```bash
# Linear backoff (not exponential)
calculate_wait_time() {
    local attempt=$1
    local wait_time=$((INITIAL_WAIT * attempt))
    echo $wait_time
}

# Fixed wait time
calculate_wait_time() {
    echo $INITIAL_WAIT
}
```

### Notification Integration

Add notifications on success/failure:

```bash
# Add to the end of main() function
if deploy_with_retry; then
    # Send success notification
    curl -X POST "https://your-webhook-url" \
      -H "Content-Type: application/json" \
      -d '{"status": "success", "message": "OCI deployment completed"}'
else
    # Send failure notification
    curl -X POST "https://your-webhook-url" \
      -H "Content-Type: application/json" \
      -d '{"status": "failed", "message": "OCI deployment failed"}'
fi
```

## License

This deployment script is provided as-is for use with the Vinted Scraper project.

## Support

For issues or questions:
1. Check the OCI Resource Manager documentation
2. Review OCI CLI documentation
3. Open an issue in the repository
