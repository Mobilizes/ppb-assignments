import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import 'package:app/scope_painter.dart';
import 'package:app/repositories/history_repository.dart';

class MicPage extends StatefulWidget {
  const MicPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MicPageState();
  }
}

class _MicPageState extends State<MicPage> {
  AudioRecorder record = AudioRecorder();
  StreamSubscription? audioSubscription;
  bool isRecording = false;
  List<double> samples = [];
  double volume = 0;

  Future<void> startRecording() async {
    if (!await record.hasPermission()) {
      return;
    }

    setState(() {
      isRecording = true;
    });

    final stream = await record.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      ),
    );

    audioSubscription = stream.listen((Uint8List data) {
      final byteData = ByteData.sublistView(data);

      List<double> temp = [];

      int sumSamples = 0;
      int maxAmpl = (1 << 15);

      for (int i = 0; i < byteData.lengthInBytes; i += 4) {
        final left = byteData.getInt16(i, Endian.little);
        final right = byteData.getInt16(i + 2, Endian.little);

        sumSamples += left * left;
        sumSamples += right * right;

        final mono = (left + right) / 2;
        temp.add(mono / maxAmpl);
      }

      double rms = sqrt(sumSamples / (samples.length * 2));

      setState(() {
        samples = temp;
        if (samples.isNotEmpty) {
          volume = 20.0 * log(rms / maxAmpl) / ln10 + 90.0;
        }
      });
    });
  }

  Future<void> stopRecording() async {
    await audioSubscription?.cancel();
    await record.stop();
    setState(() {
      isRecording = false;
      volume = 0.0;
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

  MaterialColor getDbTextColor() {
    if (volume < 55.0) {
      return Colors.green;
    }
    if (volume < 90.0) {
      return Colors.yellow;
    }
    return Colors.red;
  }

  @override
  void dispose() {
    audioSubscription?.cancel();
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyRespository = context.watch<HistoryRepository>();

    return MaterialApp(
      title: "Audio Volume Tracker",
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("Audio Volume Tracker"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "Top UI Section",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "DB: ${volume.toStringAsFixed(1)}",
                      style: TextStyle(fontSize: 24, color: getDbTextColor()),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 100,
                      child: CustomPaint(
                        painter: ScopePainter(channel: samples),
                      ),
                    ),
                    const SizedBox(height: 100),
                    ElevatedButton(
                      onPressed: toggleRecording,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                        backgroundColor: isRecording ? Colors.red : Colors.blue,
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

