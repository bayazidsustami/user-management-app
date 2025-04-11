import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                        !GetUtils.isEmail(value ?? '')
                            ? 'Please enter a valid email'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        (value?.length ?? 0) < 6
                            ? 'Password must be at least 6 characters'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        value != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
              ),
              SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      _authController.isLoading.value
                          ? null
                          : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _authController.register(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                                _confirmPasswordController.text,
                              );
                            }
                          },
                  child:
                      _authController.isLoading.value
                          ? CircularProgressIndicator()
                          : Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
