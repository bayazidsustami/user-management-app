import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      users.clear();
    }

    if (!hasMore.value && !refresh) return;

    try {
      isLoading.value = true;
      error.value = '';
      final response = await _apiService.getUsers(
        page: currentPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response['status'] == 'success') {
        final userData = response['users']['data'] as List;
        final newUsers = userData.map((json) => User.fromJson(json)).toList();
        users.addAll(newUsers);

        hasMore.value = response['users']['next_page_url'] != null;
        if (hasMore.value) currentPage.value++;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<User> getUserById(int userId) async {
    try {
      final response = await _apiService.getUserById(userId);
      if (response['status'] == 'success') {
        return User.fromJson(response['user']);
      } else {
        throw response['message'] ?? 'Failed to get user details';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    fetchUsers(refresh: true);
  }
}
