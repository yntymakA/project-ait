from sqlalchemy.orm import Session
from app.repositories import listing_repo
from app.schemas.search import ListingSearchParams


def search_listings(db: Session, params: ListingSearchParams) -> tuple[int, list]:
    """
    Search Facade for Listings.
    ===========================
    Currently, this acts as an orchestrator calling the SQL database (MySQL via `listing_repo`).

    TODO (Elasticsearch Phase):
    1. Check if ES is available.
    2. If yes -> Query ES to get `document_ids`, `total_elements`, `aggregations`.
    3. Call `listing_repo.get_by_ids(document_ids)` to fetch actual SQL models.
    4. Return merged results.
    """

    # Pass-through to SQL until Elasticsearch is implemented
    total, items = listing_repo.get_paginated_listings(
        db=db,
        page=params.page,
        page_size=params.page_size,
        q=params.q,
        category_id=params.category_id,
        city=params.city,
        min_price=params.min_price,
        max_price=params.max_price,
        status=params.status,
        sort=params.sort,
    )

    return total, items
