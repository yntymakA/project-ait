import { Table, type TableColumn } from '@/components/Table'
import { formatDate } from '@/utils'
import type { Report } from '@/types'

const columns: TableColumn<Report>[] = [
  { id: 'name', header: 'Report', accessor: 'name' },
  {
    id: 'generatedAt',
    header: 'Generated',
    cell: (row) => formatDate(row.generatedAt),
  },
  {
    id: 'format',
    header: 'Format',
    cell: (row) => row.format.toUpperCase(),
  },
]

export interface ReportsDataTableProps {
  rows: Report[]
}

export function ReportsDataTable({ rows }: ReportsDataTableProps) {
  return <Table columns={columns} rows={rows} emptyMessage="No reports loaded yet" />
}
