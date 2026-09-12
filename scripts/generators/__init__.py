"""DriveFlow synthetic-data generators.

One module per record type. Every generator is pure (returns dataclass rows,
no DB writes); the `generate` DAG in `jobs/generate.py` wires them together in
dependency order and owns persistence + the watermark.
"""

from .base import BaseGenerator, build_faker, rows_to_dicts
from .branches import Branch, BranchGenerator
from .customers import Customer, CustomerGenerator
from .odometer import OdometerGenerator, OdometerReading
from .rentals import Rental, RentalGenerator
from .vehicles import Vehicle, VehicleGenerator

__all__ = [
    "BaseGenerator",
    "build_faker",
    "rows_to_dicts",
    "Branch",
    "BranchGenerator",
    "Vehicle",
    "VehicleGenerator",
    "Customer",
    "CustomerGenerator",
    "Rental",
    "RentalGenerator",
    "OdometerReading",
    "OdometerGenerator",
]
