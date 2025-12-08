#!/bin/bash
#
# Install Knative Serving
# Educational setup - simplified for learning
# Vendor neutral: works on ANY Kubernetes!
#

set -e

echo "=========================================="
echo "Knative Serving Installation"
echo "=========================================="
echo ""

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed"
    echo "Please install kubectl first"
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo "ERROR: Cannot connect to Kubernetes cluster"
    echo "Please start your cluster or configure kubectl"
    exit 1
fi

echo "✓ Connected to Kubernetes cluster"
kubectl get nodes
echo ""

# Install Knative Serving
echo "=========================================="
echo "Installing Knative Serving..."
echo "=========================================="
echo ""

KNATIVE_VERSION="1.12.0"

echo "Installing Knative CRDs..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v${KNATIVE_VERSION}/serving-crds.yaml

echo "Waiting for CRDs to be ready..."
sleep 10

echo "Installing Knative Serving core..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v${KNATIVE_VERSION}/serving-core.yaml

echo "Waiting for Knative Serving to be ready..."
kubectl wait --for=condition=Ready pods --all -n knative-serving --timeout=300s

echo "✓ Knative Serving installed successfully"
echo ""

# Install Kourier as networking layer (lightweight)
echo "Installing Kourier (networking layer)..."
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v${KNATIVE_VERSION}/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

echo "✓ Kourier installed successfully"
echo ""

# Configure DNS (using Magic DNS for minikube)
echo "Configuring DNS..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v${KNATIVE_VERSION}/serving-default-domain.yaml

echo "✓ DNS configured"
echo ""

# Verify installation
echo "=========================================="
echo "Verifying Knative installation..."
echo "=========================================="
echo ""

echo "Knative Serving pods:"
kubectl get pods -n knative-serving
echo ""

echo "Kourier pods:"
kubectl get pods -n kourier-system
echo ""

# Create a test service
echo "=========================================="
echo "Testing Knative with hello-world service..."
echo "=========================================="
echo ""

cat <<EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "0"
        autoscaling.knative.dev/maxScale: "5"
    spec:
      containers:
      - image: gcr.io/knative-samples/helloworld-go
        env:
        - name: TARGET
          value: "Knative Learning"
EOF

echo ""
echo "Waiting for service to be ready..."
kubectl wait --for=condition=Ready ksvc/hello --timeout=300s

echo ""
echo "Testing service..."
SERVICE_URL=$(kubectl get ksvc hello -o jsonpath='{.status.url}')
echo "Service URL: $SERVICE_URL"

# For minikube, we need to set up access
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo ""
    echo "Detected minikube - setting up access..."
    
    # Get the minikube IP
    MINIKUBE_IP=$(minikube ip)
    
    # Get Kourier service NodePort
    KOURIER_PORT=$(kubectl get svc kourier -n kourier-system -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
    
    if [ -n "$KOURIER_PORT" ]; then
        echo "Kourier is accessible at: http://${MINIKUBE_IP}:${KOURIER_PORT}"
        echo ""
        echo "Testing with minikube IP and Host header..."
        
        # Extract hostname from service URL
        SERVICE_HOST=$(echo $SERVICE_URL | sed 's|http://||' | sed 's|https://||')
        
        # Test with curl using Host header
        curl -H "Host: ${SERVICE_HOST}" http://${MINIKUBE_IP}:${KOURIER_PORT} || echo "Note: Service may take a moment to be fully ready"
    else
        echo "Note: Kourier port not found. Service may still be initializing."
    fi
else
    # Not minikube - try direct access
    if command -v curl &> /dev/null; then
        echo ""
        echo "Testing request..."
        curl $SERVICE_URL || echo "Note: If this fails, you may need to configure ingress access"
    fi
fi

echo ""
echo "Watch the service scale to zero..."
echo "Run: watch kubectl get pods"
echo "After 60 seconds of no traffic, pods will terminate"
echo ""

echo "=========================================="
echo "✓ Installation Complete!"
echo "=========================================="
echo ""
echo "What's installed:"
echo "  ✓ Knative Serving ${KNATIVE_VERSION}"
echo "  ✓ Kourier (networking)"
echo "  ✓ Magic DNS (sslip.io)"
echo "  ✓ Test service 'hello'"
echo ""
echo "Next steps:"
echo "  1. Deploy examples: kubectl apply -f ../examples/"
echo "  2. Monitor scaling: watch kubectl get pods"
echo ""
echo "To test the service:"
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "  # In another terminal, run:"
    echo "  minikube tunnel"
    echo ""
    echo "  # Then test:"
    echo "  curl $SERVICE_URL"
else
    echo "  curl $SERVICE_URL"
fi
echo ""
echo "Vendor neutral: This SAME setup works on:"
echo "  - Minikube (local)"
echo "  - AWS EKS"
echo "  - Azure AKS"
echo "  - Google GKE"
echo "  - On-premise Kubernetes"
echo "  - Any Kubernetes 1.28+"
echo ""
echo "Scale-to-zero in action!"
echo ""
