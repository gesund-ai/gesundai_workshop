from turtle import resizemode
from logger import AppLogger

import numpy as np
from PIL import Image
try:
    import tensorflow as tf 

except:
    pass
    
applogger = AppLogger(__name__)
logger = applogger.get_logger()


def custom_preprocess_fxn(input,batch=False):
    logger.info("Preprocess started")
    def preprocess_img(np_img):
        img = Image.fromarray(np_img)   
        resized_img =  img.resize((224,224)) 
        if resized_img.getcolors():
            resized_img = resized_img.convert("RGB")
        resized_img = np.array(resized_img)[...,:3]
        #array_img = np.array(resized_img)/255
        tf_img = tf.convert_to_tensor(resized_img)
        return tf.expand_dims(tf_img, 0)    
        
    if batch:
        preprocessed_img_list = []
        return [preprocess_img(np_img) for np_img in input]

    else: 
        return preprocess_img(input)


class Preprocess:
    def __init__(self) -> None:
        self._preprocess = custom_preprocess_fxn

    def __call__(self, input,batch):
        return self._preprocess(input,batch)
