import { Card } from '@/components/Card'
import { ListingsStatusTabs, ListingsTable, useListingsOverview } from '@/features/listings'
import styles from './PageSection.module.css'

export function ListingsPage() {
  const { status, setStatus, rows, isLoading, onModerate } = useListingsOverview()

  return (
    <Card
      title="Listings"
      subtitle={isLoading ? 'Loading listings...' : `Total listings: ${rows.length}`}
      padding="none"
    >
      <div className={styles.section}>
        <ListingsStatusTabs status={status} onChange={setStatus} />
        {isLoading ? (
          <div style={{ padding: '2rem', textAlign: 'center' }}>Loading listings inventory...</div>
        ) : (
          <ListingsTable rows={rows} onModerate={onModerate} />
        )}
      </div>
    </Card>
  )
}
