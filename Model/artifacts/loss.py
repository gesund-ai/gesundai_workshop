import numpy as np
import tensorflow as tf


class MyLoss:

    def __init__(self):
        pass

    def calc_loss(self, y_pred, gts):
        if not any(isinstance(el, list) for el in gts):
            gts = np.asarray(list(map(lambda x: int(x), gts)))
            # Apply loss function
        _loss_function = tf.keras.losses.CategoricalCrossentropy(
            reduction='none')
        gts_encoder = np.zeros((gts.size, self.num_classes))
        gts_encoder[np.arange(gts.size), gts] = 1
        losses = _loss_function(
            y_pred, gts_encoder).numpy()
        return losses.tolist()
