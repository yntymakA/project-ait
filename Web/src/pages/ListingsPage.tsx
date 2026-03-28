import { Card } from '@/components/Card'
import { ListingsStatusTabs, ListingsTable, useListingsOverview } from '@/features/listings'
import styles from './PageSection.module.css'

export function ListingsPage() {
  const { status, setStatus, rows } = useListingsOverview()

  return (
    <Card
      title="Listings"
      subtitle="Inventory preview — replace with listingsService.list"
      padding="none"
    >
      <div className={styles.section}>
        <ListingsStatusTabs status={status} onChange={setStatus} />
        <ListingsTable rows={rows} />
      </div>
    </Card>
  )
}
