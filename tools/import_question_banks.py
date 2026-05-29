from __future__ import annotations

import argparse
import ast
import json
import re
from collections import OrderedDict
from pathlib import Path
from typing import Any


SUPERSCRIPT_DIGITS = str.maketrans("⁰¹²³⁴⁵⁶⁷⁸⁹", "0123456789")
SECTION_PREFIX_RE = re.compile(r"^[^A-Za-zÅÄÖåäö0-9?]+\s*")
SECTION_COUNT_RE = re.compile(r"\((\d+)\s+uppgifter\)", re.IGNORECASE)
GRADE_HEADER_RE = re.compile(
    r"(?:EXTREM PLUS FULLTEXT\s+[–-]\s+)?ÅK\s+(\d+)\b",
    re.IGNORECASE,
)


def strip_prefix(text: str) -> str:
    return SECTION_PREFIX_RE.sub("", text).strip()


def slugify_swedish(text: str) -> str:
    replacements = {
        "å": "a",
        "ä": "a",
        "ö": "o",
        "é": "e",
        "Å": "a",
        "Ä": "a",
        "Ö": "o",
        "É": "e",
    }
    for source, target in replacements.items():
        text = text.replace(source, target)
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def section_id(label: str) -> str:
    clean = strip_prefix(label)
    clean = SECTION_COUNT_RE.sub("", clean).strip()
    clean = re.sub(r"\s*\(.*$", "", clean).strip()

    known = {
        "addition med tiotalsövergång": "addition_with_tens_transition",
        "addition med tiotalsovergang": "addition_with_tens_transition",
        "addition av större tal": "addition_large_numbers",
        "addition av storre tal": "addition_large_numbers",
        "addition": "addition",
        "subtraktion av större tal": "subtraction_large_numbers",
        "subtraktion av storre tal": "subtraction_large_numbers",
        "subtraktion": "subtraction",
        "multiplikation": "multiplication",
        "division": "division",
        "saknat tal": "missing_number",
        "tiokompisar": "number_bonds_to_10",
        "jämföra tal": "compare_numbers",
        "jamfora tal": "compare_numbers",
        "textproblem": "word_problems",
        "statistik": "statistics",
        "negativa tal": "negative_numbers",
        "medelvärde": "mean",
        "medelvarde": "mean",
        "diagramtolkning": "diagram_interpretation",
        "flerstegsproblem": "multi_step_word_problems",
        "procentuell förändring": "percentage_change",
        "procentuell forandring": "percentage_change",
        "prioriteringsregler": "order_of_operations",
        "ekvationer": "equations",
        "förenkla uttryck": "simplify_expressions",
        "forenkla uttryck": "simplify_expressions",
        "procent på procent": "compound_percent_change",
        "procent pa procent": "compound_percent_change",
        "procent": "percentage",
        "potenser": "powers",
        "proportionalitet": "proportionality",
        "linjära samband": "linear_relationships",
        "linjara samband": "linear_relationships",
        "funktioner": "functions",
        "geometri": "geometry",
        "sannolikhet": "probability",
    }
    return known.get(clean.lower(), slugify_swedish(clean))


def stage_for_grade(grade: int) -> str:
    if grade <= 3:
        return "1-3"
    if grade <= 6:
        return "4-6"
    return "7-9"


def default_number_range(grade: int) -> dict[str, int]:
    ranges = {
        1: (0, 20),
        2: (0, 100),
        3: (0, 1000),
        4: (0, 10000),
        5: (0, 100000),
        6: (0, 100000),
        7: (0, 1000),
        8: (0, 1000),
        9: (0, 1000),
    }
    low, high = ranges[grade]
    return {"min": low, "max": high}


