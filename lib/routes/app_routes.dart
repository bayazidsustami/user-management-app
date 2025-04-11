import 'package:get/get.dart';
import 'package:user_management_app/screens/user_detail_screen.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/home_screen.dart';
import '../views/profile_screen.dart';
import '../views/forgot_password_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => LoginScreen()),
    GetPage(name: '/register', page: () => RegisterScreen()),
    GetPage(name: '/home', page: () => HomeScreen()),
    GetPage(
      name: '/user/:id',
      page: () => UserDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: '/profile', page: () => ProfileScreen()),
    GetPage(name: '/forgot-password', page: () => ForgotPasswordScreen()),
  ];
}
