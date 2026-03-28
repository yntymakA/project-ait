import { Card } from '@/components/Card'
import { UsersDirectoryTable, UsersFilterBar, useUsersDirectory } from '@/features/users'
import styles from './PageSection.module.css'

export function UsersPage() {
  const { role, setRole, rows, isLoading, onModerate } = useUsersDirectory()

  return (
    <Card title="Users" padding="none">
      <div className={styles.section}>
        <UsersFilterBar role={role} onRoleChange={setRole} />
        {isLoading ? (
          <div style={{ padding: '2rem', textAlign: 'center' }}>Loading user directory...</div>
        ) : (
          <UsersDirectoryTable rows={rows} onModerate={onModerate} />
        )}
      </div>
    </Card>
  )
}
