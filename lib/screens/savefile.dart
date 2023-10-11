import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SaveToFolderScreen extends StatefulWidget {
  @override
  _SaveToFolderScreenState createState() => _SaveToFolderScreenState();
}

class _SaveToFolderScreenState extends State<SaveToFolderScreen> {
  String? _statusMessage;

  Future<void> pickFolderAndSavePdf(List<int> pdfBytes) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        setState(() {
          _statusMessage = "User canceled the picker";
        });
        return;
      }

      File outputFile = File('$selectedDirectory/output-file.pdf');
      await outputFile.writeAsBytes(pdfBytes);

      setState(() {
        _statusMessage = "Saved to $selectedDirectory/output-file.pdf";
      });
    } catch (error) {
      setState(() {
        _statusMessage = "An error occurred: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Folder and Save")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Sample PDF bytes, replace with your actual PDF byte data
                // List<int> samplePdfBytes = [...]; 
                // For the sake of this example, let's use a dummy list
                List<int> samplePdfBytes = List.generate(100, (index) => index); 
                pickFolderAndSavePdf(samplePdfBytes);
              },
              child: Text("Pick Directory & Save PDF"),
            ),
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
