import enum

class RoleEnum(str, enum.Enum):
    guest = "guest"
    authenticated_user = "authenticated_user"
    admin = "admin"

class UserStatusEnum(str, enum.Enum):
    active = "active"
    blocked = "blocked"
    deleted = "deleted"

class ListingStatusEnum(str, enum.Enum):
    draft = "draft"
    pending_review = "pending_review"
    approved = "approved"
    rejected = "rejected"
    archived = "archived"
    sold = "sold"

class ModerationStatusEnum(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"

class PromotionStatusEnum(str, enum.Enum):
    none = "none"
    pending = "pending"#waiting for payment
    active = "active"
    expired = "expired"
    cancelled = "cancelled"

class MessageTypeEnum(str, enum.Enum):
    text = "text"
    attachment = "attachment"

class NotificationTypeEnum(str, enum.Enum):
    listing_approved = "listing_approved"
    new_message = "new_message"
    payment_success = "payment_success"
    # will add others dynamically or as string if needed

class ReportTargetTypeEnum(str, enum.Enum):
    listing = "listing"
    user = "user"
    message = "message"

class ReportStatusEnum(str, enum.Enum):
    open = "pending"
    resolved = "resolved"
    dismissed = "dismissed"

class TransactionTypeEnum(str, enum.Enum):
    top_up = "top_up"
    spend = "spend"

class PromotionTypeEnum(str, enum.Enum):
    # Выделяется визуально на фронтенде (рамка, значок VIP)
    featured = "featured"
    # Единоразово обновляется дата (прыгает на первую страницу, имитируя новое)
    boosted = "boosted"
    # Физически в SQL (ORDER BY) закрепляется всегда выше обычных объявлений
    top_feed = "top_feed"
