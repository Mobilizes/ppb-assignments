import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

late Interpreter interpreter;
late IsolateInterpreter isolateInterpreter;
late List<CameraDescription> cameras;
List<String> labels = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final labelData = await rootBundle.loadString('assets/labels.txt');
  labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();

  cameras = await availableCameras();
  interpreter = await Interpreter.fromAsset('assets/model.tflite');
  isolateInterpreter = await IsolateInterpreter.create(
    address: interpreter.address,
  );

  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  bool cameraFront = true;

  // Variables for updating the UI
  bool isProcessing = false;
  String detectedLabel = "Detecting...";
  String detectedConfidence = "";

  Future<void> _requestPermissionsAndInit() async {
    await Permission.camera.request();
    await Permission.storage.request();
    await Permission.photos.request();
    _initCamera();
  }

  void _initCamera() {
    controller = CameraController(
      cameras[cameraFront ? 1 : 0],
      ResolutionPreset.low, // Lower resolution is faster for processing
      enableAudio: false,
    );

    controller
        .initialize()
        .then((_) {
          if (!mounted) return;

          // Start the image stream here!
          controller.startImageStream((CameraImage image) {
            if (!isProcessing) {
              isProcessing = true;
              _processCameraImage(image);
            }
          });

          setState(() {});
        })
        .catchError((Object e) {
          debugPrint('Camera initialization error: $e');
        });
  }

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _processCameraImage(CameraImage cameraImage) async {
    try {
      img.Image? decodedImage;
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        decodedImage = _convertYUV420ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        decodedImage = _convertBGRA8888ToImage(cameraImage);
      }

      if (decodedImage == null) {
        isProcessing = false;
        return;
      }

      img.Image resizedImage = img.copyResize(
        decodedImage,
        width: 160,
        height: 160,
      );

      var input = List.generate(
        1,
        (b) => List.generate(
          160,
          (y) => List.generate(160, (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          }),
        ),
      );

      var output = List.generate(1, (_) => List.filled(labels.length, 0.0));

      interpreter.run(input, output);

      List<double> probabilities = output[0];
      double maxProb = 0.0;
      int maxIndex = -1;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb && probabilities[i] > 0.5) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      if (mounted && maxIndex != -1) {
        setState(() {
          detectedLabel = labels[maxIndex];
          detectedConfidence = "${(maxProb * 100).toStringAsFixed(1)}%";
        });
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      // Allow the next frame to be processed
      isProcessing = false;
    }
  }

  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final image = img.Image(width: width, height: height);

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      int uvRow = y >> 1;
      for (int x = 0; x < width; x++) {
        int uvCol = x >> 1;
        int indexY = y * yRowStride + x;
        int indexU = uvRow * uvRowStride + uvCol * uvPixelStride;
        int indexV = uvRow * uvRowStride + uvCol * uvPixelStride;

        int yp = yPlane.bytes[indexY];
        int up = uPlane.bytes[indexU];
        int vp = vPlane.bytes[indexV];

        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  img.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    String result = "$detectedLabel: $detectedConfidence";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("TFLite Detector")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
            // The caption that updates via setState()
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            cameras.length >= 2
                ? ElevatedButton(
                    onPressed: () async {
                      cameraFront = !cameraFront;
                      await controller.dispose();
                      _initCamera();
                    },
                    child: const Icon(Icons.switch_camera),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
