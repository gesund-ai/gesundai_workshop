def custom_preprocess_fxn(input,batch=False):
    from PIL import Image
    import torch
    from torchvision import transforms
    def _transform(np_img):
        data_transforms = {
        'val': transforms.Compose([
            transforms.Grayscale(num_output_channels=3),
            transforms.Resize(299),
            transforms.CenterCrop(299),
            transforms.ToTensor()
        ]),
    }
        img = Image.fromarray(np_img)
        img = data_transforms['val'](img)
        img = img.unsqueeze(0).to("cpu")
        return img
    if batch:
        return torch.cat([_transform(np_img) for np_img in input])
    else:
        return _transform(input)
class Preprocess:
    def __init__(self) -> None:
        self._preprocess = custom_preprocess_fxn

    def __call__(self, input,batch):
        return self._preprocess(input,batch)