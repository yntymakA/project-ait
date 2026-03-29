import { apiFetch } from '@/services/api/http'

export interface CategoryBase {
  name: string
  slug: string
  parent_id: number | null
  display_order: number
}

export interface CategoryResponse extends CategoryBase {
  id: number
  is_active: boolean
}

export interface CategoryTreeResponse extends CategoryResponse {
  children: CategoryTreeResponse[]
}

export const categoriesService = {
  getTree: async (): Promise<CategoryTreeResponse[]> => {
    return apiFetch<CategoryTreeResponse[]>('/categories')
  },
  create: async (data: CategoryBase): Promise<CategoryResponse> => {
    return apiFetch<CategoryResponse>('/categories', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  },
  deactivate: async (categoryId: number): Promise<{ ok: boolean; deactivated_count: number }> => {
    return apiFetch<{ ok: boolean; deactivated_count: number }>(`/categories/${categoryId}/deactivate`, {
      method: 'PATCH',
    })
  },
}
