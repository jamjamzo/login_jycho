import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_jycho/login_page.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String errorMessage = '';

  bool passwordMismatch = false; // 비밀번호 불일치 여부를 나타내는 변수
  bool isIdDuplicate = false;

  Future<bool> checkDuplicateId() async {
    String apiUrl =
        "http://192.168.0.28/id_duplicate_check.php"; // PHP 스크립트가 호스팅된 주소로 변경

    var response = await http.post(Uri.parse(apiUrl), body: {
      'username': idController.text,
    });

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData["error"]) {
        setState(() {
          errorMessage = jsonData["message"];
        });
        return false; // 아이디 중복
      } else {
        setState(() {
          errorMessage = "사용 가능한 아이디입니다.";
        });
        return true; // 아이디 중복이 아님
      }
    } else {
      setState(() {
        errorMessage = "서버 연결 중 오류가 발생했습니다.";
      });
      return false;
    }
  }

  Future<void> registerUser() async {
    final url = Uri.parse("http://192.168.0.28/join.php");
    final response = await http.post(url, body: {
      'username': idController.text,
      'password': passwordController.text,
      'fullname': nameController.text,
      'address': addressController.text,
    });

    if (response.statusCode == 200) {
      // 서버에서 온 응답을 처리할 수 있습니다.
      print("User registered successfully");
    } else {
      // 오류 처리
      print("Error registering user");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                checkDuplicateId().then((isDuplicate) {
                  if (!isDuplicate) {
                    isIdDuplicate =
                        true; // 아이디 중복이 아닌 경우 isIdDuplicate를 true로 설정
                    // 여기서 다음 단계 수행
                  } else {
                    isIdDuplicate = false;
                  }
                });
              },
              child: Text('아이디 중복 체크'),
            ),
            SizedBox(height: 10.0),
            Text(
              idController.text.isNotEmpty
                  ? !isIdDuplicate
                      ? '중복되지 않은 아이디입니다.'
                      : '중복된 아이디입니다.'
                  : '',
              style: TextStyle(
                color: isIdDuplicate ? Colors.red : Colors.green,
              ),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value) {
                setState(() {
                  passwordMismatch =
                      passwordController.text != confirmPasswordController.text;
                });
              },
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password 확인',
              ),
              onChanged: (value) {
                setState(() {
                  passwordMismatch =
                      passwordController.text != confirmPasswordController.text;
                });
              },
            ),
            SizedBox(height: 10.0),
            Text(
              passwordController.text.isNotEmpty &&
                      confirmPasswordController.text.isNotEmpty
                  ? passwordController.text == confirmPasswordController.text
                      ? '비밀번호가 일치합니다.'
                      : '비밀번호가 불일치합니다.'
                  : '',
              style: TextStyle(
                color: passwordMismatch ? Colors.red : Colors.green,
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!isIdDuplicate) {
                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    passwordMismatch = false; // 비밀번호가 일치하는 경우
                    if (idController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty &&
                        confirmPasswordController.text.isNotEmpty &&
                        nameController.text.isNotEmpty &&
                        addressController.text.isNotEmpty) {
                      registerUser(); // database 행 추가
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('회원가입 완료'),
                            content: Text('회원가입을 축하드립니다.'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // 필드 미입력 시 오류 메시지 표시
                      errorMessage = '내용을 모두 입력해주세요.';
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('오류'),
                            content: Text(errorMessage),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    passwordMismatch = true; // 비밀번호가 불일치하는 경우
                    // 비밀번호 불일치 시 오류 메시지 표시
                    errorMessage = '비밀번호를 확인해주세요.';
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('오류'),
                          content: Text(errorMessage),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // 아이디 중복 시 오류 메시지 표시
                  errorMessage = '아이디를 확인해주세요.';
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('오류'),
                        content: Text(errorMessage),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('완료'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 취소 버튼을 누르면 이전 페이지로 이동
              },
              child: Text('취소'),
            ),
          ],
        ),
      ),
    );
  }
}
