import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserController _userController = Get.find();
  bool isLoading = true;
  User? user;
  String? error;

  @override
  void initState() {
    super.initState();
    final userId = int.parse(Get.parameters['id'] ?? '0');
    _loadUser(userId);
  }

  Future<void> _loadUser(int userId) async {
    try {
      final response = await _userController.getUserById(userId);
      setState(() {
        user = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : user == null
              ? Center(child: Text('User not found'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            user?.photo != null
                                ? NetworkImage(user!.photo!)
                                : null,
                        child:
                            user?.photo == null
                                ? Icon(Icons.person, size: 50)
                                : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    DetailItem(title: 'Name', value: user!.name),
                    DetailItem(title: 'Email', value: user!.email),
                    if (user!.phone != null)
                      DetailItem(title: 'Phone', value: user!.phone!),
                    if (user!.address != null)
                      DetailItem(title: 'Address', value: user!.address!),
                  ],
                ),
              ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const DetailItem({Key? key, required this.title, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
