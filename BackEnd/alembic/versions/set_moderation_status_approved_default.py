"""
Revision ID: set_moderation_status_approved_default
Revises: 8a938cc8765f_update_models
Create Date: 2026-03-28

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'set_moderation_status_approved_default'
down_revision = '8a938cc8765f_update_models'
branch_labels = None
depends_on = None

def upgrade():
    op.alter_column(
        'listings',
        'moderation_status',
        existing_type=sa.Enum('pending', 'approved', 'rejected', name='moderationstatusenum'),
        server_default='approved',
        existing_nullable=False
    )

def downgrade():
    op.alter_column(
        'listings',
        'moderation_status',
        existing_type=sa.Enum('pending', 'approved', 'rejected', name='moderationstatusenum'),
        server_default='pending',
        existing_nullable=False
    )
