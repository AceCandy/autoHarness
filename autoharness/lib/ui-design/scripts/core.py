#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AutoHarness UI Design Core - BM25 Search Engine

A lightweight BM25 search engine for UI/UX design recommendations.
Implements Okapi BM25 algorithm for text relevance ranking.

Author: AutoHarness Team
Inspired by: BM25 paper (Okapi BM25: a probabilistic relevance framework)
"""

import csv
import re
from pathlib import Path
from math import log
from collections import defaultdict

DATA_DIR = Path(__file__).parent.parent / "data"
MAX_RESULTS = 3

DOMAIN_CONFIG = {
    "style": {
        "file": "styles.csv",
        "search_cols": ["name", "keywords", "best_for"],
        "output_cols": [
            "name",
            "keywords",
            "best_for",
            "performance",
            "accessibility",
            "light_mode",
            "dark_mode",
            "effects",
        ],
    },
    "color": {
        "file": "colors.csv",
        "search_cols": ["use_case", "mood", "industries"],
        "output_cols": [
            "palette_name",
            "primary",
            "secondary",
            "accent",
            "background",
            "text",
            "use_case",
            "mood",
            "industries",
        ],
    },
    "product": {
        "file": "products.csv",
        "search_cols": ["industry", "product_type", "design_style"],
        "output_cols": [
            "industry",
            "product_type",
            "design_style",
            "recommended_colors",
            "key_features",
            "example_sites",
        ],
    },
    "typography": {
        "file": "typography.csv",
        "search_cols": ["use_case", "character", "industries"],
        "output_cols": [
            "font_pairing",
            "heading_font",
            "body_font",
            "sizescale",
            "weight_range",
            "use_case",
            "character",
            "industries",
        ],
    },
    "landing": {
        "file": "landing.csv",
        "search_cols": ["pattern_name", "use_case"],
        "output_cols": [
            "pattern_name",
            "sections",
            "cta_placement",
            "hero_style",
            "trust_signals",
            "social_proof",
            "conversion_focus",
            "use_case",
        ],
    },
    "ux": {
        "file": "ux.csv",
        "search_cols": ["ux_principle", "category", "description"],
        "output_cols": [
            "ux_principle",
            "category",
            "description",
            "implementation",
            "wcag_level",
            "impact_score",
        ],
    },
    "techstack": {
        "file": "techstack.csv",
        "search_cols": ["stack", "best_for", "notes"],
        "output_cols": [
            "stack",
            "category",
            "component_pattern",
            "state_management",
            "styling_approach",
            "routing",
            "optimization",
            "testing_framework",
            "best_for",
            "notes",
        ],
    },
    "ui-reasoning": {
        "file": "ui-reasoning.csv",
        "search_cols": ["reasoning_category", "design_question", "decision_factors"],
        "output_cols": [
            "reasoning_category",
            "design_question",
            "reasoning_logic",
            "design_implication",
            "wcag_impact",
            "performance_impact",
            "cognitive_impact",
            "decision_factors",
            "alternative_approaches",
        ],
    },
    "chart": {
        "file": "charts.csv",
        "search_cols": ["chart_type", "best_use_case", "examples_industries"],
        "output_cols": [
            "chart_type",
            "category",
            "best_use_case",
            "visual_style",
            "data_requirements",
            "interactions",
            "accessibility",
            "examples_industries",
            "limitations",
        ],
    },
}


class BM25:
    """
    BM25 (Okapi BM25) ranking algorithm implementation.

    BM25 is a probabilistic relevance ranking function used in information retrieval.
    It considers term frequency, document length, and average document length.

    Parameters:
        k1: Term frequency saturation parameter (default: 1.5)
        b: Document length normalization parameter (default: 0.75)

    Reference: Robertson, S., Zaragoza, H. (2009). The Probabilistic Relevance Framework: BM25
    """

    def __init__(self, k1=1.5, b=0.75):
        self.k1 = k1
        self.b = b
        self.corpus = []
        self.doc_lengths = []
        self.avgdl = 0
        self.idf = {}
        self.doc_freqs = defaultdict(int)
        self.N = 0

    def tokenize(self, text):
        """Tokenize text: lowercase, remove punctuation, filter short words."""
        text = re.sub(r"[^\w\s]", " ", str(text).lower())
        text = re.sub(r"_", " ", text)  # Split underscores
        return [w for w in text.split() if len(w) > 2]

    def fit(self, documents):
        """Build BM25 index from documents."""
        self.corpus = [self.tokenize(doc) for doc in documents]
        self.N = len(self.corpus)
        if self.N == 0:
            return

        self.doc_lengths = [len(doc) for doc in self.corpus]
        self.avgdl = sum(self.doc_lengths) / self.N

        for doc in self.corpus:
            seen = set()
            for word in doc:
                if word not in seen:
                    self.doc_freqs[word] += 1
                    seen.add(word)

        for word, freq in self.doc_freqs.items():
            self.idf[word] = log((self.N - freq + 0.5) / (freq + 0.5) + 1)

    def score(self, query):
        """Score all documents against query."""
        query_tokens = self.tokenize(query)
        scores = []

        for idx, doc in enumerate(self.corpus):
            score = 0
            doc_len = self.doc_lengths[idx]
            term_freqs = defaultdict(int)
            for word in doc:
                term_freqs[word] += 1

            for token in query_tokens:
                if token in self.idf:
                    tf = term_freqs[token]
                    idf = self.idf[token]
                    numerator = tf * (self.k1 + 1)
                    denominator = tf + self.k1 * (
                        1 - self.b + self.b * doc_len / self.avgdl
                    )
                    score += idf * numerator / denominator

            scores.append((idx, score))

        return sorted(scores, key=lambda x: x[1], reverse=True)


def load_csv(filepath):
    """Load CSV and return list of dicts."""
    with open(filepath, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def search_csv(filepath, search_cols, output_cols, query, max_results):
    """Core search function using BM25."""
    if not filepath.exists():
        return []

    data = load_csv(filepath)

    documents = [" ".join(str(row.get(col, "")) for col in search_cols) for row in data]

    bm25 = BM25()
    bm25.fit(documents)
    ranked = bm25.score(query)

    results = []
    for idx, score in ranked[:max_results]:
        if score > 0:
            row = data[idx]
            results.append({col: row.get(col, "") for col in output_cols if col in row})

    return results


def detect_domain(query):
    """Auto-detect search domain from query."""
    query_lower = query.lower()

    domain_keywords = {
        "color": [
            "color",
            "palette",
            "配色",
            "颜色",
            "hex",
            "#",
            "primary",
            "secondary",
        ],
        "product": [
            "saas",
            "fintech",
            "healthcare",
            "电商",
            "游戏",
            "gaming",
            "fitness",
            "教育",
            "portfolio",
            "dashboard",
        ],
        "style": [
            "style",
            "风格",
            "minimal",
            "glassmorphism",
            "neumorphism",
            "dark mode",
            "flat",
            "aurora",
        ],
        "typography": ["font", "字体", "typography", "字体搭配", "serif", "sans"],
        "landing": ["landing", "着陆页", "homepage", "hero", "cta", "conversion"],
        "ux": [
            "ux",
            "accessibility",
            "无障碍",
            "wcag",
            "touch",
            "animation",
            "keyboard",
        ],
        "techstack": [
            "react",
            "vue",
            "nextjs",
            "flutter",
            "swiftui",
            "tailwind",
            "技术栈",
            "框架",
            "stack",
            "tailwind",
            "angular",
            "svelte",
            "astro",
        ],
        "ui-reasoning": [
            "推理",
            "reasoning",
            "决策",
            "decision",
            "为什么",
            "why",
            "如何",
            "how",
            "设计逻辑",
            "设计决策",
        ],
        "chart": [
            "chart",
            "图表",
            "可视化",
            "visualization",
            "dashboard",
            "仪表盘",
            "graph",
            "plot",
            "数据分析",
        ],
    }

    scores = {
        domain: sum(1 for kw in keywords if kw in query_lower)
        for domain, keywords in domain_keywords.items()
    }
    best = max(scores, key=scores.get)
    return best if scores[best] > 0 else "style"


def search(query, domain=None, max_results=MAX_RESULTS):
    """Main search function."""
    if domain is None:
        domain = detect_domain(query)

    config = DOMAIN_CONFIG.get(domain, DOMAIN_CONFIG["style"])
    filepath = DATA_DIR / config["file"]

    if not filepath.exists():
        return {"error": f"File not found: {filepath}", "domain": domain}

    results = search_csv(
        filepath, config["search_cols"], config["output_cols"], query, max_results
    )

    return {
        "domain": domain,
        "query": query,
        "file": config["file"],
        "count": len(results),
        "results": results,
    }


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="AutoHarness UI Design Search")
    parser.add_argument("query", help="Search query")
    parser.add_argument(
        "--domain", "-d", choices=list(DOMAIN_CONFIG.keys()), help="Search domain"
    )
    parser.add_argument(
        "--max-results", "-n", type=int, default=MAX_RESULTS, help="Max results"
    )
    parser.add_argument("--json", action="store_true", help="Output as JSON")

    args = parser.parse_args()

    result = search(args.query, args.domain, args.max_results)

    if args.json:
        import json

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
