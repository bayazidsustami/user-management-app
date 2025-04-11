import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final UserController _userController = Get.put(UserController());
  final AuthController _authController = Get.find();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _userController.searchUsers,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_userController.error.isNotEmpty) {
                return Center(child: Text(_userController.error.value));
              }

              return RefreshIndicator(
                onRefresh: () => _userController.fetchUsers(refresh: true),
                child: ListView.builder(
                  itemCount: _userController.users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _userController.users.length) {
                      if (_userController.isLoading.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (_userController.hasMore.value) {
                        _userController.fetchUsers();
                      }
                      return SizedBox();
                    }

                    final user = _userController.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user.photo != null
                                ? NetworkImage(user.photo!)
                                : null,
                        child:
                            user.photo == null
                                ? Text(user.name[0].toUpperCase())
                                : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () {
                        Get.toNamed(
                          '/user/${user.id}',
                          preventDuplicates: true,
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
