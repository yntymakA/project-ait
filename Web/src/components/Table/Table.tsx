import type { ReactNode } from 'react'
import styles from './Table.module.css'

export interface TableColumn<Row> {
  id: string
  header: string
  /** When set, value is read from the row object */
  accessor?: keyof Row & string
  /** Overrides cell content */
  cell?: (row: Row) => ReactNode
}

export interface TableProps<Row extends object> {
  columns: TableColumn<Row>[]
  rows: Row[]
  emptyMessage?: string
}

export function Table<Row extends object>({
  columns,
  rows,
  emptyMessage = 'No rows to display',
}: TableProps<Row>) {
  if (rows.length === 0) {
    return (
      <div className={styles.tableWrap} role="status">
        <div className={styles.empty}>{emptyMessage}</div>
      </div>
    )
  }

  return (
    <div className={styles.tableWrap}>
      <table className={styles.table}>
        <thead>
          <tr>
            {columns.map((col) => (
              <th key={col.id} className={styles.th} scope="col">
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, rowIndex) => (
            <tr key={rowIndex}>
              {columns.map((col) => {
                const content =
                  col.cell != null
                    ? col.cell(row)
                    : col.accessor != null
                      ? String((row as Record<string, unknown>)[col.accessor] ?? '')
                      : null

                return (
                  <td key={col.id} className={styles.td}>
                    {content}
                  </td>
                )
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
