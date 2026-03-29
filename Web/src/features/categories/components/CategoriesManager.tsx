import { useState } from 'react'
import { Table, type TableColumn } from '@/components/Table'
import { categoriesService, type CategoryTreeResponse } from '@/services/categories/categoriesService'
import styles from './CategoriesManager.module.css'

export interface CategoriesManagerProps {
  tree: CategoryTreeResponse[]
  onCategoryAdded: () => void
}

interface FlatCategoryRow extends CategoryTreeResponse {
  parentName: string
}

function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
}

function flattenTree(nodes: CategoryTreeResponse[], parentName = ''): FlatCategoryRow[] {
  let flat: FlatCategoryRow[] = []
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
  const [deactivatingId, setDeactivatingId] = useState<number | null>(null)

  const [name, setName] = useState('')
  const [slug, setSlug] = useState('')
  const [slugTouched, setSlugTouched] = useState(false)
  const [parentId, setParentId] = useState<string>('')
  const [displayOrder, setDisplayOrder] = useState<number>(0)
  const [feedback, setFeedback] = useState<string | null>(null)
  const [isError, setIsError] = useState(false)

  const flatCategories = flattenTree(tree)
  const canSubmit = name.trim().length > 0 && slug.trim().length > 0 && !isSubmitting

  const onNameChange = (value: string) => {
    setName(value)
    if (!slugTouched) {
      setSlug(slugify(value))
    }
  }

  const onSlugChange = (value: string) => {
    setSlugTouched(true)
    setSlug(slugify(value))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!canSubmit) return
    setFeedback(null)
    setIsError(false)

    try {
      setIsSubmitting(true)
      await categoriesService.create({
        name: name.trim(),
        slug: slug.trim(),
        parent_id: parentId ? parseInt(parentId, 10) : null,
        display_order: displayOrder,
      })
      setName('')
      setSlug('')
      setSlugTouched(false)
      setParentId('')
      setDisplayOrder(0)
      setFeedback('Category created successfully')
      onCategoryAdded()
    } catch (err) {
      console.error(err)
      setIsError(true)
      setFeedback(err instanceof Error ? err.message : 'Failed to add category')
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleDeactivate = async (row: FlatCategoryRow) => {
    if (deactivatingId != null) return
    const confirmed = window.confirm(`Deactivate category "${row.name}"?`)
    if (!confirmed) return

    setFeedback(null)
    setIsError(false)
    try {
      setDeactivatingId(row.id)
      const result = await categoriesService.deactivate(row.id)
      setFeedback(`Category deactivated. Affected: ${result.deactivated_count}`)
      await onCategoryAdded()
    } catch (err) {
      console.error(err)
      setIsError(true)
      setFeedback(err instanceof Error ? err.message : 'Failed to deactivate category')
    } finally {
      setDeactivatingId(null)
    }
  }

  const columns: TableColumn<FlatCategoryRow>[] = [
    { id: 'id', header: 'ID', accessor: 'id' },
    { id: 'name', header: 'Name', accessor: 'name' },
    { id: 'slug', header: 'Slug', accessor: 'slug' },
    { id: 'parentName', header: 'Parent', accessor: 'parentName' },
    { id: 'display_order', header: 'Order', accessor: 'display_order' },
    { id: 'is_active', header: 'Active', cell: (row) => row.is_active ? 'Yes' : 'No' },
    {
      id: 'actions',
      header: 'Actions',
      cell: (row) => (
        <button
          type="button"
          className={styles.dangerButton}
          disabled={deactivatingId === row.id}
          onClick={() => void handleDeactivate(row)}
        >
          {deactivatingId === row.id ? 'Deactivating...' : 'Deactivate'}
        </button>
      ),
    },
  ]

  return (
    <div className={styles.container}>
      <form onSubmit={handleSubmit} className={styles.formRow}>
        <input
          placeholder="Name"
          value={name}
          onChange={(e) => onNameChange(e.target.value)}
          required
          className={styles.input}
        />
        <input
          placeholder="Slug"
          value={slug}
          onChange={(e) => onSlugChange(e.target.value)}
          required
          className={styles.input}
        />
        <select
          value={parentId}
          onChange={(e) => setParentId(e.target.value)}
          className={styles.input}
        >
          <option value="">No Parent (Root)</option>
          {flatCategories.map((cat) => (
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
        <button type="submit" disabled={!canSubmit} className={styles.button}>
          {isSubmitting ? 'Adding...' : 'Add Category'}
        </button>
      </form>

      {feedback != null ? (
        <p className={isError ? styles.errorText : styles.successText}>{feedback}</p>
      ) : null}

      <div style={{ marginTop: '1.5rem' }}>
        <Table columns={columns} rows={flatCategories} emptyMessage="No categories found" />
      </div>
    </div>
  )
}