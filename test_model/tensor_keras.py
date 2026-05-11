import tensorflow as tf
import tf_keras
import os
import numpy as np

# Define constants matching your training setup
IMAGE_SIZE = 160  # Replace with your actual IMAGE_SIZE
tfi = tf.image


def load_image(image_path: str) -> tf.Tensor:
    # Expand ~ to user home directory
    image_path = os.path.expanduser(image_path)

    # Check if image path exists
    assert os.path.exists(image_path), f"Invalid image path: {image_path}"

    # Read the image file
    image = tf.io.read_file(image_path)

    # Load the image
    try:
        image = tfi.decode_jpeg(image, channels=3)
    except:
        image = tfi.decode_png(image, channels=3)

    # Convert and scale to [0, 1]
    image = tfi.convert_image_dtype(image, tf.float32)

    # Resize the Image
    image = tfi.resize(image, (IMAGE_SIZE, IMAGE_SIZE))

    # (The tf.cast to float32 here was redundant, as it's already float32)

    return image


# 1. Load the model
model_path = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "BestMobileNet.h5"
)
prod_model = tf_keras.models.load_model(model_path)

# 2. Process the image using your custom function
image_tensor = load_image("~/Pictures/Frozen-grapes-featured-image-1024x683.jpeg")

# 3. Add the batch dimension!
# Your model expects shape (batch_size, height, width, channels)
# expand_dims turns (224, 224, 3) into (1, 224, 224, 3)
input_batch = tf.expand_dims(image_tensor, axis=0)

# 4. Run prediction
predictions = prod_model.predict(input_batch)
predicted_class_index = np.argmax(predictions[0])

print(f"Raw probabilities: {predictions[0]}")
print(f"Predicted Class Index: {predicted_class_index}")

converter = tf.lite.TFLiteConverter.from_keras_model(prod_model)
tflite_model = converter.convert()

open("model.tflite", "wb").write(tflite_model)
