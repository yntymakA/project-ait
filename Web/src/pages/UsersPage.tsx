import { Card } from '@/components/Card'
import { UsersDirectoryTable, UsersFilterBar, useUsersDirectory } from '@/features/users'
import styles from './PageSection.module.css'

export function UsersPage() {
  const { role, setRole, rows } = useUsersDirectory()

  return (
    <Card
      title="Users"
      subtitle="Directory preview — replace with usersService.list"
      padding="none"
    >
      <div className={styles.section}>
        <UsersFilterBar role={role} onRoleChange={setRole} />
        <UsersDirectoryTable rows={rows} />
      </div>
    </Card>
  )
}
