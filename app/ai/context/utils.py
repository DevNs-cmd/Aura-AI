from __future__ import annotations

import inspect
from typing import Any


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def to_dict_list(value: Any) -> list[dict[str, Any]]:
    if value is None:
        return []
    if isinstance(value, list):
        return [item if isinstance(item, dict) else {"value": item} for item in value]
    if isinstance(value, dict):
        for key in ("items", "memories", "entries", "documents", "messages"):
            nested = value.get(key)
            if isinstance(nested, list):
                return [
                    item if isinstance(item, dict) else {"value": item}
                    for item in nested
                ]
        return [value]
    return [{"value": value}]


def build_call_kwargs(callable_obj: Any, values: dict[str, Any]) -> dict[str, Any]:
    """Best-effort kwargs projection using signature introspection.

    Context orchestration must not dynamically import services, but it can
    adapt to different service callable signatures.
    """

    try:
        signature = inspect.signature(callable_obj)
    except (TypeError, ValueError):
        return {}

    kwargs: dict[str, Any] = {}
    for name, parameter in signature.parameters.items():
        if parameter.kind not in (
            inspect.Parameter.POSITIONAL_OR_KEYWORD,
            inspect.Parameter.KEYWORD_ONLY,
        ):
            continue
        if name in values:
            kwargs[name] = values[name]
    return kwargs

