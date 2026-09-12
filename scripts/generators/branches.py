"""Branch generator — a small, stable dimension (rental locations).

Branches are clean by design: the intentional messiness lives in the
transactional entities (rentals, odometer) and in customer emails.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from .base import BaseGenerator


@dataclass
class Branch:
    branch_id: str
    city: str
    country: str
    latitude: float
    longitude: float
    created_at: datetime
    updated_at: datetime


class BranchGenerator(BaseGenerator):
    def __init__(self, *args, count: int = 25, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.count = count

    def generate(self) -> list[Branch]:
        created, updated = self.stamps
        rows: list[Branch] = []
        for i in range(1, self.count + 1):
            rows.append(
                Branch(
                    branch_id=f"B{i:02d}",
                    city=self.fake.city(),
                    country=self.fake.country(),
                    latitude=float(self.fake.latitude()),
                    longitude=float(self.fake.longitude()),
                    created_at=created,
                    updated_at=updated,
                )
            )
        return rows
