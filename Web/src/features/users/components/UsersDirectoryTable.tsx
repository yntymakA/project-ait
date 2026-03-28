import { Table, type TableColumn } from '@/components/Table'
import { formatDate } from '@/utils'
import type { User } from '@/types'

export interface UsersDirectoryTableProps {
  rows: User[]
  onModerate?: (id: string, status: 'active' | 'blocked' | 'deleted') => void
}

export function UsersDirectoryTable({ rows, onModerate }: UsersDirectoryTableProps) {
  const columns: TableColumn<User>[] = [
    { id: 'full_name', header: 'Name', accessor: 'full_name' },
    { id: 'email', header: 'Email', accessor: 'email' },
    { id: 'role', header: 'Role', accessor: 'role' },
    { id: 'status', header: 'Status', accessor: 'status' },
    {
      id: 'created_at',
      header: 'Joined',
      cell: (row) => formatDate(row.created_at),
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: (row) => (
        <div style={{ display: 'flex', gap: '0.4rem' }}>
          {row.status === 'active' ? (
            <button
              onClick={() => onModerate?.(row.id, 'blocked')}
              style={{
                padding: '4px 8px',
                borderRadius: '6px',
                border: '1px solid #f59e0b',
                background: '#fffbeb',
                color: '#b45309',
                fontSize: '0.7rem',
                fontWeight: 600,
                cursor: 'pointer'
              }}
            >
              Block
            </button>
          ) : (
            <button
              onClick={() => onModerate?.(row.id, 'active')}
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
              Activate
            </button>
          )}
          <button
            onClick={() => onModerate?.(row.id, 'deleted')}
            style={{
              padding: '4px 8px',
              borderRadius: '6px',
              border: '1px solid #ef4444',
              background: '#fef2f2',
              color: '#b91c1c',
              fontSize: '0.7rem',
              fontWeight: 600,
              cursor: 'pointer'
            }}
          >
            Delete
          </button>
        </div>
      )
    }
  ]

  return <Table columns={columns} rows={rows} emptyMessage="No users match this filter" />
}
