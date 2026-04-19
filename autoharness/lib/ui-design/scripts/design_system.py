#!/usr/bin/env python3
"""
Design System Generator - Generates design recommendations based on project context.

Usage:
    python design_system.py "fintech banking" --json
    python design_system.py --industry fintech --product banking --full
"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))
from core import search, detect_domain


def generate_full_system(industry: str = "", product: str = "", mood: str = "") -> dict:
    """Generate complete design system recommendations."""
    results = {}

    base_query = f"{industry} {product} {mood}".strip()

    domains = [
        "style",
        "product",
        "color",
        "typography",
        "landing",
        "ux",
        "techstack",
        "ui-reasoning",
        "chart",
    ]

    for domain in domains:
        domain_config = {
            "style": f"{base_query} style",
            "product": f"{industry} {product}",
            "color": f"{mood} {industry} color",
            "typography": f"{mood} {industry} font",
            "landing": f"{product} landing conversion",
            "ux": f"{industry} accessibility ux",
            "techstack": f"{industry} tech stack",
            "ui-reasoning": f"{product} {mood} design reasoning",
            "chart": f"{product} data visualization chart",
        }

        query = domain_config.get(domain, base_query)
        result = search(query, domain, max_results=3)
        results[domain] = result

    return {
        "context": {"industry": industry, "product": product, "mood": mood},
        "recommendations": results,
    }


def main():
    import argparse
    import json

    parser = argparse.ArgumentParser(description="Design System Generator")
    parser.add_argument("query", nargs="?", help="Search query")
    parser.add_argument("--industry", help="Industry type")
    parser.add_argument("--product", help="Product type")
    parser.add_argument("--mood", help="Design mood")
    parser.add_argument(
        "--domain",
        choices=[
            "style",
            "product",
            "color",
            "typography",
            "landing",
            "ux",
            "techstack",
            "ui-reasoning",
            "chart",
        ],
        help="Search domain",
    )
    parser.add_argument("--full", action="store_true", help="Generate full system")
    parser.add_argument("--json", action="store_true", help="Output as JSON")

    args = parser.parse_args()

    if args.full:
        result = generate_full_system(
            args.industry or "", args.product or "", args.mood or ""
        )
        print(json.dumps(result, indent=2, ensure_ascii=False))
    elif args.query:
        domain = args.domain or detect_domain(args.query)
        result = search(args.query, domain, max_results=5)

        if args.json:
            print(json.dumps(result, indent=2, ensure_ascii=False))
        else:
            print(f"\nDomain: {result['domain']}")
            print(f"Query: {result['query']}")
            print(f"Found: {result['count']} results\n")

            for i, row in enumerate(result["results"], 1):
                print(f"=== Result {i} ===")
                for key, value in row.items():
                    print(f"{key}: {value}")
                print()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
