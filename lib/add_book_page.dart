import 'package:book_scanner/database.dart';
import 'package:book_scanner/reviews_page.dart';
import 'package:book_scanner/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  static const routeName = '/add';

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  AppDatabase db = AppDatabase();
  int _barcode = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBarcode();
    });
    super.initState();
  }

  Future<void> _initBarcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final barcode = prefs.getInt(barcodeKey);
    setState(() {
      _barcode = barcode!;
    });
  }

  Future<void> _makeBook() async {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text;
      String author = authorController.text;
      int ageLimit = int.parse(ageController.text);
      String newBook = await db.addBook(_barcode, name, author, ageLimit);
      if (newBook == 'reg')
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(ReviewsPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {

    final nameField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: nameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите название';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Название',
          prefixIcon: const Icon(Icons.book),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { nameController.clear() },
          ),
          hintText: "Название",
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

    final authorField = Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: authorController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите автора';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Автор',
          hintText: "Автор",
          prefixIcon: const Icon(Icons.accessibility),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => { authorController.clear() },
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
            return 'Введите возрастной рейтинг';
          }
          return null;
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Возрастной рейтинг',
          hintText: "Возрастной рейтинг",
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

    final submitButton = ElevatedButton(
      onPressed: _makeBook,
      child: const Text("Подтвердить"),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Введите данные"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            nameField,
            authorField,
            ageField,
            submitButton
          ],
        ),
      ),
    );
  }
}