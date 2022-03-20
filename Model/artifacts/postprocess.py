import numpy as np

def softmax(x):
    """Compute softmax values for each sets of scores in x."""
    e_x = np.exp(x - np.max(x))
    return e_x / e_x.sum()


def custom_postprocess_fxn(model_output, batch=False, context=None, threshold=0.0):
    def _postprocess(output):
        prob = softmax(np.array(output[0]))
        confidence = output[0][0]
        prediction_class = 0
        if threshold > 0:
            prediction_class = 1 if confidence > threshold else 0
        else:
            prediction_class = int(confidence)

        output = {'prediction_class': prediction_class,
                  'confidence': float(confidence),
                  'logits': prob.tolist(),
                  'status': 200}
        return output
    if batch:
        return [_postprocess([val]) for idx, val in enumerate(model_output)]
    else:
        return _postprocess(model_output)


class Postprocess:
    def __init__(self) -> None:
        self._postprocess_fxn = custom_postprocess_fxn

    def __call__(self, input, batch=False, context=None):
        return self._postprocess_fxn(input, batch, context)
