import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FilePickerScreen());
  }
}

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  String _result = 'No file selected';

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );

    setState(() {
      _result = result != null
          ? 'Selected: ${result.files.single.name}'
          : 'No file selected';
    });
  }

  Future<void> pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    setState(() {
      _result = path != null ? 'Directory: $path' : 'No directory selected';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Pick a File'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickDirectory,
              child: const Text('Pick a Directory'),
            ),
          ],
        ),
      ),
    );
  }
}
