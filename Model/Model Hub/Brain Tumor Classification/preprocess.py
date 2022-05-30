def custom_preprocess_fxn(input,batch=False):
    import torchvision.transforms as T
    
    img_preprocess = T.Compose([T.ToTensor(),
                                T.Normalize([0.485, 0.456, 0.406],
                                            [0.229, 0.224, 0.225])
                                ])
    img = img_preprocess(input)
    return img


class Preprocess:
    def __init__(self) -> None:
        self._preprocess = custom_preprocess_fxn

    def __call__(self, input,batch):
        return self._preprocess(input,batch)
