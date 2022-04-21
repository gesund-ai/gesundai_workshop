from http.client import MOVED_PERMANENTLY
from logger import AppLogger
from register.register import modelservice
from .preprocess import Preprocess
from .postprocess import Postprocess

import numpy as np
try:
    import tensorflow as tf
except:
    pass


logger = AppLogger(__name__).get_logger()

__all__ = ["VGG_Tumor"]



@modelservice.register_module(name='VGG_Tumor', default=False)
class VGG_Tumor:
    def __init__(self, model_path) -> None:
        self.model_path = model_path
        self.preprocess = Preprocess()
        self.postprocess = Postprocess()

    def load(self):
        model = tf.keras.models.load_model(self.model_path)
        self.model = model

    def predict(self, input):
        if type(input)==list:
            y_pred = [self.model.predict(img) for img in input]
        else:
            y_pred = self.model.predict(input)
        return y_pred

    def loss(self, y_pred, gts):
        try:
            if not any(isinstance(el, list) for el in gts):
                gts = np.asarray(list(map(lambda x: int(x), gts)))
            # Apply loss function
            _loss_function = tf.keras.losses.CategoricalCrossentropy(
                reduction="none"
            )
            gts_encoder = np.zeros((gts.size, 2))
            gts_encoder[np.arange(gts.size), gts] = 1
            y_pred = np.array([i[0].tolist() for i in y_pred])
            losses = _loss_function(y_pred, gts_encoder).numpy()
            return losses.tolist()
        except Exception as exc:
            logger.error(f"Could not calculate loss for batch, reason: {exc}")
        return None
