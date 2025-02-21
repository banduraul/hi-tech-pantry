from dataclasses import dataclass
from typing import Optional, Dict
from datetime import datetime

@dataclass
class ProductInfo:
    eancode: str
    name: str
    finishedEditing: bool = False
    isExpired: bool = False
    quantity: int = 1
    expiryDate: Optional[datetime] = None

    def toFirestore(self) -> Dict[str, any]:
        return {
            'eancode': self.eancode,
            'name': self.name,
            'finishedEditing': self.finishedEditing,
            'isExpired': self.isExpired,
            'quantity': self.quantity,
            'expiryDate': self.expiryDate
        }