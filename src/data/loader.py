"""Load PlantVillage image splits as TensorFlow datasets."""

import os

import keras
import tensorflow as tf


class PlantDataLoader:
    def __init__(self, config: dict):
        # Read the dataset contract once so every split is loaded consistently.
        self.config = config
        self.img_size = tuple(config["data"]["img_size"])
        self.batch_size = config["data"]["batch_size"]
        self.data_dir = config["data"]["split_path"]

    def get_dataset(self, split: str, shuffle: bool = False) -> tf.data.Dataset:
        # Keep split validation explicit to fail before TensorFlow starts scanning.
        directory = os.path.join(self.data_dir, split)

        if not os.path.exists(directory):
            raise FileNotFoundError(f"Directory not found: {directory}")

        # Let Keras infer labels from the deterministic class-directory layout.
        ds = keras.utils.image_dataset_from_directory(
            directory,
            labels="inferred",
            label_mode="categorical",
            image_size=self.img_size,
            batch_size=self.batch_size,
            shuffle=shuffle,
            seed=self.config["data"]["seed"],
            interpolation="bilinear",
        )

        # MobileNetV3 keeps its preprocessing layer inside the model graph, so the
        # dataset contract remains raw RGB pixels in the 0..255 range.
        return ds.prefetch(buffer_size=tf.data.AUTOTUNE)
