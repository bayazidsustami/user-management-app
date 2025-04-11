import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8006/api";
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> setStoredToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> removeStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userDataKey);
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final requestBody = json.encode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );
    final data = json.decode(response.body);
    if (data['token'] != null) {
      await setStoredToken(data['token']);
      if (data['user'] != null) {
        await storeUserData(data['user']);
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> logout() async {
    final token = await getStoredToken();
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await removeStoredToken();
    await removeUserData();
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getUsers({int page = 1, String? search}) async {
    final token = await getStoredToken();
    final queryParams = {
      'page': page.toString(),
      if (search != null) 'search': search,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/users').replace(queryParameters: queryParams),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    final token = await getStoredToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile(
    String name,
    String email,
    String phone,
    String address,
    XFile? photo,
  ) async {
    final token = await getStoredToken();
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/profile'))
          ..headers.addAll({'Authorization': 'Bearer $token'})
          ..fields.addAll({
            'name': name,
            'email': email,
            'phone': phone,
            'address': address,
          });

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return json.decode(responseBody);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      body: {'email': email},
    );
    return json.decode(response.body);
  }
}
