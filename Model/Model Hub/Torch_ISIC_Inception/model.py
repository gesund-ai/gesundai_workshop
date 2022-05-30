from logger import AppLogger
from register.register import modelservice
from .preprocess import Preprocess
from .postprocess import Postprocess

logger = AppLogger(__name__).get_logger()

__all__ = ["ISIC_Inception"]

@modelservice.register_module(name='ISIC_Inception', default=False)
class ISIC_Inception:
    def __init__(self, model_path) -> None:
        self.model_path = model_path
        self.preprocess = Preprocess()
        self.postprocess = Postprocess()

        
    def load(self):
        import torch
        
        model = torch.load(self.model_path)
        model = model.to("cpu")
        self.model = model

    def predict(self, img):
        pred = self.model(img)
        return pred
