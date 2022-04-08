from logger import AppLogger
from register.register import modelservice
from .preprocess import Preprocess
from .postprocess import Postprocess

logger = AppLogger(__name__).get_logger()

__all__ = ["DenseNet100_Tumor"]




@modelservice.register_module(name='DenseNet100_Tumor', default=False)
class DenseNet100_Tumor:
    def __init__(self, model_path) -> None:
        from torch import nn
        self.model_path = model_path
        self.preprocess = Preprocess()
        self.postprocess = Postprocess()

    def load(self):
        try:
            import torch
        except ImportError:
            raise RuntimeError("PyTorch is not installed. Please install it.")

        try:
            model = torch.load(self.model_path, map_location=torch.device('cpu'))
            model.to('cpu')
            model.eval()
            self.model = model
        except Exception as e:
            raise Exception(f"Failed to load model from {self.model_path}. {e}")

    def predict(self, img):

        try:
            import torch
        except ImportError:
            raise RuntimeError("PyTorch is not installed. Please install it.")

        y_pred = self.model(img[None, :, :, :])
        return y_pred
