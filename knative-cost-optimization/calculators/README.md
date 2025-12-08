# Knative Cost Calculators

Calculators to estimate your potential cost savings with Knative scale-to-zero.

---

## 🐍 Python Calculator

**File:** `cost_calculator.py`

### Installation

```bash
# No external dependencies needed - uses Python standard library
python3 --version  # Ensure Python 3.8+
```

### Usage

**Basic usage:**
```bash
python3 cost_calculator.py \
  --services 10 \
  --replicas 3 \
  --usage-hours 45 \
  --cost-per-hour 0.05
```

**Output:**
```
Knative Cost Savings Calculator
================================

Input Parameters:
- Services: 10
- Replicas per service: 3
- Usage hours/week: 45
- Cost per pod-hour: $0.05

Results:
--------
Traditional K8s Cost:
  - Pod-hours/week: 5,040
  - Weekly cost: $252.00
  - Monthly cost: $1,092.00
  - Yearly cost: $13,104.00

Knative (scale-to-zero):
  - Pod-hours/week: 1,350
  - Weekly cost: $67.50
  - Monthly cost: $292.50
  - Yearly cost: $3,510.00

Potential Savings:
  - Weekly: $184.50 (73%)
  - Monthly: $799.50 (73%)
  - Yearly: $9,594.00 (73%)

Note: These are estimates based on YOUR inputs.
Actual savings depend on workload patterns and cold start tolerance.
```

### Advanced Usage

**Export to CSV:**
```bash
python3 cost_calculator.py \
  --services 10 \
  --replicas 3 \
  --usage-hours 45 \
  --cost-per-hour 0.05 \
  --output results.csv
```

**Batch calculation (multiple scenarios):**
```bash
python3 cost_calculator.py \
  --batch scenarios.json \
  --output comparison.csv
```

**Example scenarios.json:**
```json
[
  {
    "name": "Trading APIs",
    "services": 10,
    "replicas": 3,
    "usage_hours": 45,
    "cost_per_hour": 0.05
  },
  {
    "name": "Dev Environment",
    "services": 5,
    "replicas": 2,
    "usage_hours": 40,
    "cost_per_hour": 0.03
  }
]
```

---

## Formula

```
Traditional Cost = services × replicas × 168 hours/week × cost/hour
Knative Cost = services × replicas × usage_hours/week × cost/hour
Savings = Traditional Cost - Knative Cost
Savings % = (Savings / Traditional Cost) × 100
```

**Key assumption:** Scale-to-zero means $0 cost when idle.

**Reality check:**
- Cold starts add latency (~1 second)
- First request after idle takes longer

---

## 🎯 Real-World Usage Patterns

### Financial Services - Trading APIs
- **Usage:** 9h-18h weekdays (45 hours/week)
- **Traditional:** 168 hours/week billed
- **Savings potential:** ~73%

### Development Environments
- **Usage:** Business hours only (~40 hours/week)
- **Traditional:** 24/7 running (168 hours/week)
- **Savings potential:** ~76%

### Webhooks / Event Handlers
- **Usage:** Sporadic throughout day (~60 hours/week)
- **Traditional:** Min 2-3 replicas 24/7
- **Savings potential:** ~60%

---

## ⚠️ Important Notes

1. **These are estimates** - actual results depend on:
   - Your workload patterns
   - Cold start tolerance
   - Scaling configuration
   - Infrastructure costs

2. **Test in non-production** first
3. **Monitor actual usage** before optimizing
4. **Consider cold start impact** on user experience