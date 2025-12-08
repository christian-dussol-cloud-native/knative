#!/usr/bin/env python3
"""
Knative Cost Savings Calculator

Calculate potential cost savings from Knative scale-to-zero
compared to traditional always-on Kubernetes deployments.

Usage:
    python3 cost_calculator.py --services 10 --replicas 3 --usage-hours 45 --cost-per-hour 0.05
"""

import argparse
import json
import sys
from typing import Dict, List


def calculate_costs(services: int, replicas: int, usage_hours: float, cost_per_hour: float) -> Dict:
    """
    Calculate traditional K8s vs Knative costs.
    
    Args:
        services: Number of services
        replicas: Replicas per service
        usage_hours: Actual usage hours per week
        cost_per_hour: Cloud cost per pod-hour
        
    Returns:
        Dictionary with cost calculations
    """
    # Validate inputs
    if services <= 0 or replicas <= 0 or usage_hours <= 0 or cost_per_hour <= 0:
        raise ValueError("All inputs must be positive numbers")
    
    if usage_hours > 168:
        raise ValueError("Usage hours cannot exceed 168 hours per week")
    
    # Constants
    HOURS_PER_WEEK = 168
    WEEKS_PER_MONTH = 4.33  # Average
    WEEKS_PER_YEAR = 52
    
    # Traditional K8s (always-on)
    traditional_pod_hours_week = services * replicas * HOURS_PER_WEEK
    traditional_cost_week = traditional_pod_hours_week * cost_per_hour
    traditional_cost_month = traditional_cost_week * WEEKS_PER_MONTH
    traditional_cost_year = traditional_cost_week * WEEKS_PER_YEAR
    
    # Knative (scale-to-zero)
    knative_pod_hours_week = services * replicas * usage_hours
    knative_cost_week = knative_pod_hours_week * cost_per_hour
    knative_cost_month = knative_cost_week * WEEKS_PER_MONTH
    knative_cost_year = knative_cost_week * WEEKS_PER_YEAR
    
    # Savings
    savings_week = traditional_cost_week - knative_cost_week
    savings_month = traditional_cost_month - knative_cost_month
    savings_year = traditional_cost_year - knative_cost_year
    savings_percent = (savings_week / traditional_cost_week * 100) if traditional_cost_week > 0 else 0
    
    return {
        'inputs': {
            'services': services,
            'replicas': replicas,
            'usage_hours': usage_hours,
            'cost_per_hour': cost_per_hour
        },
        'traditional': {
            'pod_hours_week': traditional_pod_hours_week,
            'cost_week': traditional_cost_week,
            'cost_month': traditional_cost_month,
            'cost_year': traditional_cost_year
        },
        'knative': {
            'pod_hours_week': knative_pod_hours_week,
            'cost_week': knative_cost_week,
            'cost_month': knative_cost_month,
            'cost_year': knative_cost_year
        },
        'savings': {
            'week': savings_week,
            'month': savings_month,
            'year': savings_year,
            'percent': savings_percent
        }
    }


def print_results(results: Dict) -> None:
    """Print results in human-readable format."""
    print("\nKnative Cost Savings Calculator")
    print("=" * 50)
    
    print("\nInput Parameters:")
    print(f"  Services: {results['inputs']['services']}")
    print(f"  Replicas per service: {results['inputs']['replicas']}")
    print(f"  Usage hours/week: {results['inputs']['usage_hours']}")
    print(f"  Cost per pod-hour: ${results['inputs']['cost_per_hour']:.2f}")
    
    print("\nResults:")
    print("-" * 50)
    
    print("\nTraditional K8s (always-on):")
    print(f"  Pod-hours/week: {results['traditional']['pod_hours_week']:,.0f}")
    print(f"  Weekly cost: ${results['traditional']['cost_week']:,.2f}")
    print(f"  Monthly cost: ${results['traditional']['cost_month']:,.2f}")
    print(f"  Yearly cost: ${results['traditional']['cost_year']:,.2f}")
    
    print("\nKnative (scale-to-zero):")
    print(f"  Pod-hours/week: {results['knative']['pod_hours_week']:,.0f}")
    print(f"  Weekly cost: ${results['knative']['cost_week']:,.2f}")
    print(f"  Monthly cost: ${results['knative']['cost_month']:,.2f}")
    print(f"  Yearly cost: ${results['knative']['cost_year']:,.2f}")
    
    print("\nPotential Savings:")
    print(f"  Weekly: ${results['savings']['week']:,.2f} ({results['savings']['percent']:.1f}%)")
    print(f"  Monthly: ${results['savings']['month']:,.2f} ({results['savings']['percent']:.1f}%)")
    print(f"  Yearly: ${results['savings']['year']:,.2f} ({results['savings']['percent']:.1f}%)")
    
    print("\n" + "=" * 50)
    print("Note: These are estimates based on YOUR inputs.")
    print("Actual savings depend on workload patterns and cold start tolerance.")
    print("=" * 50 + "\n")


