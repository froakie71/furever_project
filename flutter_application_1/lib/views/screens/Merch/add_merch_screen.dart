import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/merch_model.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_bloc.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('merch_images')
          .child('${DateTime.now()}.jpg');

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
    }
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
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageUrl.isEmpty ? null : NetworkImage(_imageUrl),
                child:
                    _imageUrl.isEmpty
                        ? const Icon(Icons.add_photo_alternate, size: 50)
                        : null,
              ),
            ),
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
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_imageUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an image')),
                    );
                    return;
                  }

                  final merch = MerchModel(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    category: _categoryController.text,
                    imageUrl: _imageUrl,
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
