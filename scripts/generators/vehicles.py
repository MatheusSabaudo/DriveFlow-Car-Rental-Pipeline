"""Vehicle generator — the fleet dimension.

Uses the `faker_vehicle` provider for coherent make/model/year triples, while
`category` and `fuel_type` come from the DriveFlow domain enums so they match
`include/sql/ddl_ops.sql`.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from .base import BaseGenerator

CATEGORIES = ["economy", "SUV", "luxury", "van"]
FUELS = ["petrol", "diesel", "hybrid", "electric"]
STATUSES = ["available", "rented", "maintenance"]

# Real VINs are 17 chars and exclude I, O and Q to avoid digit confusion.
_VIN_ALPHABET = "ABCDEFGHJKLMNPRSTUVWXYZ0123456789"


@dataclass
class Vehicle:
    vehicle_id: str
    vin: str
    make: str
    model: str
    year: int
    category: str
    fuel_type: str
    acquisition_date: str  # ISO date (YYYY-MM-DD)
    status: str
    created_at: datetime
    updated_at: datetime


class VehicleGenerator(BaseGenerator):
    def __init__(self, *args, count: int = 200, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.count = count

    def _vin(self) -> str:
        return "".join(self.rng.choice(_VIN_ALPHABET) for _ in range(17))

    def generate(self) -> list[Vehicle]:
        created, updated = self.stamps
        rows: list[Vehicle] = []
        for i in range(self.count):
            obj = self.fake.vehicle_object()  # {"Make","Model","Year","Category"}
            rows.append(
                Vehicle(
                    vehicle_id=f"V{i:05d}",
                    vin=self._vin(),
                    make=obj["Make"],
                    model=obj["Model"],
                    year=int(obj["Year"]),
                    category=self.rng.choice(CATEGORIES),
                    fuel_type=self.rng.choice(FUELS),
                    acquisition_date=self.fake.date_between("-6y", "today").isoformat(),
                    status=self.rng.choice(STATUSES),
                    created_at=created,
                    updated_at=updated,
                )
            )
        return rows
