// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/merch_model.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_bloc.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
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
  XFile? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      try {
        final media = await ImagePickerWeb.getImageAsBytes();
        if (media != null) {
          setState(() {
            _webImage = media;
          });
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    } else {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _imageFile = image;
          });
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImageWidget(),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb && _webImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_webImage!, fit: BoxFit.cover),
          _buildImageOverlay(),
        ],
      );
    } else if (!kIsWeb && _imageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_imageFile!.path), fit: BoxFit.cover),
          _buildImageOverlay(),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Select an Image',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildImageOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: const Center(
        child: Icon(Icons.edit, color: Colors.white, size: 32),
      ),
    );
  }

  Future<String> _uploadImage() async {
    if (kIsWeb && _webImage != null) {
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
      final ref = FirebaseStorage.instance
          .ref()
          .child('merch')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(_imageFile!.path));

      return await ref.getDownloadURL();
    }

    throw Exception('No image selected');
  }

  Future<void> _saveMerch() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_webImage == null && _imageFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an image')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final imageUrl = await _uploadImage();

        final merch = MerchModel(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          imageUrl: imageUrl,
          url: _urlController.text,
        );

        if (!mounted) return;
        context.read<MerchBloc>().add(AddMerch(merch));
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Merchandise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a description'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a category'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a URL'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveMerch,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Save Merchandise',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
