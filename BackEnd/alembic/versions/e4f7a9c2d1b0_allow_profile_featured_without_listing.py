"""Allow profile featured promotions without listing relation.

Revision ID: e4f7a9c2d1b0
Revises: c1a2b3d4e5f6
Create Date: 2026-03-29

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "e4f7a9c2d1b0"
down_revision: Union[str, None] = "c1a2b3d4e5f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column("promotions", "listing_id", existing_type=sa.BigInteger(), nullable=True)


def downgrade() -> None:
    op.alter_column("promotions", "listing_id", existing_type=sa.BigInteger(), nullable=False)
