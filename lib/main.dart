import 'package:flutter/material.dart';
import 'package:login_jycho/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthProvider()), // 상태 관리용 Provider
      ],
      child: MaterialApp(
        home: LoginPage(), // Set LoginPage as the initial page
      ),
    ),
  );
}

class AuthProvider with ChangeNotifier {
  bool autoLogin = false; // 자동 로그인 상태

  // 자동 로그인 설정 변경 메서드
  void setAutoLogin(bool value) {
    autoLogin = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
