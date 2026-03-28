import { Table, type TableColumn } from '@/components/Table'
import { formatDate } from '@/utils'
import type { User } from '@/types'

const columns: TableColumn<User>[] = [
  { id: 'displayName', header: 'Name', accessor: 'displayName' },
  { id: 'email', header: 'Email', accessor: 'email' },
  { id: 'role', header: 'Role', accessor: 'role' },
  {
    id: 'createdAt',
    header: 'Joined',
    cell: (row) => formatDate(row.createdAt),
  },
]

export interface UsersDirectoryTableProps {
  rows: User[]
}

export function UsersDirectoryTable({ rows }: UsersDirectoryTableProps) {
  return <Table columns={columns} rows={rows} emptyMessage="No users match this filter" />
}
