#!/bin/bash

################################################################################
# Example Usage Script for OCI Deployment
# 
# This script demonstrates how to use the deploy-with-retry.sh script
# with various configurations.
################################################################################

# Example 1: Basic usage with minimal configuration
example_basic() {
    echo "=== Example 1: Basic Usage ==="
    echo ""
    echo "export OCI_STACK_ID='ocid1.ormstack.oc1.iad.aaaaaa...'"
    echo "./deploy-with-retry.sh"
    echo ""
}

# Example 2: With custom retry settings
example_custom_retry() {
    echo "=== Example 2: Custom Retry Settings ==="
    echo ""
    echo "export OCI_STACK_ID='ocid1.ormstack.oc1.iad.aaaaaa...'"
    echo "export OCI_MAX_RETRIES=20"
    echo "export OCI_INITIAL_WAIT=60"
    echo "export OCI_MAX_WAIT=600"
    echo "./deploy-with-retry.sh"
    echo ""
}

# Example 3: Using environment file
example_with_env_file() {
    echo "=== Example 3: Using Environment File ==="
    echo ""
    echo "# 1. Copy and edit the environment file"
    echo "cp .env.example .env"
    echo "nano .env"
    echo ""
    echo "# 2. Source the environment file"
    echo "source .env"
    echo ""
    echo "# 3. Run the deployment"
    echo "./deploy-with-retry.sh"
    echo ""
}

# Example 4: One-liner for CI/CD
example_cicd() {
    echo "=== Example 4: CI/CD One-Liner ==="
    echo ""
    echo "OCI_STACK_ID='\${{ secrets.OCI_STACK_ID }}' OCI_MAX_RETRIES=15 ./deploy-with-retry.sh"
    echo ""
}

# Example 5: With logging to file
example_with_logging() {
    echo "=== Example 5: With Logging to File ==="
    echo ""
    echo "export OCI_STACK_ID='ocid1.ormstack.oc1.iad.aaaaaa...'"
    echo "./deploy-with-retry.sh 2>&1 | tee deployment-\$(date +%Y%m%d-%H%M%S).log"
    echo ""
}

# Example 6: Multiple deployments with different stacks
example_multiple_stacks() {
    echo "=== Example 6: Multiple Stack Deployments ==="
    echo ""
    cat << 'EOF'
#!/bin/bash
declare -a STACKS=(
    "ocid1.ormstack.oc1.iad.aaaaaa...dev"
    "ocid1.ormstack.oc1.iad.aaaaaa...staging"
    "ocid1.ormstack.oc1.iad.aaaaaa...prod"
)

for stack_id in "${STACKS[@]}"; do
    echo "Deploying stack: $stack_id"
    OCI_STACK_ID="$stack_id" ./deploy-with-retry.sh
    if [ $? -ne 0 ]; then
        echo "Failed to deploy stack: $stack_id"
        exit 1
    fi
done
EOF
    echo ""
}

# Example 7: Pre-deployment validation
example_with_validation() {
    echo "=== Example 7: With Pre-Deployment Validation ==="
    echo ""
    cat << 'EOF'
#!/bin/bash

# Validate OCI CLI is installed
if ! command -v oci &> /dev/null; then
    echo "Error: OCI CLI is not installed"
    exit 1
fi

# Validate stack exists
if ! oci resource-manager stack get --stack-id "$OCI_STACK_ID" &> /dev/null; then
    echo "Error: Stack does not exist or is not accessible"
    exit 1
fi

# Run deployment
./deploy-with-retry.sh
EOF
    echo ""
}

# Print all examples
main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       OCI Deployment Script - Usage Examples                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    example_basic
    example_custom_retry
    example_with_env_file
    example_cicd
    example_with_logging
    example_multiple_stacks
    example_with_validation
    
    echo "For more information, see:"
    echo "  - README.md for comprehensive documentation"
    echo "  - QUICKSTART.md for step-by-step guide"
    echo ""
}

main
