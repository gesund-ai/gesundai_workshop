import numpy as np


def custom_preprocess_fxn(input, batch=False):
    if batch:
        return np.asarray(
            [np.resize(inp, (64, 64, 3)) / 255.0 for inp in input])
    input = np.resize(input, (64, 64, 3)) / 255.0
    return np.expand_dims(input, 0)


class Preprocess:
    def __init__(self) -> None:
        self._preprocess = custom_preprocess_fxn

    def __call__(self, input, batch=False):
        if batch:
            return np.asarray(
                [np.resize(inp, (64, 64, 3)) / 255.0 for inp in input])
        input = np.resize(input, (64, 64, 3)) / 255.0
        return np.expand_dims(input, 0)
