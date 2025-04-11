import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cross_file/cross_file.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';
      final response = await _apiService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );
      if (response['status'] == 'success') {
        Get.snackbar(
          'Success',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/login');
      } else {
        error.value = response['message'];
        Get.snackbar('Error', error.value, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      final response = await _apiService.login(email, password);
      if (response['status'] == 'success') {
        user.value = User.fromJson(response['user']);
        Get.offAllNamed('/home');
      } else {
        error.value = response['message'];
        Get.snackbar('Error', error.value, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';
      final response = await _apiService.logout();
      if (response['status'] == 'success') {
        user.value = null;
        Get.offAllNamed('/');
      } else {
        error.value = response['message'];
        Get.snackbar('Error', error.value);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<XFile?> cropImage(XFile file) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        compressQuality: 70,
        compressFormat: ImageCompressFormat.jpg,
      );

      return croppedFile != null ? XFile(croppedFile.path) : null;
    } catch (e) {
      error.value = 'Failed to crop image: $e';
      return null;
    }
  }

  Future<bool> updateProfile(
    String name,
    String email,
    String phone,
    String address,
    XFile? photo,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      XFile? processedPhoto = photo;
      if (photo != null) {
        processedPhoto = await cropImage(photo);
        if (processedPhoto == null) {
          Get.snackbar('Warning', 'Failed to process image, using original');
          processedPhoto = photo;
        }
      }

      final response = await _apiService.updateProfile(
        name,
        email,
        phone,
        address,
        processedPhoto,
      );

      if (response['status'] == 'success') {
        // Update the local user object
        user.value = User.fromJson(response['user']);
        return true;
      } else {
        error.value = response['message'] ?? 'Update failed';
        Get.snackbar('Error', error.value);
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
