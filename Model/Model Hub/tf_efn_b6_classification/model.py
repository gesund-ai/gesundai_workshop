from logger import AppLogger
from register.register import modelservice
from .preprocess import Preprocess
from .postprocess import Postprocess

logger = AppLogger(__name__).get_logger()

__all__ = ["ISIC_TF"]

@modelservice.register_module(name='ISIC_TF', default=False)
class ISIC_TF:
    def __init__(self, model_path) -> None:
        self.model_path = model_path
        self.preprocess = Preprocess()
        self.postprocess = Postprocess()

        
    def load(self):
        import tensorflow as tf
        import efficientnet.tfkeras as efn
        import tensorflow.keras.backend as K

        inp = tf.keras.layers.Input(shape=(384, 384, 3))
        base = efn.EfficientNetB6(input_shape=(384, 384, 3), weights="imagenet", include_top=False)
        x = base(inp)
        x = tf.keras.layers.GlobalAveragePooling2D()(x)
        x = tf.keras.layers.Dense(1, activation="sigmoid")(x)
        model = tf.keras.Model(inputs=inp, outputs=x)
        opt = tf.keras.optimizers.Adam(learning_rate=0.001)
        loss = tf.keras.losses.BinaryCrossentropy(label_smoothing=0.05)
        model.compile(optimizer=opt, loss=loss, metrics=["AUC"])
        K.clear_session()
        model.load_weights(self.model_path)
        self.model = model

    def predict(self, img):
        pred = self.model.predict(img)
        return pred
