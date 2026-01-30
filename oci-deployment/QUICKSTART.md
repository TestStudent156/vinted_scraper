# Quick Start Guide: OCI Deployment with Retry

This guide will help you get started with deploying to OCI using the retry script.

## Step 1: Install OCI CLI

### Linux/Mac
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

### Windows
Download and run the installer from:
https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

## Step 2: Configure OCI CLI

```bash
oci setup config
```

You'll need:
- Tenancy OCID
- User OCID
- Region (e.g., us-ashburn-1)
- API key (will be generated)

## Step 3: Create an OCI Stack

### Option A: Using OCI Console

1. Go to OCI Console → Resource Manager → Stacks
2. Click "Create Stack"
3. Choose "My Configuration" and upload `terraform-example/` directory
4. Fill in required variables
5. Click "Next" and "Create"
6. Copy the Stack OCID

### Option B: Using OCI CLI

```bash
# Navigate to terraform directory
cd terraform-example

# Copy and edit terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Create a zip file of your terraform config
zip -r ../terraform-config.zip .

# Create the stack
oci resource-manager stack create \
  --compartment-id <your-compartment-ocid> \
  --config-source ../terraform-config.zip \
  --display-name "Vinted Scraper Stack" \
  --description "Deployment stack for Vinted Scraper"

# Note the stack OCID from the output
```

## Step 4: Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your values
nano .env

# Set at minimum:
export OCI_STACK_ID="ocid1.ormstack.oc1.iad.aaaaaa..."

# Source the environment file
source .env
```

## Step 5: Run the Deployment Script

```bash
# Make sure the script is executable
chmod +x deploy-with-retry.sh

# Run the deployment
./deploy-with-retry.sh
```

The script will:
1. Verify OCI CLI is installed and configured
2. Create an apply job for your stack
3. Monitor the job status
4. Retry automatically if it fails
5. Report success or failure

## Step 6: Verify Deployment

After successful deployment:

```bash
# Check your compute instances
oci compute instance list --compartment-id <your-compartment-ocid>

# Get the public IPs
oci compute instance list-vnics --compartment-id <your-compartment-ocid>

# SSH to your instance (if created)
ssh opc@<public-ip>
```

## Troubleshooting Common Issues

### Issue: "OCI CLI is not configured properly"

**Solution:**
```bash
# Run OCI setup again
oci setup config

# Or check your config file
cat ~/.oci/config
```

### Issue: "STACK_ID is not set"

**Solution:**
```bash
# Make sure you've exported the variable
export OCI_STACK_ID="your-stack-ocid"

# Or source your .env file
source .env
```

### Issue: "Failed to create apply job"

**Solution:**
- Check that the stack exists: `oci resource-manager stack get --stack-id <stack-id>`
- Verify you have permissions to create jobs in the compartment
- Check if there's already a job running for this stack

### Issue: Job keeps failing

**Solution:**
1. Check the job logs in OCI Console
2. Verify your Terraform configuration is valid
3. Check service limits and quotas
4. Review IAM policies

## Next Steps

- Review the full [README.md](README.md) for advanced configuration
- Check the [terraform-example/](terraform-example/) directory for customizing your infrastructure
- Integrate with CI/CD pipelines (see README.md)

## Support

For issues:
1. Check OCI documentation: https://docs.oracle.com/iaas/
2. Review OCI CLI docs: https://docs.oracle.com/iaas/tools/oci-cli/
3. Open an issue in this repository
