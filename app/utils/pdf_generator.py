from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime, timezone
from io import BytesIO
from pathlib import Path
from textwrap import wrap
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


PAGE_WIDTH = 612.0
PAGE_HEIGHT = 792.0
MARGIN = 54.0
TITLE_SIZE = 18
SECTION_SIZE = 12
BODY_SIZE = 10
LINE_GAP = 4.0


class PDFReportData(BaseModel):
    model_config = ConfigDict(extra="allow")

    report_type: Literal["chat", "journal", "weekly", "productivity", "monthly", "custom"] = "custom"
    title: str = Field(min_length=1)
    user: str | None = None
    date: datetime | date | str | None = None
    chat_summary: str | None = None
    conversation: list[dict[str, Any]] = Field(default_factory=list)
    journal_entries: list[dict[str, Any]] = Field(default_factory=list)
    ai_insights: list[str] = Field(default_factory=list)
    mood: str | None = None
    productivity: str | None = None
    goals: list[str] = Field(default_factory=list)
    tasks: list[str] = Field(default_factory=list)
    recommendations: list[str] = Field(default_factory=list)
    metadata: dict[str, Any] = Field(default_factory=dict)


@dataclass(frozen=True)
class _LineItem:
    text: str
    font_size: int
    bold: bool = False
    indent: float = 0.0
    blank: bool = False

    @property
    def leading(self) -> float:
        return (self.font_size * 1.35) if not self.blank else 10.0


def build_pdf_report(report: PDFReportData | dict[str, Any]) -> bytes:
    payload = PDFReportData.model_validate(report)
    lines = _build_lines(payload)
    pages = _paginate_lines(lines)
    return _assemble_pdf(pages)


def build_pdf_report_stream(report: PDFReportData | dict[str, Any]) -> BytesIO:
    return BytesIO(build_pdf_report(report))


def write_pdf_report(report: PDFReportData | dict[str, Any], output_path: str | Path) -> Path:
    destination = Path(output_path)
    destination.write_bytes(build_pdf_report(report))
    return destination


def build_pdf_filename(title: str, report_type: str, *, user: str | None = None, date_value: datetime | date | str | None = None) -> str:
    pieces = [title, report_type]
    if user:
        pieces.append(user)
    if date_value is not None:
        pieces.append(_format_date(date_value))
    slug = "-".join(_slugify(part) for part in pieces if _normalize_text(part))
    return f"{slug or 'aura-report'}.pdf"


def _build_lines(report: PDFReportData) -> list[_LineItem]:
    items: list[_LineItem] = []

    items.append(_LineItem(text=report.title, font_size=TITLE_SIZE, bold=True))
    items.append(_LineItem(text=f"Report type: {report.report_type.replace('_', ' ').title()}", font_size=BODY_SIZE))

    if user := _normalize_text(report.user):
        items.append(_LineItem(text=f"User: {user}", font_size=BODY_SIZE))
    if report.date is not None:
        items.append(_LineItem(text=f"Date: {_format_date(report.date)}", font_size=BODY_SIZE))

    items.append(_LineItem(text="", font_size=BODY_SIZE, blank=True))

    if summary := _normalize_text(report.chat_summary):
        items.extend(_section("Chat Summary", [summary]))
    if report.conversation:
        items.extend(_section("Conversation", _render_mapping_list(report.conversation, prefix_role=True)))
    if report.journal_entries:
        items.extend(_section("Journal Entries", _render_mapping_list(report.journal_entries)))
    if report.ai_insights:
        items.extend(_section("AI Insights", [str(item) for item in report.ai_insights if _normalize_text(item)]))
    if mood := _normalize_text(report.mood):
        items.extend(_section("Mood", [mood]))
    if productivity := _normalize_text(report.productivity):
        items.extend(_section("Productivity", [productivity]))
    if report.goals:
        items.extend(_section("Goals", [str(item) for item in report.goals if _normalize_text(item)]))
    if report.tasks:
        items.extend(_section("Tasks", [str(item) for item in report.tasks if _normalize_text(item)]))
    if report.recommendations:
        items.extend(_section("Recommendations", [str(item) for item in report.recommendations if _normalize_text(item)]))

    metadata = dict(report.metadata)
    extras = report.model_extra or {}
    for key, value in extras.items():
        if key not in metadata:
            metadata[key] = value
    if metadata:
        items.extend(_section("Metadata", [f"{key}: {value}" for key, value in metadata.items()]))

    return items


