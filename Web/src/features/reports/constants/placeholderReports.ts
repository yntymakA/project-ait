import type { Report } from '@/types'

/** Demo rows only — real admin UI loads from GET /admin/reports */
export const PLACEHOLDER_REPORTS: Report[] = [
  {
    id: '1',
    status: 'pending',
    reason_code: 'seller',
    reason_text: 'Example description',
    target_type: 'user',
    target_id: '42',
    reporter_user_id: 7,
    created_at: '2026-03-01T10:00:00.000Z',
  },
  {
    id: '2',
    status: 'resolved',
    reason_code: 'spam',
    reason_text: 'Another example',
    target_type: 'listing',
    target_id: '99',
    reporter_user_id: 8,
    created_at: '2026-03-15T14:30:00.000Z',
    resolution_note: 'Reviewed',
  },
]
