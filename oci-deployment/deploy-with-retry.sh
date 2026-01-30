#!/bin/bash

################################################################################
# OCI Stack Deployment Script with Retry Logic
# 
# This script applies an OCI (Oracle Cloud Infrastructure) stack and retries
# automatically until the deployment succeeds or reaches maximum retry attempts.
#
# Features:
# - Exponential backoff between retries
# - Configurable retry attempts and timeout
# - Detailed logging
# - Error handling
################################################################################

set -e

# Configuration
MAX_RETRIES="${OCI_MAX_RETRIES:-10}"
INITIAL_WAIT="${OCI_INITIAL_WAIT:-30}"
MAX_WAIT="${OCI_MAX_WAIT:-300}"
STACK_ID="${OCI_STACK_ID:-}"
COMPARTMENT_ID="${OCI_COMPARTMENT_ID:-}"
CONFIG_SOURCE="${OCI_CONFIG_SOURCE:-.}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if OCI CLI is installed
check_oci_cli() {
    if ! command -v oci &> /dev/null; then
        log_error "OCI CLI is not installed. Please install it first."
        log_info "Visit: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
        exit 1
    fi
    log_success "OCI CLI found"
}

# Check if OCI CLI is configured
check_oci_config() {
    if ! oci iam region list &> /dev/null; then
        log_error "OCI CLI is not configured properly. Please run 'oci setup config'"
        exit 1
    fi
    log_success "OCI CLI is configured"
}

# Apply the OCI stack
apply_stack() {
    local attempt=$1
    log_info "Attempt $attempt/$MAX_RETRIES: Applying OCI stack..."
    
    if [ -z "$STACK_ID" ]; then
        log_error "STACK_ID is not set. Please set OCI_STACK_ID environment variable."
        return 1
    fi
    
    # Create a job to apply the stack
    local job_output
    job_output=$(oci resource-manager job create-apply-job \
        --stack-id "$STACK_ID" \
        --execution-plan-strategy AUTO_APPROVED \
        2>&1) || {
        log_error "Failed to create apply job"
        echo "$job_output"
        return 1
    }
    
    # Extract job ID from output
    local job_id
    job_id=$(echo "$job_output" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$job_id" ]; then
        log_error "Failed to extract job ID"
        echo "$job_output"
        return 1
    fi
    
    log_info "Apply job created with ID: $job_id"
    log_info "Waiting for job to complete..."
    
    # Wait for the job to complete
    local max_wait_iterations=60  # 30 minutes max (60 * 30 seconds)
    local wait_iteration=0
    
    while [ $wait_iteration -lt $max_wait_iterations ]; do
        local job_status
        job_status=$(oci resource-manager job get --job-id "$job_id" --query 'data."lifecycle-state"' --raw-output 2>&1)
        
        case "$job_status" in
            SUCCEEDED)
                log_success "Stack applied successfully!"
                return 0
                ;;
            FAILED|CANCELED)
                log_error "Job $job_status"
                # Get job logs for debugging
                log_info "Fetching job logs..."
                oci resource-manager job get-job-logs --job-id "$job_id" 2>&1 || true
                return 1
                ;;
            IN_PROGRESS|ACCEPTED)
                log_info "Job status: $job_status (waiting...)"
                sleep 30
                wait_iteration=$((wait_iteration + 1))
                ;;
            *)
                log_warning "Unknown job status: $job_status"
                sleep 30
                wait_iteration=$((wait_iteration + 1))
                ;;
        esac
    done
    
    log_error "Job timed out after waiting for $((max_wait_iterations * 30)) seconds"
    return 1
}

# Calculate wait time with exponential backoff
calculate_wait_time() {
    local attempt=$1
    local wait_time=$((INITIAL_WAIT * (2 ** (attempt - 1))))
    
    # Cap at MAX_WAIT
    if [ $wait_time -gt $MAX_WAIT ]; then
        wait_time=$MAX_WAIT
    fi
    
    echo $wait_time
}

# Main deployment function with retry logic
deploy_with_retry() {
    log_info "Starting OCI stack deployment with retry logic"
    log_info "Max retries: $MAX_RETRIES"
    log_info "Initial wait: ${INITIAL_WAIT}s"
    log_info "Max wait: ${MAX_WAIT}s"
    log_info "Stack ID: $STACK_ID"
    
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "=== Deployment Attempt $attempt/$MAX_RETRIES ==="
        
        if apply_stack "$attempt"; then
            log_success "Deployment completed successfully on attempt $attempt!"
            return 0
        fi
        
        if [ $attempt -lt $MAX_RETRIES ]; then
            local wait_time
            wait_time=$(calculate_wait_time "$attempt")
            log_warning "Deployment failed. Waiting ${wait_time}s before retry..."
            sleep "$wait_time"
        fi
        
        attempt=$((attempt + 1))
    done
    
    log_error "Deployment failed after $MAX_RETRIES attempts"
    return 1
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Main execution
main() {
    echo "==============================================="
    echo "  OCI Stack Deployment with Retry"
    echo "==============================================="
    echo ""
    
    check_oci_cli
    check_oci_config
    
    if deploy_with_retry; then
        log_success "Stack deployment completed successfully!"
        exit 0
    else
        log_error "Stack deployment failed after all retry attempts"
        exit 1
    fi
}

# Run main function
main
