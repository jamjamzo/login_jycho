import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_jycho/home_page.dart';
import 'package:login_jycho/join_page.dart';
import 'package:login_jycho/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String errormsg;
  late bool error, showprogress;
  late String username, password;
  bool autoLogin = false; // Store automatic login status

  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('isLoggedIn') == true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  Future<void> _handleLogin() async {
    // 로그인 처리
    String apiurl = "http://192.168.0.28/login.php";
    username = idController.text;
    password = passwordController.text;

    var response = await http.post(Uri.parse(apiurl), body: {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"]) {
        setState(() {
          showprogress = false;
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"]) {
          setState(() {
            error = false;
            showprogress = false;
          });

          if (autoLogin) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', true);
          }

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          showprogress = false;
          error = true;
          errormsg = "로그인에 실패했습니다.";
        }
      }
    } else {
      setState(() {
        showprogress = false;
        error = true;
        errormsg = "서버에 연결 중 오류가 발생했습니다.";
      });
    }

    // 로그인이 성공하면 로그인 상태를 설정합니다.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 로그인 성공 시 authProvider의 autoLogin 속성을 true로 설정하여 자동 로그인 상태로 표시
    authProvider.autoLogin = true;

    // Save the autoLogin state in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoLogin', authProvider.autoLogin);
  }

  void _handleLogout() async {
    // Handle logout
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인화면'),
        actions: [
          if (Provider.of<AuthProvider>(context)
              .autoLogin) // Show logout button if autoLogin is enabled
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('로그인'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinPage()),
                );
              },
              child: Text('회원가입'),
            ),
            Row(
              children: [
                Checkbox(
                  value: autoLogin,
                  onChanged: (value) {
                    setState(() {
                      autoLogin = value ?? false;
                    });
                  },
                ),
                Text('자동로그인'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
