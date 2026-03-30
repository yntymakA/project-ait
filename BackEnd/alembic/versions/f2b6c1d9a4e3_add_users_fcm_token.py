"""Add fcm_token to users.

Revision ID: f2b6c1d9a4e3
Revises: e4f7a9c2d1b0
Create Date: 2026-03-30

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "f2b6c1d9a4e3"
down_revision: Union[str, None] = "e4f7a9c2d1b0"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("fcm_token", sa.String(length=255), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "fcm_token")