def blank_bank(grade: int, source_file: Path) -> OrderedDict[str, Any]:
    return OrderedDict(
        [
            ("schemaVersion", 1),
            ("updated", "2026-05-26"),
            (
                "purpose",
                f"Structured grade {grade} seed bank for manual review, example prompts and future generator audits.",
            ),
            ("grade", grade),
            ("stage", stage_for_grade(grade)),
            ("language", "sv-SE"),
            ("sourceType", "manual_seed_bank"),
            ("sourceFile", source_file.as_posix()),
            ("notCanonicalFacit", True),
            (
                "alignment",
                OrderedDict(
                    [
                        ("numberRange", default_number_range(grade)),
                        ("operations", []),
                        ("centralConcepts", []),
                        ("strategies", []),
                        ("commonMisconceptions", []),
                    ]
                ),
            ),
            (
                "qualityNotes",
                [
                    "Source prompts were normalized from Uppgitstabell.txt into structured JSON records."
                ],
            ),
            (
                "coverage",
                OrderedDict(
                    [
                        ("questionCount", 0),
                        ("headlineQuestionCount", None),
                        ("declaredQuestionCount", 0),
                        ("countsBySection", OrderedDict()),
                        ("declaredCountsBySection", OrderedDict()),
                        ("undercoveredConcepts", []),
                        ("requiresSupportingContext", []),
                    ]
                ),
            ),
            ("sections", []),
        ]
    )


def unique_append(values: list[Any], value: Any) -> None:
    if value and value not in values:
        values.append(value)


def normalize_number(text: str) -> str:
    text = text.replace("−", "-")
    text = text.replace("–", "-")
    text = text.replace(" ", "")
    text = text.replace(" ", "")
    return text


def parse_int(text: str) -> int:
    return int(normalize_number(text))


def safe_eval_numeric(expr: str) -> int | float | None:
    expr = normalize_number(expr)
    expr = expr.replace("×", "*").replace("÷", "/")
    expr = re.sub(
        r"(-?\d+)([⁰¹²³⁴⁵⁶⁷⁸⁹]+)",
        lambda match: f"({match.group(1)}**{match.group(2).translate(SUPERSCRIPT_DIGITS)})",
        expr,
    )
    if not re.fullmatch(r"[0-9+\-*/().]+", expr):
        return None

    allowed_nodes = (
        ast.Expression,
        ast.BinOp,
        ast.UnaryOp,
        ast.Constant,
        ast.Add,
        ast.Sub,
        ast.Mult,
        ast.Div,
        ast.Pow,
        ast.USub,
        ast.UAdd,
    )
    tree = ast.parse(expr, mode="eval")
    if not all(isinstance(node, allowed_nodes) for node in ast.walk(tree)):
        return None
    value = eval(compile(tree, "<question-bank>", "eval"), {"__builtins__": {}}, {})
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value


def infer_answer(prompt: str, section: str) -> tuple[Any | None, str | None]:
    normalized = prompt.strip("“”\"")
    plain = normalize_number(normalized)

    missing_patterns = [
        (r"^\?\+(\-?\d+)=(\-?\d+)$", lambda a, b: b - a),
        (r"^(\-?\d+)\+\?=(\-?\d+)$", lambda a, b: b - a),
        (r"^(\-?\d+)-\?=(\-?\d+)$", lambda a, b: a - b),
        (r"^\?-(\-?\d+)=(\-?\d+)$", lambda a, b: a + b),
        (r"^(\-?\d+)×\?=(\-?\d+)$", lambda a, b: b / a),
        (r"^\?×(\-?\d+)=(\-?\d+)$", lambda a, b: b / a),
        (r"^\?÷(\-?\d+)=(\-?\d+)$", lambda a, b: a * b),
    ]
    for pattern, solver in missing_patterns:
        match = re.fullmatch(pattern, plain)
        if match:
            answer = solver(parse_int(match.group(1)), parse_int(match.group(2)))
            if isinstance(answer, float) and answer.is_integer():
                return int(answer), None
            return answer, None

    mean_match = re.match(r"^Medel av (.+)$", normalized, re.IGNORECASE)
    if mean_match:
        numbers = [parse_int(value) for value in re.findall(r"-?\d+", mean_match.group(1))]
        if numbers:
            answer = sum(numbers) / len(numbers)
            return int(answer) if answer.is_integer() else answer, None

    percent_match = re.fullmatch(r"(\d+)% av (\d+)", normalized)
    if percent_match:
        percent = parse_int(percent_match.group(1))
        base = parse_int(percent_match.group(2))
        answer = base * percent / 100
        return int(answer) if answer.is_integer() else answer, None

    if re.fullmatch(r"[\d\s ⁰¹²³⁴⁵⁶⁷⁸⁹+\-−×÷*/().]+", normalized):
        return safe_eval_numeric(normalized), None

    if section in {"percentage_change", "compound_percent_change"}:
        return None, "Requires explicit policy for whether answer is final value, difference or percentage change."
    if section in {"diagram_interpretation", "functions", "linear_relationships", "geometry", "probability"}:
        return None, "Requires supporting visual data, formula policy, rounding policy or exact outcome space."
    if section == "multi_step_word_problems":
        return None, "Requires completed word-problem text and explicit answer target."
    return None, None


