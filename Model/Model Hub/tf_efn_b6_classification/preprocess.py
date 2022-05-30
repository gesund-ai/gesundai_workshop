def custom_preprocess_fxn(input,batch=False):
    from efficientnet.keras import center_crop_and_resize, preprocess_input
    import numpy as np

    img = center_crop_and_resize(input, image_size=384)
    img = preprocess_input(img)
    img = np.expand_dims(img, 0)
    return img 

class Preprocess:
    def __init__(self) -> None:
        self._preprocess = custom_preprocess_fxn

    def __call__(self, input,batch):
        return self._preprocess(input,batch)