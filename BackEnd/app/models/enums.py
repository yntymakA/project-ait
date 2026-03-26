import enum

class RoleEnum(str, enum.Enum):
    user = "user"
    moderator = "moderator"
    admin = "admin"
    superadmin = "superadmin"

class UserStatusEnum(str, enum.Enum):
    active = "active"
    blocked = "blocked"
    pending_verification = "pending_verification"
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
    pending = "pending"
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
    open = "open"
    resolved = "resolved"
    dismissed = "dismissed"

class TransactionTypeEnum(str, enum.Enum):
    top_up = "top_up"
    spend = "spend"

class PromotionTypeEnum(str, enum.Enum):
    featured = "featured"
    boosted = "boosted"
    top_feed = "top_feed"
