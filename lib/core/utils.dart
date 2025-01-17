import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Terminal: flutter pub add file_picker

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}