import { Table, type TableColumn } from '@/components/Table'
import { formatCurrency, formatDate } from '@/utils'
import type { Listing } from '@/types'

export interface ListingsTableProps {
  rows: Listing[]
  onModerate?: (id: string, status: 'approved' | 'rejected') => void
}

export function ListingsTable({ rows, onModerate }: ListingsTableProps) {
  const columns: TableColumn<Listing>[] = [
    { 
      id: 'title', 
      header: 'Listing', 
      cell: (row) => (
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          <span style={{ fontWeight: 600 }}>{row.title}</span>
          <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)' }}>ID: {row.id}</span>
        </div>
      )
    },
    { id: 'status', header: 'Status', accessor: 'status' },
    {
      id: 'price',
      header: 'Price',
      cell: (row) => formatCurrency(row.price, row.currency),
    },
    {
      id: 'updated_at',
      header: 'Updated',
      cell: (row) => formatDate(row.updated_at),
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: (row) => (
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          {row.status === 'pending_review' && (
            <>
              <button
                onClick={() => onModerate?.(row.id, 'approved')}
                style={{
                  padding: '4px 8px',
                  borderRadius: '6px',
                  border: '1px solid #10b981',
                  background: '#ecfdf5',
                  color: '#047857',
                  fontSize: '0.75rem',
                  fontWeight: 600,
                  cursor: 'pointer'
                }}
              >
                Approve
              </button>
              <button
                onClick={() => onModerate?.(row.id, 'rejected')}
                style={{
                  padding: '4px 8px',
                  borderRadius: '6px',
                  border: '1px solid #ef4444',
                  background: '#fef2f2',
                  color: '#b91c1c',
                  fontSize: '0.75rem',
                  fontWeight: 600,
                  cursor: 'pointer'
                }}
              >
                Reject
              </button>
            </>
          )}
        </div>
      )
    }
  ]

  return <Table columns={columns} rows={rows} emptyMessage="No listings for this filter" />
}
