import { Card } from '@/components/Card'
import { CategoriesManager, useCategoriesTree } from '@/features/categories'
import styles from './PageSection.module.css'

export function CategoriesPage() {
  const { tree, isLoading, reloadTree } = useCategoriesTree()

  return (
    <Card title="Categories" padding="none">
      <div className={styles.section}>
        {isLoading ? (
          <div style={{ padding: '2rem', textAlign: 'center' }}>Loading categories...</div>
        ) : (
          <CategoriesManager tree={tree} onCategoryAdded={reloadTree} />
        )}
      </div>
    </Card>
  )
}