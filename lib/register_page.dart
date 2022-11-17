import 'package:flutter/material.dart';
import 'package:book_scanner/main.dart';
import 'package:book_scanner/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static String routeName = '/register';

  @override
  _RegisterPageState createState() => new _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  AppDatabase db = AppDatabase();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String login = loginController.text;
      String password = passwordController.text;
      String username = usernameController.text;
      String user = await db.registerUser(username, login, password);
      if (user != "reg") {
        await _showDialogAlert("Такой пользователь уже есть, попробуйте другой логин");
        return;
      }
      await _showDialogAlert("Вы успешно зарегистрированны");
      Navigator.of(context).pop();
    }
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

  @override
  Widget build(BuildContext context) {
    final usernameField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: usernameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите имя';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Имя',
          prefixIcon: const Icon(Icons.person),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { usernameController.clear() },
          ),
          hintText: "Имя",
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

    final singUpButton = ElevatedButton(
      onPressed: _registerUser,
      child: const Text("Зарегистрироваться"),
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
              usernameField,
              loginField,
              passwordField,
              singUpButton,
            ],
          ),
        ),
      ),
    );
  }
}