import { useState } from 'react'
import { Table, type TableColumn } from '@/components/Table'
import { categoriesService, type CategoryTreeResponse } from '@/services/categories/categoriesService'
import styles from './CategoriesManager.module.css'

export interface CategoriesManagerProps {
  tree: CategoryTreeResponse[]
  onCategoryAdded: () => void
}

function flattenTree(nodes: CategoryTreeResponse[], parentName = ''): any[] {
  let flat: any[] = []
  for (const node of nodes) {
    flat.push({
      ...node,
      parentName: parentName || 'None',
    })
    if (node.children?.length > 0) {
      flat = flat.concat(flattenTree(node.children, node.name))
    }
  }
  return flat
}

export function CategoriesManager({ tree, onCategoryAdded }: CategoriesManagerProps) {
  const [isSubmitting, setIsSubmitting] = useState(false)

  const [name, setName] = useState('')
  const [slug, setSlug] = useState('')
  const [parentId, setParentId] = useState<string>('')
  const [displayOrder, setDisplayOrder] = useState<number>(0)

  const flatCategories = flattenTree(tree)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name || !slug) return

    try {
      setIsSubmitting(true)
      await categoriesService.create({
        name,
        slug,
        parent_id: parentId ? parseInt(parentId, 10) : null,
        display_order: displayOrder,
      })
      setName('')
      setSlug('')
      setParentId('')
      setDisplayOrder(0)
      onCategoryAdded()
    } catch (err) {
      console.error(err)
      alert('Failed to add category')
    } finally {
      setIsSubmitting(false)
    }
  }

  const columns: TableColumn<any>[] = [
    { id: 'id', header: 'ID', accessor: 'id' },
    { id: 'name', header: 'Name', accessor: 'name' },
    { id: 'slug', header: 'Slug', accessor: 'slug' },
    { id: 'parentName', header: 'Parent', accessor: 'parentName' },
    { id: 'display_order', header: 'Order', accessor: 'display_order' },
    { id: 'is_active', header: 'Active', cell: (row) => row.is_active ? 'Yes' : 'No' },
  ]

  return (
    <div className={styles.container}>
      <form onSubmit={handleSubmit} className={styles.formRow}>
        <input 
          placeholder="Name" 
          value={name} 
          onChange={(e) => setName(e.target.value)}
          required
          className={styles.input}
        />
        <input 
          placeholder="Slug" 
          value={slug} 
          onChange={(e) => setSlug(e.target.value)}
          required
          className={styles.input}
        />
        <select 
          value={parentId} 
          onChange={(e) => setParentId(e.target.value)}
          className={styles.input}
        >
          <option value="">No Parent (Root)</option>
          {flatCategories.map(cat => (
            <option key={cat.id} value={cat.id}>{cat.name}</option>
          ))}
        </select>
        <input 
          type="number"
          placeholder="Display Order" 
          value={displayOrder} 
          onChange={(e) => setDisplayOrder(parseInt(e.target.value, 10) || 0)}
          className={styles.input}
          style={{ width: '100px' }}
        />
        <button type="submit" disabled={isSubmitting} className={styles.button}>
          Add Category
        </button>
      </form>

      <div style={{ marginTop: '1.5rem' }}>
        <Table columns={columns} rows={flatCategories} emptyMessage="No categories found" />
      </div>
    </div>
  )
}