def response_type(section: str, prompt: str) -> str:
    if section in {"addition", "addition_large_numbers", "addition_with_tens_transition", "subtraction", "subtraction_large_numbers", "multiplication", "division", "negative_numbers", "powers", "percentage", "mean", "missing_number", "number_bonds_to_10", "order_of_operations", "equations"}:
        return "numeric"
    if section in {"compare_numbers", "statistics", "diagram_interpretation", "functions", "linear_relationships", "geometry", "probability", "multi_step_word_problems", "proportionality"}:
        return "mixed"
    return "numeric_or_text"


def parse_source(source_file: Path, output_dir: Path) -> None:
    lines = source_file.read_text(encoding="utf-8-sig").replace("\r", "").split("\n")
    banks: dict[int, OrderedDict[str, Any]] = {}
    current_grade: int | None = None
    current_mode: str | None = None
    current_section: OrderedDict[str, Any] | None = None

    for raw_line in lines:
        line = raw_line.strip()
        if not line:
            continue

        grade_match = GRADE_HEADER_RE.search(line)
        if grade_match and ("uppgifter" in line.lower() or "fulltext" in line.lower()):
            grade = int(grade_match.group(1))
            banks.setdefault(grade, blank_bank(grade, source_file))
            headline_count_match = re.search(
                r"ÅK\s+\d+\s+[–-]\s+(\d+)\s+FULL",
                line,
                re.IGNORECASE,
            )
            if headline_count_match:
                banks[grade]["coverage"]["headlineQuestionCount"] = int(
                    headline_count_match.group(1)
                )
            current_grade = grade
            current_mode = None
            current_section = None
            continue

        if current_grade is None:
            continue

        if re.match(r"^🎉\s*ÅK\s+\d+\s+KLART\.?$", line, re.IGNORECASE):
            current_mode = None
            current_section = None
            continue

        if line.startswith("🎯"):
            current_mode = "number_range"
            continue
        if "Räknesätt" in line or "Raknesatt" in line:
            current_mode = "operations"
            continue
        if line.startswith("📘 Centrala"):
            current_mode = "concepts"
            continue
        if line.startswith("🧠"):
            current_mode = "strategies"
            continue
        if line.startswith("⚠️"):
            current_mode = "misconceptions"
            continue

        section_count_match = SECTION_COUNT_RE.search(line)
        if section_count_match and "ÅK" not in line:
            label = SECTION_COUNT_RE.sub("", strip_prefix(line)).strip()
            section_key = section_id(line)
            declared_count = int(section_count_match.group(1))
            current_section = OrderedDict(
                [
                    ("id", section_key),
                    ("label", label),
                    ("questionCount", 0),
                    ("declaredQuestionCount", declared_count),
                    ("defaultResponseType", response_type(section_key, "")),
                    ("defaultConceptTags", []),
                    ("defaultStrategyTags", []),
                    ("sourceNotes", []),
                    ("questions", []),
                ]
            )
            banks[current_grade]["sections"].append(current_section)
            current_mode = "section"
            continue

        bank = banks[current_grade]
        alignment = bank["alignment"]

        if current_mode == "number_range":
            range_match = re.search(r"(\d+)\s*[–-]\s*([\d\s ]+)(\+)?", line)
            if range_match:
                alignment["numberRange"] = {
                    "min": parse_int(range_match.group(1)),
                    "max": parse_int(range_match.group(2)),
                }
                if range_match.group(3):
                    alignment["numberRange"]["openEnded"] = True
            continue

        if current_mode == "operations":
            if "Alla fyra" in line:
                for operation in ["addition", "subtraction", "multiplication", "division"]:
                    unique_append(alignment["operations"], operation)
            for label, operation in [
                ("Addition", "addition"),
                ("subtraktion", "subtraction"),
                ("multiplikation", "multiplication"),
                ("division", "division"),
            ]:
                if label.lower() in line.lower():
                    unique_append(alignment["operations"], operation)
            if "algebra" in line.lower():
                unique_append(alignment["operations"], "algebraic_reasoning")
            if "funktion" in line.lower():
                unique_append(alignment["operations"], "functional_reasoning")
            if "geometri" in line.lower():
                unique_append(alignment["operations"], "geometry_reasoning")
            if "sannolikhet" in line.lower():
                unique_append(alignment["operations"], "probability_reasoning")
            continue

        if current_mode == "concepts":
            unique_append(alignment["centralConcepts"], slugify_swedish(line))
            continue
        if current_mode == "strategies":
            unique_append(alignment["strategies"], slugify_swedish(line))
            continue
        if current_mode == "misconceptions":
            unique_append(alignment["commonMisconceptions"], slugify_swedish(line))
            continue

        if current_mode == "section" and current_section is not None:
            if (
                line.startswith("(")
                and line.endswith(")")
                and re.search(r"[A-Za-zÅÄÖåäö]{2,}", line)
            ):
                current_section["sourceNotes"].append(line.strip("()"))
                continue

            question_index = len(current_section["questions"]) + 1
            key = current_section["id"]
            prompt = line.strip("“”\"")
            question = OrderedDict(
                [
                    ("id", f"g{current_grade}_{key}_{question_index:03d}"),
                    ("prompt", prompt),
                    ("responseType", response_type(key, prompt)),
                ]
            )
            answer, answer_note = infer_answer(prompt, key)
            if answer is not None:
                question["correctAnswer"] = answer
            if answer_note:
                question["answerPolicyNote"] = answer_note

            if re.search(
                r"diagram|graf|tabell|kortlek|påse|dag hade|rita graf|skala|utfallsrum",
                prompt,
                re.IGNORECASE,
            ):
                question["requiresSupportingContext"] = True
            if "…" in prompt or "..." in prompt:
                question["requiresCompletedPrompt"] = True

            current_section["questions"].append(question)

    for grade, bank in sorted(banks.items()):
        if not (1 <= grade <= 9):
            continue

        total = 0
        declared_total = 0
        requires_context: list[dict[str, Any]] = []
        for section in bank["sections"]:
            actual = len(section["questions"])
            declared = section["declaredQuestionCount"]
            section["questionCount"] = actual
            total += actual
            declared_total += declared
            bank["coverage"]["countsBySection"][section["id"]] = actual
            bank["coverage"]["declaredCountsBySection"][section["id"]] = declared
            context_count = sum(
                1
                for question in section["questions"]
                if question.get("requiresSupportingContext")
                or question.get("requiresCompletedPrompt")
                or question.get("answerPolicyNote")
            )
            if context_count:
                requires_context.append({"sectionId": section["id"], "questionCount": context_count})
            if not section["sourceNotes"]:
                del section["sourceNotes"]
            if actual != declared:
                bank["qualityNotes"].append(
                    f"Section {section['id']} declares {declared} questions in source text but {actual} prompts were found."
                )

        bank["coverage"]["questionCount"] = total
        bank["coverage"]["declaredQuestionCount"] = declared_total
        bank["coverage"]["requiresSupportingContext"] = requires_context
        headline_count = bank["coverage"].get("headlineQuestionCount")
        if headline_count is not None and headline_count != declared_total:
            bank["qualityNotes"].append(
                f"Grade headline declares {headline_count} questions but section headers sum to {declared_total}."
            )
        if requires_context:
            bank["qualityNotes"].append(
                "Some prompts require diagram, graph, table, card-deck, bag-model, scale context or an explicit answer policy."
            )

        if not bank["alignment"]["operations"]:
            for operation in ["addition", "subtraction", "multiplication", "division"]:
                if any(operation in section["id"] for section in bank["sections"]):
                    unique_append(bank["alignment"]["operations"], operation)

        output_file = output_dir / f"grade_{grade}_question_bank.json"
        output_file.write_text(
            json.dumps(bank, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Siffersafari question banks from Uppgitstabell.txt.")
    parser.add_argument("source", type=Path, help="Path to Uppgitstabell.txt")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("docs"),
        help="Directory where grade_<n>_question_bank.json files are written.",
    )
    args = parser.parse_args()
    parse_source(args.source, args.output_dir)


if __name__ == "__main__":
    main()