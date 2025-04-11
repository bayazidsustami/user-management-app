import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      _authController.isLoading.value
                          ? null
                          : () => _authController.login(
                            _emailController.text,
                            _passwordController.text,
                          ),
                  child:
                      _authController.isLoading.value
                          ? CircularProgressIndicator()
                          : Text('Login'),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: Text('Don\'t have an account? Register'),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/forgot-password'),
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
