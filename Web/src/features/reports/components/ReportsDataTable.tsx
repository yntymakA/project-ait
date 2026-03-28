import { Table, type TableColumn } from '@/components/Table'
import { formatDate } from '@/utils'
import type { Report } from '@/types'

export interface ReportsDataTableProps {
  rows: Report[]
  onResolve?: (id: string, status: 'resolved' | 'dismissed', note?: string) => void
}

export function ReportsDataTable({ rows, onResolve }: ReportsDataTableProps) {
  const columns: TableColumn<Report>[] = [
    { 
      id: 'target', 
      header: 'Target', 
      cell: (row) => (
        <span style={{ textTransform: 'capitalize' }}>
          {row.target_type} #{row.target_id}
        </span>
      )
    },
    { id: 'reason_code', header: 'Reason', accessor: 'reason_code' },
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
        <div style={{ display: 'flex', gap: '0.4rem' }}>
          {row.status === 'pending' && (
            <>
              <button
                onClick={() => {
                  const note = prompt('Enter resolution note (optional):') || ''
                  onResolve?.(row.id, 'resolved', note)
                }}
                style={{
                  padding: '4px 8px',
                  borderRadius: '6px',
                  border: '1px solid #10b981',
                  background: '#ecfdf5',
                  color: '#047857',
                  fontSize: '0.7rem',
                  fontWeight: 600,
                  cursor: 'pointer'
                }}
              >
                Resolve
              </button>
              <button
                onClick={() => {
                  const note = prompt('Enter dismissal note (optional):') || ''
                  onResolve?.(row.id, 'dismissed', note)
                }}
                style={{
                  padding: '4px 8px',
                  borderRadius: '6px',
                  border: '1px solid #94a3b8',
                  background: '#f1f5f9',
                  color: '#475569',
                  fontSize: '0.7rem',
                  fontWeight: 600,
                  cursor: 'pointer'
                }}
              >
                Dismiss
              </button>
            </>
          )}
        </div>
      )
    }
  ]

  return <Table columns={columns} rows={rows} emptyMessage="No reports loaded yet" />
}
