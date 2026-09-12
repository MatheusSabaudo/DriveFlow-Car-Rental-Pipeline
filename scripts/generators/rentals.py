"""Rental generator — the core transactional fact.

Depends on the three dimensions (vehicles, customers, branches) for valid
foreign keys. Injects most of the pipeline's intentional messiness:
  - open rentals   → null `end_ts`
  - future dates   → `start_ts` pushed past the run day
  - inconsistent   → `end_ts` before `start_ts`
  - duplicates     → the same rental row emitted twice (same `rental_id`)
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, time, timedelta, timezone
from typing import Optional

from .base import BaseGenerator
from .branches import Branch
from .customers import Customer
from .vehicles import Vehicle


@dataclass
class Rental:
    rental_id: str
    vehicle_id: str
    customer_id: str
    pickup_branch_id: str
    return_branch_id: str
    start_ts: datetime
    end_ts: Optional[datetime]  # None = open rental
    daily_rate_eur: float
    status: str
    created_at: datetime
    updated_at: datetime


class RentalGenerator(BaseGenerator):
    def __init__(
        self,
        run_date,
        fake,
        vehicles: list[Vehicle],
        customers: list[Customer],
        branches: list[Branch],
        count: int = 500,
        open_rate: float = 0.08,
        future_rate: float = 0.03,
        bad_date_rate: float = 0.02,
        duplicate_rate: float = 0.02,
    ) -> None:
        super().__init__(run_date, fake)
        self.vehicles = vehicles
        self.customers = customers
        self.branches = branches
        self.count = count
        self.open_rate = open_rate
        self.future_rate = future_rate
        self.bad_date_rate = bad_date_rate
        self.duplicate_rate = duplicate_rate

    def generate(self) -> list[Rental]:
        created, updated = self.stamps
        base_day = datetime.combine(self.run_date, time.min, tzinfo=timezone.utc)
        rows: list[Rental] = []

        for r in range(self.count):
            start = base_day + timedelta(
                hours=self.rng.randint(0, 23), minutes=self.rng.randint(0, 59)
            )
            if self.chance(self.future_rate):
                # INTENTIONAL: start date in the future
                start = start + timedelta(days=self.rng.randint(5, 60))

            if self.chance(self.open_rate):
                end: Optional[datetime] = None  # INTENTIONAL: open rental
            else:
                end = start + timedelta(days=self.rng.randint(1, 14))
                if self.chance(self.bad_date_rate):
                    # INTENTIONAL: end before start
                    end = start - timedelta(days=self.rng.randint(1, 3))

            rental = Rental(
                rental_id=f"R{self.run_date:%Y%m%d}_{r:05d}",
                vehicle_id=self.rng.choice(self.vehicles).vehicle_id,
                customer_id=self.rng.choice(self.customers).customer_id,
                pickup_branch_id=self.rng.choice(self.branches).branch_id,
                return_branch_id=self.rng.choice(self.branches).branch_id,
                start_ts=start,
                end_ts=end,
                daily_rate_eur=round(self.rng.uniform(25, 220), 2),
                status="open" if end is None else "closed",
                created_at=created,
                updated_at=updated,
            )
            rows.append(rental)
            if self.chance(self.duplicate_rate):
                # INTENTIONAL: duplicate rental (same business key) for the deduper
                rows.append(rental)

        return rows
