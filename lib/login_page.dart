import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_jycho/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:login_jycho/join_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String errormsg;
  late bool error, showprogress;
  late String username, password;

  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // apiurl = "http://192.168.1.22/login.php";
  Future<bool> startLogin() async {
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
        return false; // 로그인 실패
      } else {
        if (jsondata["success"]) {
          setState(() {
            error = false;
            showprogress = false;
          });
          // 로그인에 성공한 경우
          // 여기에서 필요한 처리를 추가하세요.
          return true; // 로그인 성공
        } else {
          showprogress = false;
          error = true;
          errormsg = "로그인에 실패했습니다.";
          return false; // 로그인 실패
        }
      }
    } else {
      setState(() {
        showprogress = false;
        error = true;
        errormsg = "서버에 연결 중 오류가 발생했습니다.";
      });
      return false; // 로그인 실패
    }
  }

  @override
  void initState() {
    username = "";
    password = "";
    errormsg = "";
    error = false;
    showprogress = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 화면'),
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
              onPressed: () {
                startLogin().then((success) {
                  if (success) {
                    // 로그인 성공 시 다음 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    // 로그인 실패 시 오류 메시지를 표시
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('로그인 실패'),
                          content: Text(errormsg), // 오류 메시지 표시
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // 팝업 닫기
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
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
          ],
        ),
      ),
    );
  }
}
