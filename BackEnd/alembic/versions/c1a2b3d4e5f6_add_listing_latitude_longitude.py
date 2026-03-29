"""Add latitude and longitude to listings for map / OSM placement.

Revision ID: c1a2b3d4e5f6
Revises: ab12cd34ef56
Create Date: 2026-03-29

"""
from alembic import op
import sqlalchemy as sa

revision = "c1a2b3d4e5f6"
down_revision = "ab12cd34ef56"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "listings",
        sa.Column("latitude", sa.Numeric(precision=10, scale=8), nullable=True),
    )
    op.add_column(
        "listings",
        sa.Column("longitude", sa.Numeric(precision=11, scale=8), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("listings", "longitude")
    op.drop_column("listings", "latitude")