def _section(title: str, body_lines: list[str]) -> list[_LineItem]:
    lines = [_LineItem(text=title, font_size=SECTION_SIZE, bold=True)]
    for raw_line in body_lines:
        normalized = _normalize_text(raw_line)
        if not normalized:
            continue
        wrapped = _wrap_text(normalized, BODY_SIZE, indent=0.0)
        for index, line in enumerate(wrapped):
            prefix = "- " if index == 0 else "  "
            lines.append(_LineItem(text=f"{prefix}{line}", font_size=BODY_SIZE, indent=8.0))
    lines.append(_LineItem(text="", font_size=BODY_SIZE, blank=True))
    return lines


def _render_mapping_list(items: list[dict[str, Any]], *, prefix_role: bool = False) -> list[str]:
    rendered: list[str] = []
    for item in items:
        if not isinstance(item, dict):
            normalized = _normalize_text(item)
            if normalized:
                rendered.append(normalized)
            continue

        if prefix_role and (role := _normalize_text(item.get("role"))):
            content = _normalize_text(item.get("content")) or _normalize_text(item.get("text")) or _normalize_text(item.get("value"))
            if content:
                rendered.append(f"{role.title()}: {content}")
                continue

        rendered_text = ", ".join(
            f"{key}={_stringify_value(value)}"
            for key, value in item.items()
            if _normalize_text(value) is not None
        )
        if rendered_text:
            rendered.append(rendered_text)
    return rendered


def _stringify_value(value: Any) -> str:
    if isinstance(value, (datetime, date)):
        return _format_date(value)
    if isinstance(value, (list, tuple, set)):
        return "; ".join(_stringify_value(item) for item in value)
    if isinstance(value, dict):
        return ", ".join(f"{key}={_stringify_value(item)}" for key, item in value.items())
    normalized = _normalize_text(value)
    return normalized if normalized is not None else ""


def _wrap_text(text: str, font_size: int, *, indent: float) -> list[str]:
    usable_width = PAGE_WIDTH - (2 * MARGIN) - indent
    average_char_width = max(font_size * 0.52, 4.0)
    max_chars = max(20, int(usable_width / average_char_width))
    wrapped: list[str] = []
    for paragraph in text.splitlines() or [text]:
        chunks = wrap(paragraph, width=max_chars) or [""]
        wrapped.extend(chunks)
    return wrapped


def _paginate_lines(lines: list[_LineItem]) -> list[list[_LineItem]]:
    pages: list[list[_LineItem]] = []
    current: list[_LineItem] = []
    remaining = PAGE_HEIGHT - (2 * MARGIN)

    for line in lines:
        height = line.leading
        if current and height > remaining:
            pages.append(current)
            current = []
            remaining = PAGE_HEIGHT - (2 * MARGIN)
        current.append(line)
        remaining -= height

    if current:
        pages.append(current)
    return pages or [[_LineItem(text="Empty report", font_size=BODY_SIZE)]]


