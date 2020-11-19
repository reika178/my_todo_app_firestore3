import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_todo_app_firestore3/main.dart';

// 追加用Widget
class AddTodoPage extends StatefulWidget {
  
  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  // 入力した内容
  String messageText = "";

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final FirebaseUser user = userState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // todo入力
              TextFormField(
                decoration: InputDecoration(labelText: 'Todo'),
                // initialValue: ,
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    messageText = value;
                  });
                },
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('Add'),
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String();
                    final email = user.email;//AddPostPageのデータを参照
                    // Add用ドキュメント作成
                    await Firestore.instance
                        .collection('post')//コレクションID指定
                        .document()//ドキュメントID自動生成
                        .setData({
                          'text': messageText,
                          'email': email,
                          'date': date
                        });
                    // １つ前の画面に戻る
                    Navigator.of(context).pop();
                  }
                )
              )
            ]
          )
        )
      ),
    );
  }
}
