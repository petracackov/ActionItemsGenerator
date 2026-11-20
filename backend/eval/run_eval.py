"""Measure extraction quality against the sample notes, using the real Groq API.

Runs each sample note several times (the model isn't fully deterministic) and
reports which expected items were found, plus latency.

    cd backend
    uv run python eval/run_eval.py            # 3 runs per sample
    uv run python eval/run_eval.py --runs 5

Uses GROQ_API_KEY / GROQ_MODEL from .env. Each run is one real API call.
"""

import argparse
import json
import re
import sys
import tempfile
import time
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_DIR))

from app.config import load_settings  # noqa: E402
from app.errors import AppError  # noqa: E402
from app.extraction import Extractor, make_groq_client  # noqa: E402
from app.logger import setup_logging  # noqa: E402

ASSIGNMENT = BACKEND_DIR.parent / "Documentation" / "Assignment.md"
EXPECTED = Path(__file__).with_name("expected.json")


def load_samples() -> dict[str, str]:
    """Read the sample notes straight from the assignment, so they can't drift."""
    text = ASSIGNMENT.read_text()
    matches = re.findall(r"### (Sample \d+)[^\n]*\n\n```\n(.*?)```", text, re.S)
    return {name: body for name, body in matches}


def found(keywords: list[str], item_texts: list[str]) -> bool:
    return any(k.lower() in t.lower() for t in item_texts for k in keywords)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=3)
    args = parser.parse_args()

    settings = load_settings()
    setup_logging(Path(tempfile.mkdtemp(prefix="eval-logs-")))  # keep eval out of logs/
    extractor = Extractor(make_groq_client(settings.groq_api_key), settings.groq_model)
    samples = load_samples()
    expected = json.loads(EXPECTED.read_text())["samples"]

    print(f"Model: {settings.groq_model} | runs per sample: {args.runs}\n")
    total_hits = total_required = 0
    durations: list[float] = []

    for name, spec in expected.items():
        required, optional = spec["required"], spec["optional"]
        hit_counts = {label: 0 for label in {**required, **optional}}
        item_counts: list[int] = []

        for run in range(args.runs):
            start = time.perf_counter()
            try:
                result = extractor.extract(samples[name], request_id=f"eval-{name}-{run}")
            except AppError as error:
                print(f"  {name} run {run + 1}: ERROR {error.code}")
                continue
            durations.append(time.perf_counter() - start)
            texts = [item.text for item in result.action_items]
            item_counts.append(len(texts))
            for label, keywords in {**required, **optional}.items():
                hit_counts[label] += found(keywords, texts)

        print(f"{name}  (items per run: {item_counts})")
        for label in required:
            mark = "OK " if hit_counts[label] == args.runs else "-- "
            print(f"  {mark} {hit_counts[label]}/{args.runs}  {label}")
            total_hits += hit_counts[label]
            total_required += args.runs
        for label in optional:
            print(f"  (opt) {hit_counts[label]}/{args.runs}  {label}")
        print()

    recall = total_hits / total_required if total_required else 0
    print(f"Required items found: {total_hits}/{total_required} ({recall:.0%})")
    if durations:
        print(f"Latency: avg {sum(durations) / len(durations):.2f}s, max {max(durations):.2f}s (goal < 2s)")


if __name__ == "__main__":
    main()