def _assemble_pdf(pages: list[list[_LineItem]]) -> bytes:
    num_pages = len(pages)
    font_regular_id = 1
    font_bold_id = 2
    content_start_id = 3
    page_start_id = content_start_id + num_pages
    pages_tree_id = page_start_id + num_pages
    catalog_id = pages_tree_id + 1

    objects: list[bytes] = []
    objects.append(_pdf_object(font_regular_id, b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"))
    objects.append(_pdf_object(font_bold_id, b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>"))

    content_ids = list(range(content_start_id, content_start_id + num_pages))
    page_ids = list(range(page_start_id, page_start_id + num_pages))

    for content_id, page_lines in zip(content_ids, pages, strict=True):
        stream = _build_page_stream(page_lines)
        objects.append(_pdf_stream_object(content_id, stream))

    for page_id, content_id in zip(page_ids, content_ids, strict=True):
        page_object = (
            f"<< /Type /Page /Parent {pages_tree_id} 0 R /MediaBox [0 0 {PAGE_WIDTH:.0f} {PAGE_HEIGHT:.0f}] "
            f"/Resources << /Font << /F1 {font_regular_id} 0 R /F2 {font_bold_id} 0 R >> >> "
            f"/Contents {content_id} 0 R >>"
        ).encode("latin-1")
        objects.append(_pdf_object(page_id, page_object))

    kids = " ".join(f"{page_id} 0 R" for page_id in page_ids)
    objects.append(_pdf_object(pages_tree_id, f"<< /Type /Pages /Kids [{kids}] /Count {num_pages} >>".encode("latin-1")))
    objects.append(_pdf_object(catalog_id, f"<< /Type /Catalog /Pages {pages_tree_id} 0 R >>".encode("latin-1")))

    pdf = bytearray()
    pdf.extend(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")

    offsets: list[int] = [0]
    for obj in objects:
        offsets.append(len(pdf))
        pdf.extend(obj)

    xref_position = len(pdf)
    pdf.extend(f"xref\n0 {len(objects) + 1}\n".encode("latin-1"))
    pdf.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        pdf.extend(f"{offset:010d} 00000 n \n".encode("latin-1"))
    pdf.extend(
        (
            f"trailer\n<< /Size {len(objects) + 1} /Root {catalog_id} 0 R >>\n"
            f"startxref\n{xref_position}\n%%EOF\n"
        ).encode("latin-1")
    )
    return bytes(pdf)


def _build_page_stream(lines: list[_LineItem]) -> bytes:
    commands: list[str] = ["BT"]
    y = PAGE_HEIGHT - MARGIN
    current_font: tuple[str, int] | None = None

    for line in lines:
        if line.blank:
            y -= line.leading
            continue

        font_name = "/F2" if line.bold else "/F1"
        if current_font != (font_name, line.font_size):
            commands.append(f"{font_name} {line.font_size} Tf")
            current_font = (font_name, line.font_size)

        for wrapped_line in _wrap_text(line.text, line.font_size, indent=line.indent):
            text = _escape_pdf_text(wrapped_line)
            commands.append(f"1 0 0 1 {MARGIN + line.indent:.2f} {y:.2f} Tm")
            commands.append(f"({text}) Tj")
            y -= line.leading

    commands.append("ET")
    return "\n".join(commands).encode("latin-1", "replace")


def _pdf_object(object_id: int, body: bytes) -> bytes:
    return f"{object_id} 0 obj\n".encode("latin-1") + body + b"\nendobj\n"


def _pdf_stream_object(object_id: int, stream: bytes) -> bytes:
    return (
        f"{object_id} 0 obj\n<< /Length {len(stream)} >>\nstream\n".encode("latin-1")
        + stream
        + b"\nendstream\nendobj\n"
    )


def _escape_pdf_text(text: str) -> str:
    normalized = text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")
    return normalized.encode("latin-1", "replace").decode("latin-1")


def _normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def _format_date(value: datetime | date | str) -> str:
    if isinstance(value, datetime):
        normalized = value.astimezone(timezone.utc) if value.tzinfo else value
        return normalized.strftime("%Y-%m-%d %H:%M UTC" if normalized.tzinfo else "%Y-%m-%d %H:%M")
    if isinstance(value, date):
        return value.isoformat()
    return _normalize_text(value) or ""


def _slugify(value: str) -> str:
    normalized = value.lower().strip()
    pieces: list[str] = []
    previous_hyphen = False
    for char in normalized:
        if char.isalnum():
            pieces.append(char)
            previous_hyphen = False
        else:
            if not previous_hyphen:
                pieces.append("-")
                previous_hyphen = True
    slug = "".join(pieces).strip("-")
    return slug or "report"
