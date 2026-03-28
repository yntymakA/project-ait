import type { HTMLAttributes, ReactNode } from 'react'
import styles from './Card.module.css'

type CardPadding = 'md' | 'lg' | 'none'

export interface CardProps extends Omit<HTMLAttributes<HTMLDivElement>, 'title'> {
  title?: ReactNode
  subtitle?: ReactNode
  /** Right-side slot (actions, badges) */
  headerExtra?: ReactNode
  padding?: CardPadding
  children: ReactNode
}

const paddingClass: Record<CardPadding, string | undefined> = {
  none: undefined,
  md: styles.paddingMd,
  lg: styles.paddingLg,
}

export function Card({
  title,
  subtitle,
  headerExtra,
  padding = 'md',
  className = '',
  children,
  ...rest
}: CardProps) {
  const pad = paddingClass[padding]
  const rootClass = [styles.card, pad, className].filter(Boolean).join(' ')

  const showHeader = title != null || subtitle != null || headerExtra != null

  return (
    <div className={rootClass} {...rest}>
      {showHeader ? (
        <header className={styles.header}>
          <div>
            {title != null ? <h2 className={styles.title}>{title}</h2> : null}
            {subtitle != null ? (
              <p className={styles.subtitle}>{subtitle}</p>
            ) : null}
          </div>
          {headerExtra != null ? <div>{headerExtra}</div> : null}
        </header>
      ) : null}
      <div className={styles.body}>{children}</div>
    </div>
  )
}
