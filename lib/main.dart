import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

void main() {
  // 最初に表示するWidget
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

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = "";

  // 入力したメールアドレス・パスワード
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: InputDecoration(labelText: 'mail address'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'password'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                // ユーザー登録ボタン
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.purple,
                  textColor: Colors.white,
                  child: Text('sign up'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final AuthResult result =
                          await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      final FirebaseUser user = result.user;

                      // ユーザー情報を更新
                      userState.setUser(user);

                      // ユーザー登録に成功した場合
                      // todo画面に遷移+ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return TodoPage();
                        }),
                      );
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      setState(() {
                        infoText = "登録に失敗しました : ${e.message}";
                      });
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlineButton(
                  textColor: Colors.blue,
                  child: Text('login'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final AuthResult result =
                          await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      final FirebaseUser user = result.user;

                      // ユーザー情報を更新
                      userState.setUser(user);

                      // ログインに成功した場合
                      // todo画面に遷移+ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return TodoPage();
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      setState(() {
                        infoText = "ログインに失敗しました : ${e.message}";
                      });
                    }
                  },
                ),
              ),
            ],
          ),
         ),
        ),
    );
  }
}

// チャット画面用Widget
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
          Container(
            padding: EdgeInsets.all(8),
            child: Text('user : ${user.email}'),
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
                        key: ObjectKey(snapshot.document(documentID),
                        onDismissed: (direction) {
                          setState(() async {
                            await Firestore.instance
                                .collection('post')
                                .document(document.documentID)
                                .delete();
                          });
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(document['text']),
                            subtitle: Text(document['email']),
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
              return AddPostPage();
            }),
          );
        },
      ),
    );
  }
}

// 追加用Widget
class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
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

