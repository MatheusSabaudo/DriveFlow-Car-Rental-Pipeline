"""Shared plumbing for every entity generator.

Every generator subclasses `BaseGenerator`, implements `generate()`, and returns
a list of dataclass rows. Generators are **pure**: they never touch the database.
Persistence, ordering and the `ops.watermark` advance are the generate job's
responsibility (the `generate` DAG in `jobs/generate.py`). Keeping generation
side-effect-free is what makes the
whole thing trivially unit-testable.
"""

from __future__ import annotations

import random
from dataclasses import asdict
from datetime import date, datetime, timezone
from typing import Any

from faker import Faker
from faker_vehicle import VehicleProvider


def build_faker(seed: int | None = None) -> Faker:
    """Return a Faker instance with the vehicle provider registered.

    When `seed` is given, both Faker and its shared RNG (`fake.random`) are
    seeded, so a given `run_date` always produces the same "business day".
    """
    fake = Faker()
    fake.add_provider(VehicleProvider)
    if seed is not None:
        Faker.seed(seed)
        fake.seed_instance(seed)
    return fake


class BaseGenerator:
    """Common state + helpers shared by all entity generators."""

    def __init__(self, run_date: date, fake: Faker) -> None:
        self.run_date = run_date
        self.fake = fake
        # one shared RNG so the whole run is reproducible from a single seed
        self.rng: random.Random = fake.random
        # a single wall-clock stamp per run → created_at == updated_at at birth
        self._ts = datetime.now(timezone.utc)

    # -- helpers -------------------------------------------------------------
    def chance(self, prob: float) -> bool:
        """True with probability `prob`; used to inject intentional messiness."""
        return self.rng.random() < prob

    @property
    def stamps(self) -> tuple[datetime, datetime]:
        """(created_at, updated_at) for a freshly generated row."""
        return self._ts, self._ts

    def generate(self) -> list[Any]:  # pragma: no cover - interface
        raise NotImplementedError


def rows_to_dicts(rows: list[Any]) -> list[dict]:
    """Convert a list of dataclass rows to plain dicts (for Parquet / psycopg2)."""
    return [asdict(r) for r in rows]
