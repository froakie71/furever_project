import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/rescue_report/rescue_report_bloc.dart';
import 'package:flutter_application_1_user/bloc/rescue_report/rescue_report_event.dart';
import 'package:flutter_application_1_user/bloc/rescue_report/rescue_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RescueReportScreen extends StatefulWidget {
  const RescueReportScreen({super.key});

  @override
  State<RescueReportScreen> createState() => _RescueReportScreenState();
}

class _RescueReportScreenState extends State<RescueReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Dog for Rescue')),
      body: BlocConsumer<RescueReportBloc, RescueReportState>(
        listener: (context, state) {
          if (state is RescueReportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted successfully')),
            );
            Navigator.pop(context);
          } else if (state is RescueReportError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child:
                          _image != null
                              ? Image.file(_image!, fit: BoxFit.cover)
                              : const Center(
                                child: Text('Tap to take a photo'),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter the address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _landmarkController,
                    decoration: const InputDecoration(
                      labelText: 'Landmark',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a landmark';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your contact number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your phone number';
                      }
                      // Add phone number validation if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        state is RescueReportLoading
                            ? null
                            : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (_image == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please take a photo'),
                                    ),
                                  );
                                  return;
                                }
                                context.read<RescueReportBloc>().add(
                                  SubmitRescueReport(
                                    address: _addressController.text,
                                    landmark: _landmarkController.text,
                                    imagePath: _image!.path,
                                    phoneNumber: _phoneNumberController.text,
                                  ),
                                );
                              }
                            },
                    child:
                        state is RescueReportLoading
                            ? const CircularProgressIndicator()
                            : const Text('Submit Report'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
