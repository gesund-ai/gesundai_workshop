from pydantic import BaseModel
from register import outschema


@outschema.register_module('ISIC_TF', default=False)
class Response(BaseModel):
    prediction_class: int
    confidence: float
    logits: list