import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController _authController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _imagePicker = ImagePicker();
  final RxString _selectedImagePath = ''.obs;

  Future<void> _pickAndCropImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (croppedFile != null) {
        _selectedImagePath.value = croppedFile.path;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill form fields with current user data
    if (_authController.user.value != null) {
      _nameController.text = _authController.user.value!.name;
      _emailController.text = _authController.user.value!.email;
      _phoneController.text = _authController.user.value!.phone ?? '';
      _addressController.text = _authController.user.value!.address ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          Obx(
            () =>
                _authController.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await _authController.updateProfile(
                            _nameController.text,
                            _emailController.text,
                            _phoneController.text,
                            _addressController.text,
                            _selectedImagePath.isNotEmpty
                                ? XFile(_selectedImagePath.value)
                                : null,
                          );
                          if (success) {
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Profile updated successfully',
                            );
                          }
                        }
                      },
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Obx(
                () => GestureDetector(
                  onTap: _pickAndCropImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _selectedImagePath.isNotEmpty
                            ? FileImage(File(_selectedImagePath.value))
                            : _authController.user.value?.photo != null
                            ? NetworkImage(_authController.user.value!.photo!)
                                as ImageProvider
                            : null,
                    child:
                        _selectedImagePath.isEmpty &&
                                _authController.user.value?.photo == null
                            ? Icon(Icons.camera_alt, size: 40)
                            : null,
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter your name'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        !GetUtils.isEmail(value ?? '') ? 'Invalid email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
