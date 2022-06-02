def custom_preprocess_fxn(input,batch=False):
    from efficientnet.keras import center_crop_and_resize, preprocess_input
    import tensorflow as tf
    import numpy as np

    def _preprocess_single_image(input):
        img = center_crop_and_resize(input, image_size=384)
        img = preprocess_input(img)
        img = np.expand_dims(img, 0)
        return img

    if batch:
        img = []
        for inp_ in input:
            img.append(_preprocess_single_image(inp_))
        img = tf.keras.backend.concatenate(img,axis=0)
    else:
        img = _preprocess_single_image(input)
    return img

class Preprocess:
    def __init__(self) -> None:
        self._preprocess = custom_preprocess_fxn

    def __call__(self, input,batch):
        return self._preprocess(input,batch)