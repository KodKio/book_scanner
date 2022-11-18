import 'package:flutter/material.dart';
import 'package:book_scanner/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_scanner/main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static String routeName = '/edit_profile';

  @override
  _EditProfilePageState createState() => new _EditProfilePageState();

}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController secondPasswordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool _changePassword = false;
  String _login = "";
  String _username = "";
  int _age = 0;
  String _password = "";
  AppDatabase db = AppDatabase();


  @override
  void initState() {
    _initData();
    super.initState();
  }

  Future<void> _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(loginKey);
    final username = prefs.getString(usernameKey);
    final age = prefs.getInt(ageKey);
    final password = prefs.getString(passwordKey);
    setState(() {
      _login = login!;
      _username = username!;
      _age = age!;
      _password = password!;
    });
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      String password = _changePassword ? passwordController.text : _password;
      String username = usernameController.text;
      int age = int.parse(ageController.text);
      print(_login);
      print(password);
      print(username);
      print(age);
      String result = await db.updateUser(_login, username, password, age);
      if (result == "reg") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(usernameKey, username);
        prefs.setInt(ageKey, age);
        prefs.setString(passwordKey, password);
        await _showDialogAlert("Ваш данные обновлёны");
        Navigator.of(context).pop();
      } else {
        _showDialogAlert("Что-то пошло не так:(");
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

    usernameController.text = _username;
    ageController.text = "$_age";

    final usernameField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: usernameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите новое имя';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Новое имя',
          prefixIcon: const Icon(Icons.person),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { usernameController.clear() },
          ),
          hintText: "Новое имя",
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
            return 'Введите новый возраст';
          }
          return null;
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Новый возраст',
          hintText: "Новый возраст",
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

    final updateButton = ElevatedButton(
      onPressed: _updateUserInfo,
      child: const Text("Обновить"),
    );

    final changePasswordButton = ElevatedButton(
      onPressed: () => {
        setState(() {
          _changePassword = !_changePassword;
        })
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red
      ),
      child: const Text("Поменять пароль"),
    );

    final changePasswordBackButton = ElevatedButton(
      onPressed: () => {
        setState(() {
          _changePassword = !_changePassword;
        })
      },
      child: const Text("Не менять пароль"),
    );

    List<Widget> getListItems() {
      List<Widget> result = [usernameField, ageField];
      if (_changePassword) {
        result.add(passwordField);
        result.add(secondPasswordField);
        result.add(changePasswordBackButton);
      } else {
        result.add(changePasswordButton);
      }
      result.add(updateButton);
      return result;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Изменение данных"),
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