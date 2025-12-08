# Knative cost optimization - Learning toolkit

[![CNCF Project](https://img.shields.io/badge/CNCF-Graduated-blue)](https://knative.dev/)
[![Vendor Neutral](https://img.shields.io/badge/Vendor-Neutral-green)](https://www.cncf.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Kyverno](https://img.shields.io/badge/Kyverno-1.11+-00A95C?logo=kyverno&logoColor=white)](https://kyverno.io/)

> **🏳️ Vendor neutral**: runs on ANY Kubernetes - AWS, Azure, GCP, on-premise, anywhere.
>
> **Educational content**: this repository provides learning materials and examples for understanding Knative cost optimization. It is NOT production-ready code. Always validate with your platform team and adapt for your specific requirements.

## 📋 What's inside

This learning toolkit helps you understand and calculate the cost impact of Knative's scale-to-zero capabilities in **vendor-neutral** Kubernetes environments.

**No fabricated numbers.** Use YOUR actual data to get real insights.

**No vendor lock-in.** Same code works everywhere.

### ⚠️ When to use Knative

Knative is **excellent** for:
- ✅ **HTTP APIs**: REST, GraphQL, webhooks
- ✅ **Event-driven functions**: Process events, triggers
- ✅ **Request/response workloads**: User-facing services
- ✅ **Batch processing**: Scheduled jobs, data transformation
- ✅ **Services with idle periods**: Business hours only, sporadic traffic
- ✅ **Dev/staging environments**: Automatic cost savings

### ❌ When NOT to use Knative

Knative is **NOT appropriate** for:
- 🚫 **Databases**: MySQL, PostgreSQL, MongoDB (always-on, stateful)
- 🚫 **Message queues**: RabbitMQ, Kafka brokers (persistent)
- 🚫 **WebSockets**: Long-lived connections (incompatible with scale-to-zero)
- 🚫 **Cache servers**: Redis, Memcached (need instant availability)
- 🚫 **Streaming**: Video/audio streaming (persistent connections)
- 🚫 **Ultra-low latency**: <100ms cold start unacceptable
- 🚫 **Stateful services**: Session stores, distributed locks

**Key principle:** If it needs to be **always available instantly**, don't use Knative.

**Cold start reality:** ~300ms-1s first request after idle. Acceptable for APIs, not for real-time systems.

### 🧮 Cost calculators

2. **Python script** (`calculators/cost_calculator.py`)
   - Automation-friendly
   - Batch processing multiple services
   - Export results to CSV
   - Integrate with your monitoring tools

### 📚 Learning materials

- **Simple setup & cleanup scripts**: Knative installation
- **2 basic examples**: hello-world, scale-to-zero demo
- **2 essential policies**: Kyverno governance
- **1 Financial Services example**: Treasury API pattern
- **Cost calculator templates**: Use YOUR numbers
- **Clear README tutorials**: Step-by-step learning

---

## 🎯 Why this toolkit?

Traditional Kubernetes deployments run 24/7, even when idle:
- Minimum replicas always running
- Development environments paid 168 hours/week but used ~40 hours
- No automatic shutdown when traffic stops

### Knative

Knative enables scale-to-zero:
- Zero replicas when no traffic = $0 cost
- Sub-second cold starts when requests arrive
- Automatic scaling based on actual load

### Vendor neutral advantage

**Same code. Same API. Everywhere.**

Unlike cloud-specific serverless (Lambda, Cloud Functions, Azure Functions):
- ✅ Runs on ANY Kubernetes (EKS, AKS, GKE, OpenShift, on-prem)
- ✅ No vendor lock-in
- ✅ Multi-cloud ready
- ✅ Full infrastructure control

### The missing piece

Without governance, serverless becomes chaos. Kyverno policies ensure:
- Scale-to-zero enforced in dev/staging
- Resource limits prevent runaway costs
- Cost tags enable proper chargeback
- **Vendor-neutral policies work everywhere**

---

## 🏳️ Why vendor neutral matters

Knative is a **CNCF graduated project** - open source, community-driven, vendor-neutral by design.

### The problem with cloud-specific serverless

| Service | Limitation |
|---------|------------|
| AWS Lambda | Locked to AWS only |
| Google Cloud Functions | Locked to GCP only |
| Azure Functions | Locked to Azure only |

**Result**: Vendor lock-in, proprietary APIs, migration nightmares.

### The Knative advantage

Knative runs on ANY Kubernetes:
- ✅ **AWS EKS** - Enterprise Kubernetes Service
- ✅ **Azure AKS** - Azure Kubernetes Service  
- ✅ **Google GKE** - Google Kubernetes Engine
- ✅ **Red Hat OpenShift** - Enterprise platform
- ✅ **Rancher** - Multi-cluster management
- ✅ **On-premise** - Your datacenter
- ✅ **Local dev** - Minikube

**Knative enables true multi-cloud serverless strategies.**

### Portability in Action

```yaml
# This SAME YAML works on:
# - AWS EKS
# - Azure AKS  
# - GCP GKE
# - On-premise K8s

apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-api
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/min-scale: "0"
    spec:
      containers:
      - image: myregistry/my-api:v1
```

**Deploy once. Run anywhere. Zero changes.**

---

## 📁 Repository Structure

```
knative-cost-optimization-learning/
├── README.md                           # This file
├── LICENSE
│
├── calculators/
│   ├── cost_calculator.py              # Python script
│   └── README.md                       # Calculator usage guide
│
├── setup/
│   ├── cleanup-knative.sh              # Knative uninstallation
│   └── install-knative.sh              # Knative installation
│
├── examples/
│   ├── hello-world.yaml                # Basic Knative service
│   ├── scale-to-zero-demo.yaml         # Scale-to-zero example
│   ├── treasury-api.yaml               # Financial Services example
│   └── governance/
│       ├── bad-service.yaml            # Policy violation
│       └── good-service.yaml           # Policy compliant
│
└── policies/
    ├── enforce-scale-to-zero.yaml      # Dev/staging policy
    └── enforce-resource-limits.yaml    # Cost control
```

## 💡 How to use this toolkit

### Step 1: Calculate YOUR potential savings

**Using Python calculator:**
```bash
cd calculators
python3 cost_calculator.py --services 10 --replicas 3 --usage-hours 45 --cost-per-hour 0.05
```

**Formula:**
```
Traditional Cost = services × replicas × 168 hours/week × cost/hour
Knative Cost = services × replicas × actual_usage_hours × cost/hour
Potential Savings = Traditional Cost - Knative Cost
```

**Example pattern (financial services):**
- Trading APIs active: 9h-18h weekdays only
- Usage: 45 hours/week
- Billed traditionally: 168 hours/week
- Idle time: 123 hours/week (73%)

### Step 2: set up your learning environment

**Prerequisites:**
- Kubernetes cluster (minikube)
- kubectl installed

**Quick start:**
```bash
# Clone this repository
git clone https://github.com/ChristianDussol/knative-cost-optimization-learning.git
cd knative-cost-optimization-learning

# Option 1: Minikube (Once installed)
minikube tunnel
# Open a new terminal
cd setup
chmod +x install-knative.sh
./install-knative.sh

```

### Step 3: test with examples

**Deploy a sample application:**
```bash
cd examples
kubectl apply -f hello-world.yaml
```

**Watch Scale-to-Zero in action:**
```bash
# Watch pods
watch kubectl get pods

# Send traffic
# Open a new terminal
curl http://hello-world.default.127.0.0.1.sslip.io

# Wait 60 seconds (no traffic)
# Pods will scale to zero

# Send traffic again
curl http://hello-world.default.127.0.0.1.sslip.io
# Pod starts in <1 second
```

**Test governance policies:**
```bash
cd examples/governance

# This should FAIL (no scale-to-zero in dev namespace)
kubectl apply -f bad-service.yaml

# This should SUCCEED (scale-to-zero enabled)
kubectl apply -f good-service.yaml
```

---

## Examples included

### 1. Basic Scale-to-Zero service

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-world
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/min-scale: "0"  # Scale to zero
        autoscaling.knative.dev/max-scale: "10"
    spec:
      containers:
      - image: gcr.io/knative-samples/helloworld-go
        env:
        - name: TARGET
          value: "Knative"
```

### 2. Governance policy (Kyverno)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-scale-to-zero-dev
spec:
  validationFailureAction: enforce
  rules:
  - name: require-min-scale-zero
    match:
      resources:
        kinds:
        - Service
        namespaces:
        - dev-*
        - staging-*
    validate:
      message: "Dev/staging services must enable scale-to-zero"
      pattern:
        spec:
          template:
            metadata:
              annotations:
                autoscaling.knative.dev/min-scale: "0"
```

**Same policies work on EKS, AKS, GKE, on-prem!**

---

## ⚠️ Important notes

### This is educational content

- ✅ Learn Knative concepts and patterns
- ✅ Understand cost optimization formulas
- ✅ Experiment in safe environments
- ❌ Do NOT use directly in production
- ❌ Do NOT assume savings without testing
- ❌ Do NOT skip validation with your platform team

### Cost considerations

- Cold starts add latency (typically <1 second)
- First request after scale-to-zero takes longer
- Not suitable for ultra-low latency requirements
- Consider reserved capacity for predictable workloads
- Monitor actual usage patterns before optimizing
- **Test on your target environment** (works everywhere!)

---

## 📚 Additional resources

### Official documentation
- [Knative Documentation](https://knative.dev/docs/)
- [Kyverno Documentation](https://kyverno.io/docs/)
- [CNCF Knative Project](https://www.cncf.io/projects/knative/)

### Community
- [Knative Slack](https://knative.slack.com)
- [Kyverno Slack](https://slack.k8s.io) - #kyverno channel
- [CNCF Slack](https://slack.cncf.io)

---

## 📌 Related Projects in "CNCF Project Focus" Series

This is **#1 in the series**. Future projects will explore other CNCF graduated projects.

---

**⭐ If this helped you learn about vendor-neutral serverless with Knative, please star the repo!**
