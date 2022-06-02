def custom_postprocess_fxn(model_output, batch=False, context=None, threshold=0.5):
    def _postprocess(output):
        for i in output[0]:
            i = i.tolist()
            if i >threshold:
                prediction_class = 1
                confidence = i
                logits = [1 - i, i]
            else:
                prediction_class = 0
                confidence = 1 - i
                logits = [1 - i, i]

        output = {
            "prediction_class": prediction_class,
            "confidence": confidence,
            "logits": logits,
            "status": 200,
        }
        return output

    if batch:
        return [_postprocess(i) for i in model_output]

    else:
        return _postprocess(model_output)


class Postprocess():
    def __init__(self) -> None:
        self._postprocess_fxn = custom_postprocess_fxn

    def __call__(self, input, batch=False, context=None):
        return self._postprocess_fxn(input, batch, context)