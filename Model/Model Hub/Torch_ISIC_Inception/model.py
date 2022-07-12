import torch
import torch.nn as nn
import numpy as np

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

        model = torch.load(self.model_path, map_location=torch.device('cpu'))
        self.model = model

    def predict(self, img):
        pred = self.model(img)
        pred_softmax = nn.functional.softmax(pred)
        return pred_softmax


    def loss(self, y_pred, gts):
        if not any(isinstance(el, list) for el in gts):
            gts = np.asarray(list(map(lambda x: int(x["class"]), gts)))
        # Apply loss function
        _loss_function = nn.CrossEntropyLoss(reduction="none")
        gts_encoder = np.zeros((gts.size, 2))
        gts_encoder[np.arange(gts.size), gts] = 1
        gts_encoder = torch.from_numpy(gts_encoder)

        losses = _loss_function(y_pred, gts_encoder).detach().numpy().tolist()

        return losses