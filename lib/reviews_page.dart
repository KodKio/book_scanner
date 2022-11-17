import 'package:book_scanner/add_review_page.dart';
import 'package:book_scanner/structures.dart';
import 'package:book_scanner/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_scanner/database.dart';

class ReviewsPage extends StatefulWidget {

  static const routeName = '/reviews';

  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {

  int _barcode = 0;
  MyBook _book = MyBook(0, "", "", 0);
  bool _logined = false;
  List<MyReview> _reviews = [];
  AppDatabase db = AppDatabase();


  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAsync();
    });
    super.initState();
  }

  Future<void> _initAsync() async {
    await _initBarcode();
    await _initBook();
    await _checkAge();
    await _initReviews();
  }

  Future<void> _checkAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final age = prefs.getInt(ageKey);
    if (_logined) {
      if (age! < _book.age_limit) {
        Navigator.of(context).pop();
        _showReview("Извините", "Вы ещё маленький для таких книжек:(");
      }
    }
  }

  Future<void> _initBarcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final barcode = prefs.getInt(barcodeKey);
    final logined = prefs.getBool(loginedKey);
    setState(() {
      _barcode = barcode!;
      if (logined != null) {
        _logined = logined;
      }
    });
  }

  Future<void> _initBook() async {
    List<Map<String, Map<String, dynamic>>> data = await db.fetchBookData(
        _barcode);
    MyBook book = MyBook(
        _barcode,
        data[0]["books_info"]!["name"],
        data[0]["books_info"]!["author"],
        data[0]["books_info"]!["age_limit"]
    );
    setState(() {
      _book = book;
    });
  }

  Future<void> _initReviews() async {
    List<Map<String, Map<String, dynamic>>> data = await db.fetchReviewsData(
        _barcode);
    List<MyReview> reviews = [];
    for (var elem in data) {
      reviews.add(MyReview(
          _book,
          MyUser(
              elem["books_accounts"]!["login"],
              elem["books_accounts"]!["name"],
              0
          ),
          elem["books_reviews"]!["review"]
      )
      );
    }
    setState(() {
      _reviews = reviews;
    });
  }

  Widget _buildBookInfoCard(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(10)
            ),
            height: 100,
            child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                          _book.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.left
                      ),
                      const SizedBox(height: 10),
                      Row(
                          children: [
                            Text(
                                _book.author,
                                style: const TextStyle(color: Colors.white)
                            ),
                          ]
                      )
                    ]
                )
            )
        )
    );
  }

  Future<void> _goToEditing() async {
    await Navigator.of(context).pushNamed(AddReviewPage.routeName);
    await _initReviews();
  }

  Future _showReview(String name, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
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
                child: const Text("Понятно")
            )
          ],
          content: Text(text),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Отзывы"),
        ),
        body:
        Center(
            child: (_reviews.length >= 0) ?
            ListView.separated(
              itemBuilder: _itemBuilder,
              separatorBuilder: _separatorBuilder,
              itemCount: _reviews.length + 1,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ) :
            const Text("Нет отзывов")
        ),
        floatingActionButton: (_logined) ? FloatingActionButton(
          onPressed: _goToEditing,
          child: const Icon(Icons.edit),
        ) : null
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == 0) {
      return _buildBookInfoCard(context);
    } else {
      return GestureDetector(
        onTap: () => _showReview(_reviews[index - 1].how.name, _reviews[index - 1].text),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10)
          ),
          height: 100,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                        _reviews[index - 1].how.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.left
                    ),
                    const SizedBox(height: 10),
                    Row(
                        children: [
                          Expanded(
                            child: Text(
                              _reviews[index - 1].text,
                              maxLines: null,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white)
                            ),
                          )
                        ]
                    )
                  ]
              )
          )
        )
      );
    }
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    return const SizedBox(height: 10);
  }
}
