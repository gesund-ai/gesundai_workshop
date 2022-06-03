
class EfficientNet:
    def model():
        inp = tf.keras.layers.Input(shape=(384, 384, 3))
        base = efn.EfficientNetB6(input_shape=(384, 384, 3), weights="imagenet", include_top=False)
        x = base(inp)
        x = tf.keras.layers.GlobalAveragePooling2D()(x)
        x = tf.keras.layers.Dense(1, activation="sigmoid")(x)
        model = tf.keras.Model(inputs=inp, outputs=x)
        opt = tf.keras.optimizers.Adam(learning_rate=0.001)
        loss = tf.keras.losses.BinaryCrossentropy(label_smoothing=0.05)
        model.compile(optimizer=opt, loss=loss, metrics=["AUC"])
        K.clear_session()
        return model
