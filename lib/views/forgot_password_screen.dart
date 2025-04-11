import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  final _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email address to reset your password',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed:
                    _isLoading.value
                        ? null
                        : () async {
                          if (!GetUtils.isEmail(_emailController.text)) {
                            Get.snackbar(
                              'Error',
                              'Please enter a valid email',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          _isLoading.value = true;
                          try {
                            final response = await _apiService.forgotPassword(
                              _emailController.text,
                            );
                            if (response['status'] == true) {
                              Get.snackbar(
                                'Success',
                                response['message'],
                                snackPosition: SnackPosition.TOP,
                                duration: Duration(seconds: 2),
                              );
                              await Future.delayed(Duration(seconds: 2));
                              Get.back();
                            } else {
                              Get.snackbar(
                                'Error',
                                response['message'] ?? 'Something went wrong',
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              e.toString(),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } finally {
                            _isLoading.value = false;
                          }
                        },
                child:
                    _isLoading.value
                        ? CircularProgressIndicator()
                        : Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
