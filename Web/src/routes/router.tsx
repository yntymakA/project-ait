import { createBrowserRouter } from 'react-router-dom'
import { MainLayout } from '@/layouts/MainLayout'
import { DashboardPage } from '@/pages/DashboardPage'
import { ListingsPage } from '@/pages/ListingsPage'
import { ReportsPage } from '@/pages/ReportsPage'
import { UsersPage } from '@/pages/UsersPage'

export const router = createBrowserRouter([
  {
    path: '/',
    element: <MainLayout />,
    children: [
      {
        index: true,
        element: <DashboardPage />,
        handle: { title: 'Dashboard' },
      },
      {
        path: 'reports',
        element: <ReportsPage />,
        handle: { title: 'Reports' },
      },
      {
        path: 'users',
        element: <UsersPage />,
        handle: { title: 'Users' },
      },
      {
        path: 'listings',
        element: <ListingsPage />,
        handle: { title: 'Listings' },
      },
    ],
  },
])
