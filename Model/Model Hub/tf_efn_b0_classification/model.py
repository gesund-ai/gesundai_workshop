try:
    import tensorflow as tf
    import efficientnet.tfkeras as efn
    import tensorflow.keras.backend as K
except:
    pass

from register.register import modelservice
from .preprocess import Preprocess
from .postprocess import Postprocess
from .efficientnet import EfficientNet

logger = AppLogger(__name__).get_logger()

__all__ = ["ISIC_TF_B0"]

@modelservice.register_module(name='ISIC_TF_B0', default=False)
class ISIC_TF_B0:
    def __init__(self, model_path) -> None:
        self.model_path = model_path
        self.preprocess = Preprocess()
        self.postprocess = Postprocess()
        self.efficientnet_obj = EfficientNet()
        self.model = EfficientNet.model()


    def load(self):
        self.model.load_weights(self.model_path)


    def predict(self, img):
        pred = self.model.predict(img)
        return pred

    def loss(self, y_pred, gts):
        if not any(isinstance(el, list) for el in gts):
            gts = np.asarray(list(map(lambda x: int(x["class"]), gts)))
        # Apply loss function
        _loss_function = tf.keras.losses.CategoricalCrossentropy(reduction="none")
        gts_encoder = np.zeros((gts.size, 2))
        gts_encoder[np.arange(gts.size), gts] = 1

        y_pred = np.array((y_pred>0.5)*1).flatten()
        pred_encoder = np.zeros((y_pred.size,2))
        pred_encoder[np.arange(y_pred.size),y_pred] = 1
        losses = _loss_function(pred_encoder, gts_encoder).numpy()

        return losses.tolist()
