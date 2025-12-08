#!/bin/bash
#
# Cleanup Knative Only
# Removes Knative Serving and test services
#

set -e

# Confirm with user
read -p "This will remove Knative Serving and all test services. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup..."
echo ""

# Step 1: Delete test services
echo "=========================================="
echo "Step 1: Removing test services..."
echo "=========================================="
echo ""

# Delete all Knative services in default namespace
if kubectl get ksvc -n default &> /dev/null; then
    echo "Deleting Knative services in default namespace..."
    kubectl delete ksvc --all -n default --ignore-not-found=true
    echo "✓ Services deleted"
else
    echo "✓ No services to delete"
fi

# Delete dev namespace if exists (test namespace, not Kyverno)
if kubectl get namespace dev &> /dev/null; then
    echo "Deleting dev namespace..."
    kubectl delete namespace dev --ignore-not-found=true
    echo "✓ Dev namespace deleted"
fi

# Delete staging namespace if exists (test namespace)
if kubectl get namespace staging &> /dev/null; then
    echo "Deleting staging namespace..."
    kubectl delete namespace staging --ignore-not-found=true
    echo "✓ Staging namespace deleted"
fi

echo ""

# Step 2: Delete Kourier (networking layer)
echo "=========================================="
echo "Step 2: Removing Kourier..."
echo "=========================================="
echo ""

if kubectl get namespace kourier-system &> /dev/null; then
    echo "Deleting Kourier..."
    kubectl delete namespace kourier-system --ignore-not-found=true
    echo "Waiting for kourier-system namespace to be deleted..."
    kubectl wait --for=delete namespace/kourier-system --timeout=120s || true
    echo "✓ Kourier deleted"
else
    echo "✓ Kourier not installed"
fi

echo ""

# Step 3: Delete Knative Serving
echo "=========================================="
echo "Step 3: Removing Knative Serving..."
echo "=========================================="
echo ""

if kubectl get namespace knative-serving &> /dev/null; then
    echo "Deleting Knative Serving core components..."
    
    KNATIVE_VERSION="1.12.0"
    
    # Delete serving core
    kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${KNATIVE_VERSION}/serving-core.yaml --ignore-not-found=true
    
    # Delete CRDs
    kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${KNATIVE_VERSION}/serving-crds.yaml --ignore-not-found=true
    
    # Delete default domain config if exists
    kubectl delete -f https://github.com/knative/serving/releases/download/knative-v${KNATIVE_VERSION}/serving-default-domain.yaml --ignore-not-found=true || true
    
    # Wait for namespace to be deleted
    echo "Waiting for knative-serving namespace to be deleted..."
    kubectl wait --for=delete namespace/knative-serving --timeout=120s || true
    
    # Force delete if still exists
    if kubectl get namespace knative-serving &> /dev/null; then
        echo "Force deleting knative-serving namespace..."
        kubectl delete namespace knative-serving --force --grace-period=0 --ignore-not-found=true
    fi
    
    echo "✓ Knative Serving deleted"
else
    echo "✓ Knative Serving not installed"
fi

echo ""

# Step 4: Clean up any remaining Knative resources
echo "=========================================="
echo "Step 4: Cleaning up remaining Knative resources..."
echo "=========================================="
echo ""

# Delete any remaining Knative CRDs
echo "Checking for Knative CRDs..."
KNATIVE_CRDS=$(kubectl get crd -o name | grep -E 'knative|serving' || true)
if [ -n "$KNATIVE_CRDS" ]; then
    echo "Deleting remaining Knative CRDs..."
    echo "$KNATIVE_CRDS" | xargs kubectl delete --ignore-not-found=true
    echo "✓ CRDs cleaned up"
else
    echo "✓ No Knative CRDs to clean up"
fi

# Delete Knative ValidatingWebhookConfigurations
echo "Checking for Knative webhook configurations..."
WEBHOOKS=$(kubectl get validatingwebhookconfigurations -o name | grep knative || true)
if [ -n "$WEBHOOKS" ]; then
    echo "Deleting Knative webhook configurations..."
    echo "$WEBHOOKS" | xargs kubectl delete --ignore-not-found=true
    echo "✓ Webhooks cleaned up"
else
    echo "✓ No Knative webhooks to clean up"
fi

# Delete Knative MutatingWebhookConfigurations
MUTATING_WEBHOOKS=$(kubectl get mutatingwebhookconfigurations -o name | grep knative || true)
if [ -n "$MUTATING_WEBHOOKS" ]; then
    echo "Deleting Knative mutating webhook configurations..."
    echo "$MUTATING_WEBHOOKS" | xargs kubectl delete --ignore-not-found=true
    echo "✓ Mutating webhooks cleaned up"
else
    echo "✓ No Knative mutating webhooks to clean up"
fi

echo ""

# Step 5: Verify cleanup
echo "=========================================="
echo "Step 5: Verifying cleanup..."
echo "=========================================="
echo ""

echo "Checking for remaining Knative resources..."

# Check namespaces
REMAINING_NS=$(kubectl get namespaces -o name | grep -E 'knative|kourier' || true)
if [ -n "$REMAINING_NS" ]; then
    echo "⚠️  Warning: Some namespaces still exist:"
    echo "$REMAINING_NS"
else
    echo "✓ All Knative namespaces removed"
fi

# Check CRDs
REMAINING_CRDS=$(kubectl get crd -o name | grep -E 'knative|serving' || true)
if [ -n "$REMAINING_CRDS" ]; then
    echo "⚠️  Warning: Some Knative CRDs still exist:"
    echo "$REMAINING_CRDS"
else
    echo "✓ All Knative CRDs removed"
fi

# Check pods
REMAINING_PODS=$(kubectl get pods --all-namespaces -o wide | grep -E 'knative|kourier' || true)
if [ -n "$REMAINING_PODS" ]; then
    echo "⚠️  Warning: Some Knative pods still exist:"
    echo "$REMAINING_PODS"
else
    echo "✓ All Knative pods removed"
fi

echo ""

# Final status
echo "=========================================="
echo "✓ Cleanup Complete!"
echo "=========================================="
echo ""
echo "What was removed:"
echo "  ✓ Knative Serving (including CRDs)"
echo "  ✓ Kourier (networking layer)"
echo "  ✓ Test services (hello, scale-demo, etc.)"
echo "  ✓ Test namespaces (dev, staging)"
echo "  ✓ Knative webhook configurations"
echo ""
echo "What was preserved:"
echo "  ✓ Other cluster resources"
echo ""
echo "Your cluster is now clean and ready for fresh Knative installation."
echo ""
echo "To reinstall Knative:"
echo "  ./install-knative.sh"
echo ""

# Optional: Show cluster info
echo "Current cluster status:"
kubectl get nodes
echo ""
echo "Namespaces:"
kubectl get namespaces
echo ""