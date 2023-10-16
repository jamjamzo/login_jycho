import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login_jycho/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String id = "";
  String fullName = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    loadUserInfo(); // 사용자 정보를 불러오는 함수 호출
  }

  void loadUserInfo() async {
    // 데이터베이스에서 사용자 정보를 가져오는 코드 작성
    // 이 과정은 데이터베이스와 통신이 필요하며, API나 서버와 통합해야 합니다.

    // 예를 들어, http 패키지를 사용하여 서버 API에 요청을 보내 데이터를 가져올 수 있습니다.
    final response =
        await http.get('http://192.168.0.28/read_account.php' as Uri);

    if (response.statusCode == 200) {
      // API로부터 사용자 정보를 성공적으로 가져온 경우
      final userData = json.decode(response.body);
      setState(() {
        id = userData['user_name'];
        fullName = userData['fullname'];
        address = userData['address'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        leading: GestureDetector(
          child: Icon(
            Icons.logout,
            color: Colors.black,
          ),
          onTap: () {
            // 로그아웃 처리
            _handleLogout(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ID: $id'),
            Text('Fullname: $fullName'),
            Text('Address: $address'),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    // 로그아웃 처리
    // 로컬 저장소(예: SharedPreferences)에서 로그인 상태를 false로 설정
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
