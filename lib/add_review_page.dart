import 'package:book_scanner/database.dart';
import 'package:book_scanner/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_scanner/structures.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({super.key});

  static const routeName = '/add_review';

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  AppDatabase db = AppDatabase();
  TextEditingController commentController = TextEditingController();
  int _barcode = 0;
  String _login = "";
  String _myReview = "";

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initBarcode();
      await _initReviews();
    });
    super.initState();
  }

  Future<void> _initBarcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final barcode = prefs.getInt(barcodeKey);
    final login = prefs.getString(loginKey);
    setState(() {
      _barcode = barcode!;
      _login = login!;
    });
  }

  Future<void> _initReviews() async {
    List<Map<String, Map<String, dynamic>>> data = await db.fetchReviewsData(
        _barcode);
    String review = "";
    for (var elem in data) {
      if (elem["books_accounts"]!["login"] == _login) {
        review = elem["books_reviews"]!["review"];
      };
    }
    setState(() {
      _myReview = review;
    });
  }

  Future<void> _createReview() async {
    String text = commentController.text;
    if (text == "") {
      Navigator.of(context).pop();
      return;
    }
    String review = await db.createReview(_barcode, _login, text);
    if (review == "reg") {
      await _showDialogAlert("Комментарий создан");
      Navigator.of(context).pop();
    } else {
      await _updateReview();
    }
  }

  Future<void> _updateReview() async {
    String text = commentController.text;
    if (text != "") {
      String review = await db.updateReview(_barcode, _login, text);
      if (review == "reg") {
        await _showDialogAlert("Комментарий обновлен");
        Navigator.of(context).pop();
      } else {
        await _showDialogAlert("Что-то пошло не так:(");
      }
    } else {
      await _deleteReview();
    }
  }

  Future<void> _deleteReview() async {
    String review = await db.deleteReview(_barcode, _login);
    if (review == "reg") {
      await _showDialogAlert("Комментарий удален");
      Navigator.of(context).pop();
    } else {
      await _showDialogAlert("Что-то пошло не так:(");
    }
  }

  @override
  Widget build(BuildContext context) {

    commentController.text = _myReview;

    final commentField = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.5),
      child: SizedBox(
        child: TextField(
          maxLines: null,
          controller: commentController,
          decoration: InputDecoration(
              labelText: 'Коментарий',
              hintText: "Коментарий",
              suffixIcon: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () => { commentController.clear()},
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: Colors.black, width: 2.0),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              )
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Введите отзыв"),
      ),
      body: Center(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: <Widget>[
              commentField,
              ElevatedButton(
                onPressed: (_myReview == "") ? _createReview : _updateReview,
                child: const Text("Отправить"),
              ),
              ElevatedButton(
                onPressed: _deleteReview,
                child: const Text("Удалить"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                )
              )
            ],
          ),
        ),
    );
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
}