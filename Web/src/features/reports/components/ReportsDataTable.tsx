import { Table, type TableColumn } from '@/components/Table'
import { formatDate } from '@/utils'
import type { Report } from '@/types'

export interface ReportsDataTableProps {
  rows: Report[]
  onBlockUser: (targetUserId: string) => void | Promise<void>
}

function truncate(text: string | undefined, max: number) {
  if (text == null || text.length === 0) return '—'
  if (text.length <= max) return text
  return `${text.slice(0, max)}…`
}

export function ReportsDataTable({ rows, onBlockUser }: ReportsDataTableProps) {
  const columns: TableColumn<Report>[] = [
    { id: 'id', header: 'ID', accessor: 'id' },
    {
      id: 'reporter',
      header: 'Reporter',
      cell: (row) => <span>#{row.reporter_user_id}</span>,
    },
    {
      id: 'target',
      header: 'Target',
      cell: (row) => (
        <span style={{ textTransform: 'capitalize' }}>
          {row.target_type} #{row.target_id}
        </span>
      ),
    },
    { id: 'reason_code', header: 'Reason', accessor: 'reason_code' },
    {
      id: 'reason_text',
      header: 'Description',
      cell: (row) => (
        <span title={row.reason_text ?? ''}>{truncate(row.reason_text, 100)}</span>
      ),
    },
    { id: 'status', header: 'Status', accessor: 'status' },
    {
      id: 'created_at',
      header: 'Created',
      cell: (row) => formatDate(row.created_at),
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: (row) => (
        <div
          style={{
            display: 'flex',
            justifyContent: 'flex-end',
            alignItems: 'center',
            minHeight: '2rem',
          }}
        >
          {row.target_type === 'user' ? (
            <button
              type="button"
              onClick={() => void onBlockUser(row.target_id)}
              style={{
                padding: '6px 12px',
                borderRadius: '8px',
                border: '1px solid #b91c1c',
                background: '#fef2f2',
                color: '#b91c1c',
                fontSize: '0.75rem',
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              Block user
            </button>
          ) : (
            <span style={{ color: '#94a3b8', fontSize: '0.75rem' }}>—</span>
          )}
        </div>
      ),
    },
  ]

  return (
    <Table columns={columns} rows={rows} emptyMessage="No reports" />
  )
}
