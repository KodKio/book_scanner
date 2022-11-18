import 'package:book_scanner/edit_profile_page.dart';
import 'package:book_scanner/forget_page.dart';
import 'package:book_scanner/my_reviews_page.dart';
import 'package:book_scanner/register_page.dart';
import 'package:flutter/material.dart';
import 'package:book_scanner/main.dart';
import 'package:book_scanner/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String routeName = '/login';

  @override
  _LoginPageState createState() => new _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _logined = false;
  String _login = "";
  String _username = "";
  int _age = 0;
  AppDatabase db = AppDatabase();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLogin();
    });
  }

  Future<void> _initLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final logined = prefs.getBool(loginedKey);
    setState(() {
      if (logined != null) {
        _logined = logined;
      }
    });
    if (_logined) {
      final age = prefs.getInt(ageKey);
      final username = prefs.getString(usernameKey);
      final login = prefs.getString(loginKey);
      setState(() {
        _age = age!;
        _username = username!;
        _login = login!;
      });
    }
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      String login = loginController.text;
      String password = passwordController.text;
      var user = await db.loginUser(login, password);
      if (user.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(usernameKey, user[0]["books_accounts"]!["name"]);
        prefs.setString(loginKey, user[0]["books_accounts"]!["login"]);
        prefs.setString(passwordKey, user[0]["books_accounts"]!["password"]);
        prefs.setInt(ageKey, user[0]["books_accounts"]!["age"]);
        prefs.setBool(loginedKey, true);
        Navigator.of(context).pop();
      } else {
        _showDialogAlert("У нас нет таких:(");
      }
    }
  }

  Future<void> _deleteProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(usernameKey, "");
    prefs.setString(loginKey, "");
    prefs.setString(passwordKey, "");
    prefs.setInt(ageKey, 0);
    prefs.setBool(loginedKey, false);
    db.deleteUser(_login);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    _showDialogAlert("Аккаунт удалён");
  }

  Future<void> _goToRegister() async {
    Navigator.of(context).pushNamed(RegisterPage.routeName);
  }

  Future<void> _goToForgetPassword() async {
    Navigator.of(context).pushNamed(ForgetPage.routeName);
  }

  Future _showDialogAlert(String text) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(text),
            titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20
            ),
            actionsOverflowButtonSpacing: 20,
            actions: [
              ElevatedButton(
                  onPressed: () =>
                      Future.delayed(Duration.zero, () {
                        Navigator.of(context).pop();
                      }),
                  child: const Text("Ок")
              ),
            ],
          );
        });
  }

  Future _showDeleteAlert() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Удаление аккаунта"),
            titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20
            ),
            actionsOverflowButtonSpacing: 20,
            actions: [
              ElevatedButton(
                  onPressed: () => Future.delayed(Duration.zero, () {
                    Navigator.of(context).pop(); }),
                  child: const Text("Нет")
              ),
              ElevatedButton(
                  onPressed: _deleteProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                  ),
                  child: const Text("Да")
              ),
            ],
            content: const Text("Точно хотите удалить?"),
          );
        });
  }

  Widget buildLoginForm(BuildContext context) {
    final loginField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: loginController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите логин';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Логин',
          prefixIcon: const Icon(Icons.person),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { loginController.clear() },
          ),
          hintText: "Логин",
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide:
            BorderSide(color: Colors.deepOrangeAccent, width: 2.0),
          ),
        ),
      ),
    );

    final passwordField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        obscureText: true,
        controller: passwordController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите пароль';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Пароль',
          hintText: "Пароль",
          prefixIcon: const Icon(Icons.password),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { passwordController.clear() },
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide:
            BorderSide(color: Colors.deepOrangeAccent, width: 2.0),
          ),
        ),
      ),
    );

    final loginButton = ElevatedButton(
      onPressed: _loginUser,
      child: const Text("Войти"),
    );


    final singUpButon = TextButton(
        onPressed: _goToRegister,
        child: const Text("Зарегистрироваться")
    );

    final forgetPasswordButton = TextButton(
        onPressed: _goToForgetPassword,
        child: const Text("Забыли пароль?")
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Введите данные аккаунта"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: <Widget>[
              loginField,
              passwordField,
              loginButton,
              singUpButon,
              forgetPasswordButton
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(usernameKey, "");
    prefs.setString(loginKey, "");
    prefs.setString(passwordKey, "");
    prefs.setBool(loginedKey, false);
    Navigator.of(context).pop();
  }

  Future<void> _goToMyReviews() async {
    Navigator.of(context).pushNamed(MyReviewsPage.routeName);
  }

  Future<void> _goToEditing() async {
    await Navigator.of(context).pushNamed(EditProfilePage.routeName);
    _initLogin();
  }

  Widget buildOutForm(BuildContext context) {

    final myReviewsButton = ElevatedButton(
      onPressed: _goToMyReviews,
      child: const Text("Мои отзывы"),
    );

    final deleteButton = ElevatedButton(
      onPressed: () => {
        _showDeleteAlert()
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red
      ),
      child: const Text("Удалить аккаунт"),
    );

    final loginInfo = Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Логин:",
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Text(
                              _login,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        ),
                      )
                    ]
                )
            )
        )
    );

    final usernameInfo = Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Имя:",
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Text(
                              _username,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        ),
                      )
                    ]
                )
            )
        )
    );

    final ageInfo = Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Возраст:",
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
              const SizedBox(height: 5),
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Text(
                      "$_age",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    )
                ),
              )
            ]
          )
        )
      )
    );

    final profileCard = Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 5),
          children: <Widget>[
            loginInfo,
            usernameInfo,
            ageInfo
          ],
        )
      )
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ваш Аккаунт"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.white,
                onPressed: _logout,
              )
            )
          )
        ],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: <Widget>[
              profileCard,
              const SizedBox(height: 20),
              myReviewsButton,
              deleteButton
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToEditing,
        child: const Icon(Icons.edit),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_logined) {
      return buildOutForm(context);
    } else {
      return buildLoginForm(context);
    }
  }
}