import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:app/repositories/history_repository.dart';
import 'package:app/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';

class MicPage extends StatefulWidget {
  const MicPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MicPageState();
  }
}

class ScopePainter extends CustomPainter {
  final List<double> channel;
  final Color lineColor;

  ScopePainter({required this.channel, this.lineColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final sectionHeight = size.height;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    List<Offset> points = [];

    if (channel.isEmpty) return;

    double xStep = size.width / channel.length;

    for (int i = 0; i < channel.length; i++) {
      double x = i * xStep;

      double y = sectionHeight - (channel[i] * sectionHeight);
      points.add(Offset(x, y));
    }

    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant ScopePainter oldDelegate) => true;
}

class _MicPageState extends State<MicPage> {
  AudioRecorder record = AudioRecorder();
  StreamSubscription? audioSubscription;

  bool isRecording = false;
  List<double> samples = [];
  Queue<double> volumeBuffer = Queue();
  double _maxDbDuringHigh = 0.0;
  bool _isHighDb = false;
  bool _canVibrate = false;
  DateTime? _lastVibrationTime;

  final int volumeBufferLength = 4;
  final double safeVolumeLimit = 55.0;
  final double warningVolumeLimit = 77.5;

  @override
  Widget build(BuildContext context) {
    final double currentVolume = getAverageVolume();
    final bool isWarning =
        currentVolume >= safeVolumeLimit && currentVolume < warningVolumeLimit;
    final bool isLoud = currentVolume >= warningVolumeLimit;

    Color volumeColor = Colors.green;
    if (isWarning) volumeColor = Colors.orange;
    if (isLoud) volumeColor = Colors.red;

    final String statusText = isLoud
        ? "Level: LOUD!"
        : (isWarning ? "Level: Warning" : "Level: Safe");

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Voice Volume Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: volumeColor.withAlpha(10),
                        border: Border.all(color: volumeColor, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: volumeColor.withAlpha(20),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentVolume.isFinite
                                ? currentVolume.toStringAsFixed(1)
                                : '0.0',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: volumeColor,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            "dB",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: volumeColor.withAlpha(80),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: volumeColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: volumeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                      child: CustomPaint(
                        painter: ScopePainter(
                          channel: samples,
                          lineColor: volumeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton.large(
                onPressed: toggleRecording,
                backgroundColor: isRecording
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioSubscription?.cancel();
    record.dispose();
    super.dispose();
  }

  double getAverageVolume() {
    if (volumeBuffer.length < volumeBufferLength / 2) {
      return 0;
    }

    double sum = 0.0;
    for (double vol in volumeBuffer) {
      sum += vol;
    }

    return sum / volumeBuffer.length;
  }

  Future<void> startRecording() async {
    if (!await record.hasPermission()) {
      return;
    }

    _canVibrate = await Vibration.hasVibrator();
    if (_canVibrate) {
      Vibration.vibrate(duration: 300, amplitude: 128);
    }

    setState(() {
      isRecording = true;
    });

    final stream = await record.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
        noiseSuppress: true,
      ),
    );

    audioSubscription = stream.listen((Uint8List data) {
      final byteData = ByteData.sublistView(data);

      List<double> temp = [];

      int sumSamples = 0;
      int maxAmpl = (1 << 15);

      for (int i = 0; i < byteData.lengthInBytes; i += 2) {
        final sample = byteData.getInt16(i, Endian.little);
        sumSamples += sample * sample;
        temp.add(sample / maxAmpl);
      }

      double rms = temp.isNotEmpty ? sqrt(sumSamples / temp.length) : 0.0;

      setState(() {
        samples = temp;
        if (samples.length > 100) {
          double volume = 0.0;
          if (rms > 0) {
            volume = 20.0 * log(rms / maxAmpl) / ln10 + 90.0;
          }

          volumeBuffer.add(volume);
          if (volumeBuffer.length > volumeBufferLength) {
            volumeBuffer.removeFirst();
          }

          double averageVolume = getAverageVolume();
          if (averageVolume >= warningVolumeLimit) {
            if (!_isHighDb) {
              debugPrint("Volume high detected: $averageVolume dB");
              _isHighDb = true;
            }
            if (averageVolume > _maxDbDuringHigh) {
              _maxDbDuringHigh = averageVolume;
            }
          } else if (_isHighDb && averageVolume < warningVolumeLimit) {
            debugPrint(
              "Volume dropped below limit. Saving history: $_maxDbDuringHigh dB",
            );
            context.read<HistoryRepository>().addHistory(_maxDbDuringHigh);
            _isHighDb = false;
            _maxDbDuringHigh = 0.0;
          }
        }
      });

      if (_isHighDb) {
        final now = DateTime.now();
        if (_canVibrate &&
            (_lastVibrationTime == null ||
                now.difference(_lastVibrationTime!).inMilliseconds > 500)) {
          Vibration.vibrate(amplitude: 256);
          _lastVibrationTime = now;

          NotificationService.createNotification(
            id: 1,
            title: "So loud!",
            body: "Please turn down your voice!",
          );
        }
      }
    });
  }

  Future<void> stopRecording() async {
    if (_canVibrate) {
      Vibration.vibrate(duration: 300, amplitude: 128);
    }

    await audioSubscription?.cancel();
    await record.stop();

    if (!mounted) return;

    if (_isHighDb && _maxDbDuringHigh > 0) {
      debugPrint(
        "Stopping recording during high volume. Saving: $_maxDbDuringHigh dB",
      );
      context.read<HistoryRepository>().addHistory(_maxDbDuringHigh);
    }

    setState(() {
      isRecording = false;
      _isHighDb = false;
      _maxDbDuringHigh = 0.0;
      volumeBuffer.clear();
      samples = List.filled(samples.length, 0.0);
    });
  }

  Future<void> toggleRecording() async {
    if (isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }
}
