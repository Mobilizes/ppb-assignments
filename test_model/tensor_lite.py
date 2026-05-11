import tensorflow as tf
import os

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


model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model.tflite")
interpreter = tf.lite.Interpreter(model_path=model_path)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

image_tensor = load_image("~/Pictures/Frozen-grapes-featured-image-1024x683.jpeg")

interpreter.set_tensor(input_details[0]['index'], [image_tensor])

interpreter.invoke()
output_data = interpreter.get_tensor(output_details[0]['index'])
print(output_data)
