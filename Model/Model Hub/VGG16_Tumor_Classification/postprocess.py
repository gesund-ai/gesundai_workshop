try:
    import torch.nn.functional as F
    import numpy as np
except:
    pass
    
def custom_postprocess_fxn(model_output, batch=False, context=None, threshold=0.5):
    def _postprocess(image_output):
        prediction_class = image_output[0].tolist().index(max(image_output[0]))  # index of the highest probability
        confidence = image_output[0][prediction_class]

        output = {'prediction_class': prediction_class,
                  'confidence': float(confidence),
                  'logits': image_output[0].tolist(),
                  'status': 200}
        return output

    if batch:
        return [_postprocess(single_output) for single_output in model_output]
    else:
        return _postprocess(model_output)


class Postprocess():
    def __init__(self) -> None:
        self._postprocess_fxn = custom_postprocess_fxn

    def __call__(self, input, batch=False, context=None):
        return self._postprocess_fxn(input, batch, context)
