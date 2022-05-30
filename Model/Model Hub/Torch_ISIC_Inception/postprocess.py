def custom_postprocess_fxn(model_output, batch=False, context=None, threshold=0.5):
    def _postprocess(output):
        import torch.nn.functional as F
        import numpy as np
        
        logits = F.softmax(output, dim=1).detach().numpy()[0]  # list of probabilities
        logits =  logits[0:2]/np.sum(logits[0:2]) 
        y_pred = logits

        prediction_index = logits.tolist().index(max(logits))  # index of the highest probability
        labels = [0, 1]

        if y_pred[prediction_index] >= threshold:
            prediction_class = labels[prediction_index]
            confidence = y_pred[prediction_index]

        elif y_pred[prediction_index] < threshold:
            prediction_class = labels[prediction_index]
            confidence = y_pred[prediction_index]

        output = {'prediction_class': prediction_class,
                    'confidence': float(confidence),
                    'logits': logits.tolist(),
                    'status': 200}
        return output

    if batch:
        return [_postprocess(output) for output in model_output]
        
    else:
        return _postprocess(model_output)


class Postprocess():
    def __init__(self) -> None:
        self._postprocess_fxn = custom_postprocess_fxn

    def __call__(self, input, batch=False, context=None):
        return self._postprocess_fxn(input, batch, context)
