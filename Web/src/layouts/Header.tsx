import styles from './Header.module.css'

export function Header() {
  return (
    <header className={styles.header}>
      <span className={styles.brand}>Console</span>
      <span className={styles.meta}>Admin</span>
    </header>
  )
}
