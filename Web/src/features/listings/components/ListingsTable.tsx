import { Table, type TableColumn } from '@/components/Table'
import { formatCurrency, formatDate } from '@/utils'
import type { Listing } from '@/types'

const columns: TableColumn<Listing>[] = [
  { id: 'title', header: 'Listing', accessor: 'title' },
  { id: 'status', header: 'Status', accessor: 'status' },
  {
    id: 'price',
    header: 'Price',
    cell: (row) => formatCurrency(row.price, row.currency),
  },
  {
    id: 'updatedAt',
    header: 'Updated',
    cell: (row) => formatDate(row.updatedAt),
  },
]

export interface ListingsTableProps {
  rows: Listing[]
}

export function ListingsTable({ rows }: ListingsTableProps) {
  return <Table columns={columns} rows={rows} emptyMessage="No listings for this filter" />
}
