import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'bloc/event_bloc.dart';
import 'bloc/event_event.dart';
import 'bloc/event_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _imageUrl = '';
  File? _imageFile;
  Uint8List? _webImage; // Add this for web support
  bool _isUploading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        if (kIsWeb) {
          // Handle web platform
          _webImage = await pickedFile.readAsBytes();
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('event_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          // Upload bytes for web
          await storageRef.putData(_webImage!);
          final downloadUrl = await storageRef.getDownloadURL();
          setState(() {
            _imageUrl = downloadUrl;
          });
        } else {
          // Handle mobile platforms
          _imageFile = File(pickedFile.path);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('event_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          // Upload file for mobile
          await storageRef.putFile(_imageFile!);
          final downloadUrl = await storageRef.getDownloadURL();
          setState(() {
            _imageUrl = downloadUrl;
          });
        }
        setState(() {
          _isUploading = false;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _imageUrl,
          fit: BoxFit.cover,
          width: 200,
          height: 200,
        ),
      );
    }

    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          _webImage!,
          fit: BoxFit.cover,
          width: 200,
          height: 200,
        ),
      );
    }

    if (!kIsWeb && _imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
          width: 200,
          height: 200,
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.add_photo_alternate, size: 50),
      onPressed: _pickImage,
    );
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      context.read<EventBloc>().add(
        CreateEvent(
          title: _titleController.text,
          location: _locationController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          time: '${_selectedTime.hour}:${_selectedTime.minute}',
          imageUrl: _imageUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventSuccess) {
          Navigator.pop(context);
        } else if (state is EventFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving event: ${state.error}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add New Event')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                ListTile(
                  title: Text('Time: ${_selectedTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildImagePreview(),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(
                          _imageUrl.isEmpty ? 'Select Image' : 'Change Image',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
