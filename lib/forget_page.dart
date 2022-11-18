import 'package:flutter/material.dart';
import 'package:book_scanner/database.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  static String routeName = '/forget';

  @override
  _ForgetPageState createState() => new _ForgetPageState();

}

class _ForgetPageState extends State<ForgetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController secondPasswordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool _found = false;
  AppDatabase db = AppDatabase();

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      String login = loginController.text;
      String password = passwordController.text;
      String result = await db.updateUserPassword(login, password);
      if (result == "reg") {
        await _showDialogAlert("Ваш пароль обновлён");
        Navigator.of(context).pop();
      } else {
        _showDialogAlert("Что-то пошло не так:(");
      }
    }
  }

  Future<void> _check() async {
    if (_formKey.currentState!.validate()) {
      String login = loginController.text;
      int age = int.parse(ageController.text);
      bool found = await db.foundUserByLoginAndAge(login, age);
      if (found) {
        setState(() {
          _found = true;
        });
      } else {
        _showDialogAlert("У нас нет таких:(");
      }
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
    final loginField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: loginController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите свой логин';
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
            return 'Введите новый пароль';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Новый пароль',
          hintText: "Новый пароль",
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

    final secondPasswordField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        obscureText: true,
        controller: secondPasswordController,
        validator: (value) {
          if (value!.isEmpty) {
            return "Введите пароль еще раз";
          } else if (value != passwordController.text) {
            return 'Пароли не совпадают';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Повторите пароль',
          hintText: "Повторите пароль",
          prefixIcon: const Icon(Icons.password),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { secondPasswordController.clear() },
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

    final ageField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: ageController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите свой возраст, который указывали при регистрации';
          }
          return null;
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Ваш возраст',
          hintText: "Ваш возраст",
          prefixIcon: const Icon(Icons.date_range),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { ageController.clear() },
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

    final updatePasswordButton = ElevatedButton(
      onPressed: _updatePassword,
      child: const Text("Востановить"),
    );

    final checkButton = ElevatedButton(
      onPressed: _check,
      child: const Text("Проверить"),
    );

    List<Widget> getListItems() {
      if (!_found) {
        return [loginField, ageField, checkButton];
      } else {
        return [passwordField, secondPasswordField, updatePasswordButton];
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Востановление пароля"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: getListItems(),
          ),
        ),
      ),
    );
  }
}