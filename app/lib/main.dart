import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Audio Benchmarker", home: MicPage());
  }
}

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
  List<int> pcmSamples = [];
  double volume = 0;

  Future<void> startRecording() async {
    if (!await record.hasPermission()) {
      return;
    }

    final stream = await record.startStream(
      const RecordConfig(
        encoder: AudioEncoder.opus,
        sampleRate: 44100,
        numChannels: 1,
      ),
    );

    audioSubscription = stream.listen((Uint8List data) {
      List<int> samples = [];
      final byteData = ByteData.sublistView(data);

      double rms = 0;
      int maxAmpl = (1 << 15);

      for (int i = 0; i < byteData.lengthInBytes; i += 2) {
        final sample = byteData.getInt16(i, Endian.little);
        rms += sample * sample;

        samples.add(sample);
      }

      rms /= samples.length;
      rms = sqrt(rms);

      setState(() {
        pcmSamples = samples;
        if (samples.isNotEmpty) {
          volume = 20.0 * log(rms / maxAmpl) / ln10 + 90.0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: startRecording(),
      builder: (context, AsyncSnapshot<void> snapshot) {
        return Scaffold(body: Center(
          child: Text(volume.toString()),
        ));
      },
    );
  }
}
