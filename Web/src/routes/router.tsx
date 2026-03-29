import { createBrowserRouter } from 'react-router-dom'
import { AccessDeniedPage } from '@/features/auth/AccessDeniedPage'
import { LoginPage } from '@/features/auth/LoginPage'
import { MainLayout } from '@/layouts/MainLayout'
import { DashboardPage } from '@/pages/DashboardPage'
import { ListingsPage } from '@/pages/ListingsPage'
import { ReportsPage } from '@/pages/ReportsPage'
import { UsersPage } from '@/pages/UsersPage'
import { CategoriesPage } from '@/pages/CategoriesPage'
import { ProtectedLayout } from './ProtectedLayout'

export const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  { path: '/access-denied', element: <AccessDeniedPage /> },
  {
    path: '/',
    element: <ProtectedLayout />,
    children: [
      {
        element: <MainLayout />,
        children: [
          {
            index: true,
            element: <DashboardPage />,
            handle: { title: 'Dashboard' },
          },
          {
            path: 'categories',
            element: <CategoriesPage />,
            handle: { title: 'Categories' },
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
    ],
  },
])
