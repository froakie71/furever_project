import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/merch_model.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_bloc.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'dart:io';

import 'package:image_picker_web/image_picker_web.dart';

class AddMerchScreen extends StatefulWidget {
  const AddMerchScreen({super.key});

  @override
  State<AddMerchScreen> createState() => _AddMerchScreenState();
}

class _AddMerchScreenState extends State<AddMerchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _urlController = TextEditingController();
  String _imageUrl = '';
  XFile? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web image picking
      try {
        final media = await ImagePickerWeb.getImageAsBytes();
        if (media != null) {
          setState(() {
            _webImage = media; // media is already Uint8List
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    } else {
      // Mobile image picking
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            _imageFile = image;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb) {
      if (_webImage != null) {
        return Image.memory(
          _webImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    } else {
      if (_imageFile != null) {
        return Image.file(
          File(_imageFile!.path),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text('Select an Image', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<String> _uploadImage() async {
    if (kIsWeb && _webImage != null) {
      // Upload web image
      final ref = FirebaseStorage.instance
          .ref()
          .child('merch')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putData(
        _webImage!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } else if (!kIsWeb && _imageFile != null) {
      // Upload mobile image
      final ref = FirebaseStorage.instance
          .ref()
          .child('merch')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(_imageFile!.path));

      return await ref.getDownloadURL();
    }

    throw Exception('No image selected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Merchandise')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            GestureDetector(onTap: _pickImage, child: _buildImagePreview()),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter a description'
                          : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter a category' : null,
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter a URL' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_webImage == null && _imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an image')),
                    );
                    return;
                  }

                  final imageUrl = await _uploadImage();

                  final merch = MerchModel(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    category: _categoryController.text,
                    imageUrl: imageUrl,
                    url: _urlController.text,
                  );

                  context.read<MerchBloc>().add(AddMerch(merch));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
