import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_todo_app_firestore3/add_todo_page.dart';
import 'package:my_todo_app_firestore3/login_page.dart';
import 'package:provider/provider.dart';
import 'package:my_todo_app_firestore3/main.dart';

class TodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final FirebaseUser user = userState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              // ログアウト状態
              // 内部で保持しているセッションが初期化される
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移+todo画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
          ),
          Expanded(
            // StreamBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // todo一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: Firestore.instance
                  .collection('post')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents =
                      snapshot.data.documents;
                      // 取得したtodo一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      IconButton deleteIcon;
                      // 削除ボタンを表示
                      if (document['email'] == user.email) {
                        deleteIcon = IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            // todoのドキュメントを削除
                            await Firestore.instance
                                .collection('post')
                                .document(document.documentID)
                                .delete();
                          },
                        );
                      }
                      return Dismissible(
                        key: Key(document.documentID),
                        onDismissed: (direction) async {
                            await Firestore.instance
                                .collection('post')
                                .document(document.documentID)
                                .delete();
                        },
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return AddTodoPage();
                                }),
                              );
                            },
                            title: Text(document['text']),
                            subtitle: Text(document['date']),
                            trailing: deleteIcon,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                // データが読み込み中の場合
                return Center(
                  child: Text('loading...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 追加画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddTodoPage();
            }),
          );
        },
      ),
    );
  }
}