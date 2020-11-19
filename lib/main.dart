import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_todo_app_firestore3/login_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// 更新可能なデータ
class UserState extends ChangeNotifier {
  FirebaseUser user;

  void setUser(FirebaseUser newUser) {
    user = newUser;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  // ユーザーの情報を管理するデータ
  final UserState userState = UserState();

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を渡す
    return ChangeNotifierProvider<UserState>.value(
      value: userState,
      child: MaterialApp(
        // ラベルを消す
        debugShowCheckedModeBanner: false,
        // アプリ名
        title: 'MyTodoApp',
        theme: ThemeData(
          // テーマカラー
          primaryColor: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // ログイン画面を表示
        home: LoginPage(),
      ),
    );
  }
}