import tensorflow as tf
import efficientnet.tfkeras as efn
import tensorflow.keras.backend as K

class EfficientNet:
    def model():
        inp = tf.keras.layers.Input(shape=(384, 384, 3))
        base = efn.EfficientNetB0(input_shape=(384, 384, 3), weights="imagenet", include_top=False)
        x = base(inp)
        x = tf.keras.layers.GlobalAveragePooling2D()(x)
        x = tf.keras.layers.Dense(1, activation="sigmoid")(x)
        model = tf.keras.Model(inputs=inp, outputs=x)
        K.clear_session()

        return model