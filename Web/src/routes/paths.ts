/** Route path constants — use in links, redirects, and route definitions. */

export const paths = {
  dashboard: '/',
  reports: '/reports',
  users: '/users',
  listings: '/listings',
  categories: '/categories',
} as const

export type AppPath = (typeof paths)[keyof typeof paths]
