import numpy as np

from logger import AppLogger
from register.register import modelservice
from core.engine.base_models import TensorflowModel
from .preprocess import Preprocess
from .postprocess import Postprocess
from .loss import MyLoss

logger = AppLogger(__name__).get_logger()

__all__ = ['MyNet']

try:
    import tensorflow as tf
except ImportError:
    pass


@modelservice.register_module(name='MyNet', default=False)
class MyNet(TensorflowModel):
    def __init__(self, model_path) -> None:
        super().__init__(model_path)
        self.model_path = model_path
        self.preprocess = Preprocess()
        self.preprocess(np.zeros((100, 100, 3)), False)
        self.postprocess = Postprocess()
        self.num_classes = 1
        self.class_mapping = {1: 'Positive', 0: 'Negative'}
        self.loss = MyLoss()

    def _load_model(self):
        self.model = super().load()

    def load(self):
        self._load_model()

    def _model_output(self, input):
        y_pred = self.model.predict(input)
        return y_pred

    def predict(self, input):
        y_pred = self._model_output(input)
        return y_pred

    def loss(self, y_pred, gts):
        return self.loss.calc_loss(y_pred, gts)