def export_to_csv(results: Dict, filename: str) -> None:
    """Export results to CSV file."""
    import csv
    
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        
        # Header
        writer.writerow(['Metric', 'Value'])
        
        # Inputs
        writer.writerow(['Services', results['inputs']['services']])
        writer.writerow(['Replicas', results['inputs']['replicas']])
        writer.writerow(['Usage Hours/Week', results['inputs']['usage_hours']])
        writer.writerow(['Cost per Pod-Hour', f"${results['inputs']['cost_per_hour']:.2f}"])
        writer.writerow([])
        
        # Traditional
        writer.writerow(['Traditional Pod-Hours/Week', results['traditional']['pod_hours_week']])
        writer.writerow(['Traditional Weekly Cost', f"${results['traditional']['cost_week']:.2f}"])
        writer.writerow(['Traditional Monthly Cost', f"${results['traditional']['cost_month']:.2f}"])
        writer.writerow(['Traditional Yearly Cost', f"${results['traditional']['cost_year']:.2f}"])
        writer.writerow([])
        
        # Knative
        writer.writerow(['Knative Pod-Hours/Week', results['knative']['pod_hours_week']])
        writer.writerow(['Knative Weekly Cost', f"${results['knative']['cost_week']:.2f}"])
        writer.writerow(['Knative Monthly Cost', f"${results['knative']['cost_month']:.2f}"])
        writer.writerow(['Knative Yearly Cost', f"${results['knative']['cost_year']:.2f}"])
        writer.writerow([])
        
        # Savings
        writer.writerow(['Weekly Savings', f"${results['savings']['week']:.2f}"])
        writer.writerow(['Monthly Savings', f"${results['savings']['month']:.2f}"])
        writer.writerow(['Yearly Savings', f"${results['savings']['year']:.2f}"])
        writer.writerow(['Savings Percentage', f"{results['savings']['percent']:.1f}%"])
    
    print(f"Results exported to {filename}")


def batch_calculate(scenarios_file: str) -> List[Dict]:
    """Calculate costs for multiple scenarios from JSON file."""
    with open(scenarios_file, 'r') as f:
        scenarios = json.load(f)
    
    results = []
    for scenario in scenarios:
        result = calculate_costs(
            services=scenario['services'],
            replicas=scenario['replicas'],
            usage_hours=scenario['usage_hours'],
            cost_per_hour=scenario['cost_per_hour']
        )
        result['name'] = scenario.get('name', 'Unnamed')
        results.append(result)
    
    return results


def main():
    parser = argparse.ArgumentParser(
        description='Calculate Knative cost savings with YOUR actual numbers'
    )
    
    # Single calculation mode
    parser.add_argument('--services', type=int, help='Number of services')
    parser.add_argument('--replicas', type=int, help='Replicas per service')
    parser.add_argument('--usage-hours', type=float, help='Actual usage hours per week')
    parser.add_argument('--cost-per-hour', type=float, help='Cloud cost per pod-hour ($)')
    
    # Batch mode
    parser.add_argument('--batch', type=str, help='JSON file with multiple scenarios')
    
    # Output
    parser.add_argument('--output', type=str, help='Export results to CSV file')
    parser.add_argument('--json', action='store_true', help='Output results as JSON')
    
    args = parser.parse_args()
    
    try:
        if args.batch:
            # Batch mode
            results = batch_calculate(args.batch)
            
            if args.json:
                print(json.dumps(results, indent=2))
            else:
                for result in results:
                    print(f"\n{'=' * 50}")
                    print(f"Scenario: {result['name']}")
                    print(f"{'=' * 50}")
                    print_results(result)
            
            if args.output:
                # Export all scenarios to CSV
                import csv
                with open(args.output, 'w', newline='') as f:
                    writer = csv.writer(f)
                    writer.writerow(['Scenario', 'Services', 'Replicas', 'Usage Hours', 
                                   'Cost/Hour', 'Traditional Yearly', 'Knative Yearly', 
                                   'Yearly Savings', 'Savings %'])
                    
                    for result in results:
                        writer.writerow([
                            result['name'],
                            result['inputs']['services'],
                            result['inputs']['replicas'],
                            result['inputs']['usage_hours'],
                            f"${result['inputs']['cost_per_hour']:.2f}",
                            f"${result['traditional']['cost_year']:.2f}",
                            f"${result['knative']['cost_year']:.2f}",
                            f"${result['savings']['year']:.2f}",
                            f"{result['savings']['percent']:.1f}%"
                        ])
                
                print(f"\nBatch results exported to {args.output}")
        
        else:
            # Single calculation mode
            if not all([args.services, args.replicas, args.usage_hours, args.cost_per_hour]):
                parser.error("Single calculation requires: --services, --replicas, --usage-hours, --cost-per-hour")
            
            results = calculate_costs(
                services=args.services,
                replicas=args.replicas,
                usage_hours=args.usage_hours,
                cost_per_hour=args.cost_per_hour
            )
            
            if args.json:
                print(json.dumps(results, indent=2))
            else:
                print_results(results)
            
            if args.output:
                export_to_csv(results, args.output)
    
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
