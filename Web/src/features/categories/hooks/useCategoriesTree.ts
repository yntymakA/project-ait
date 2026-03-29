import { useState, useEffect } from 'react'
import { categoriesService, type CategoryTreeResponse } from '@/services/categories/categoriesService'

export function useCategoriesTree() {
  const [tree, setTree] = useState<CategoryTreeResponse[]>([])
  const [isLoading, setIsLoading] = useState(true)

  const loadTree = async () => {
    setIsLoading(true)
    try {
      const response = await categoriesService.getTree()
      setTree(response)
    } catch (err) {
      console.error('Failed to fetch categories:', err)
      alert('Failed to load categories')
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadTree()
  }, [])

  return { tree, isLoading, reloadTree: loadTree }
}