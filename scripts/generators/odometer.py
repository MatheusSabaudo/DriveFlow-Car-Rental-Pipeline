"""Odometer generator — telemetry readings attached to rentals.

Per-vehicle mileage is tracked so readings are naturally monotonic-increasing
in `ts` order (what a real odometer does) — *except* where we deliberately
inject bad values. That way the cleaner's "drop negatives / enforce increasing"
rule has genuine violations to catch without over-dropping legitimate rows.

Intentional messiness:
  - negative readings
  - decreasing readings (goes backwards vs the vehicle's running total)
  - out-of-range fuel level (e.g. 150%)
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta

from .base import BaseGenerator
from .rentals import Rental


@dataclass
class OdometerReading:
    reading_id: str
    vehicle_id: str
    rental_id: str
    ts: datetime
    odometer_reading_km: int
    fuel_level_percentage: int
    created_at: datetime
    updated_at: datetime


class OdometerGenerator(BaseGenerator):
    def __init__(
        self,
        run_date,
        fake,
        rentals: list[Rental],
        max_readings: int = 5,
        negative_rate: float = 0.03,
        decreasing_rate: float = 0.02,
        bad_fuel_rate: float = 0.04,
    ) -> None:
        super().__init__(run_date, fake)
        self.rentals = rentals
        self.max_readings = max_readings
        self.negative_rate = negative_rate
        self.decreasing_rate = decreasing_rate
        self.bad_fuel_rate = bad_fuel_rate

    def _unique_rentals_in_time_order(self) -> list[Rental]:
        seen: dict[str, Rental] = {}
        for r in self.rentals:
            seen.setdefault(r.rental_id, r)  # drop duplicate rentals for telemetry
        return sorted(seen.values(), key=lambda r: r.start_ts)

    def generate(self) -> list[OdometerReading]:
        created, updated = self.stamps
        vehicle_km: dict[str, int] = {}
        rows: list[OdometerReading] = []

        for rental in self._unique_rentals_in_time_order():
            km = vehicle_km.get(rental.vehicle_id, self.rng.randint(10_000, 180_000))
            n = self.rng.randint(1, self.max_readings)

            for h in range(n):
                km += self.rng.randint(5, 60)  # the true running total only goes up

                if self.chance(self.negative_rate):
                    value = -abs(km)  # INTENTIONAL: negative reading
                elif self.chance(self.decreasing_rate):
                    value = km - self.rng.randint(500, 5_000)  # INTENTIONAL: goes backwards
                else:
                    value = km

                fuel = 150 if self.chance(self.bad_fuel_rate) else self.rng.randint(0, 100)

                rows.append(
                    OdometerReading(
                        reading_id=f"{rental.rental_id}_{h}",
                        vehicle_id=rental.vehicle_id,
                        rental_id=rental.rental_id,
                        ts=rental.start_ts + timedelta(hours=h),
                        odometer_reading_km=value,
                        fuel_level_percentage=fuel,
                        created_at=created,
                        updated_at=updated,
                    )
                )

            vehicle_km[rental.vehicle_id] = km

        return rows
