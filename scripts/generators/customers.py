"""Customer generator — the customer dimension.

Injects one kind of intentional messiness: a small share of malformed emails,
which the `clean.py` stage validates downstream.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from .base import BaseGenerator


@dataclass
class Customer:
    customer_id: str
    first_name: str
    last_name: str
    email: str
    license_number: str
    country: str
    signup_date: str  # ISO date (YYYY-MM-DD)
    created_at: datetime
    updated_at: datetime


class CustomerGenerator(BaseGenerator):
    def __init__(self, *args, count: int = 800, malformed_email_rate: float = 0.05, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.count = count
        self.malformed_email_rate = malformed_email_rate

    def _email(self, first: str, last: str) -> str:
        if self.chance(self.malformed_email_rate):
            # INTENTIONAL: malformed email (missing @/domain) for the cleaner to catch
            return self.rng.choice([
                "not-an-email",
                f"{first.lower()}.{last.lower()}",
                f"{first.lower()}@",
            ])
        return f"{first.lower()}.{last.lower()}@{self.fake.free_email_domain()}"

    def generate(self) -> list[Customer]:
        created, updated = self.stamps
        rows: list[Customer] = []
        for i in range(self.count):
            first = self.fake.first_name()
            last = self.fake.last_name()
            rows.append(
                Customer(
                    customer_id=f"C{i:05d}",
                    first_name=first,
                    last_name=last,
                    email=self._email(first, last),
                    license_number=self.fake.bothify("??######").upper(),
                    country=self.fake.country(),
                    signup_date=self.fake.date_between("-4y", "today").isoformat(),
                    created_at=created,
                    updated_at=updated,
                )
            )
        return rows
