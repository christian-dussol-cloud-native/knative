# 🔧 Setup scripts

Installation and cleanup scripts for Knative learning environment.

---

## 📋 Available scripts

### 1. `install-knative.sh`
Installs Knative Serving on existing Kubernetes cluster.

**Usage:**
```bash
chmod +x install-knative.sh
./install-knative.sh
```

**What it does:**
- ✅ Installs Knative Serving 1.12.0
- ✅ Installs Kourier (networking layer)
- ✅ Configures Magic DNS (sslip.io)
- ✅ Creates test service 'hello'
- ✅ Verifies installation

**Requirements:**
- Kubernetes cluster running (minikube or cloud)
- kubectl configured
- 4+ GB RAM available

**Works on:**
- ✅ Minikube
- ✅ AWS EKS
- ✅ Azure AKS
- ✅ Google GKE
- ✅ On-premise K8s
- ✅ Any Kubernetes 1.28+

---

### 3. `cleanup-knative.sh` ⚠️
Removes Knative Serving and test services.

**Usage:**
```bash
chmod +x cleanup-knative.sh
./cleanup-knative.sh
```

**What it removes:**
- ❌ All Knative services (hello, scale-demo, etc.)
- ❌ Knative Serving components
- ❌ Kourier networking
- ❌ All Knative CRDs and webhooks
- ❌ Test namespaces (dev, staging)

**⚠️ WARNING:** This is destructive for Knative! Confirm before running.

**Use cases:**
- Clean slate before reinstalling Knative
- Testing Knative installation process
- Removing Knative completely
- Troubleshooting failed Knative installations

---

## 🚀 Quick start (complete flow)

### Fresh installation

```bash
# Step 1: Install minikube (if not already installed)

# Step 2: Install Knative + Kyverno
./install-knative.sh

# Step 3: Test the service
kubectl get ksvc hello

# Step 4: In another terminal, start tunnel
minikube tunnel

# Step 5: Test scale-to-zero
curl http://hello.default.127.0.0.1.sslip.io
```

### Cleanup and reinstall

```bash
# Step 1: Clean everything
./cleanup-knative.sh
# Confirm with 'y'

# Step 2: Verify cleanup
kubectl get namespaces
# Should NOT see: knative-serving, kourier-system

# Step 3: Reinstall
./install-knative.sh

# Step 4: Test again
minikube tunnel  # In another terminal
curl http://hello.default.127.0.0.1.sslip.io
```

---

## Troubleshooting

### Installation stuck

**Symptom:** `install-knative.sh` hangs on "Waiting for pods..."

**Solution:**
```bash
# Check pod status
kubectl get pods -n knative-serving

# Check events
kubectl get events -n knative-serving --sort-by='.lastTimestamp'

# If stuck, cleanup and retry
Ctrl+C
./cleanup-knative.sh
./install-knative.sh
```

### Service not accessible

**Symptom:** `curl: (6) Could not resolve host`

**Solutions:**

1. **Use minikube tunnel (recommended):**
   ```bash
   # Terminal 1
   minikube tunnel
   
   # Terminal 2
   curl http://hello.default.127.0.0.1.sslip.io
   ```

### Cleanup incomplete

**Symptom:** Some resources still exist after cleanup

**Solution:**
```bash
# Manual cleanup of remaining resources
kubectl delete namespace knative-serving --force --grace-period=0
kubectl delete namespace kourier-system --force --grace-period=0

# Remove CRDs
kubectl get crd | grep knative | awk '{print $1}' | xargs kubectl delete crd
kubectl get crd | grep kyverno | awk '{print $1}' | xargs kubectl delete crd
```

### Minikube issues

**Symptom:** Minikube won't start or behaves oddly

**Solution:**
```bash
# Complete minikube reset
minikube stop
minikube delete
minikube start --cpus=4 --memory=8192

# Then reinstall Knative
./install-knative.sh
```

---

## 📊 Verification commands

### Check installation status

```bash
# Knative Serving
kubectl get pods -n knative-serving
# All pods should be Running

# Kourier
kubectl get pods -n kourier-system
# All pods should be Running

# Services
kubectl get ksvc
# Should show 'hello' service as Ready
```

### Check resource usage

```bash
# Cluster resources
kubectl top nodes

# Pod resources
kubectl top pods --all-namespaces
```

---

## 📝 Script details

### Install versions

- **Knative Serving:** v1.12.0
- **Kourier:** v1.12.0

### Network configuration

- **DNS:** Magic DNS (sslip.io)
- **Ingress:** Kourier (lightweight)
- **Access:** minikube tunnel or NodePort

### Resource requirements

**Minimum:**
- 2 CPU cores
- 4 GB RAM
- 20 GB disk

**Recommended:**
- 4 CPU cores
- 8 GB RAM
- 40 GB disk