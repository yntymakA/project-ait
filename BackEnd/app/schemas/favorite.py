from pydantic import BaseModel, ConfigDict
from builtins import int

class FavoriteResponse(BaseModel):
    id: int
    user_id: int
    listing_id: int
    
    model_config = ConfigDict(from_attributes=True)
