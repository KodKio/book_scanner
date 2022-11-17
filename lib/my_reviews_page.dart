import 'package:book_scanner/structures.dart';
import 'package:book_scanner/main.dart';
import 'package:book_scanner/reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_scanner/database.dart';

class MyReviewsPage extends StatefulWidget {

  static const routeName = '/my_reviews';

  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {

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
    await _initReviews();
  }

  Future<void> _initReviews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(loginKey);
    List<Map<String, Map<String, dynamic>>> data = await db.fetchUserReviewsData(
        login!);
    List<MyReview> reviews = [];
    for (var elem in data) {
      reviews.add(MyReview(
          MyBook(
            elem["books_info"]!["barcode"],
            elem["books_info"]!["name"],
            elem["books_info"]!["author"],
            elem["books_info"]!["age_limit"]
          ),
          MyUser(
              login,
              "",
              0,
          ),
          elem["books_reviews"]!["review"]
      )
      );
    }
    setState(() {
      _reviews = reviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Мои отзывы"),
        ),
        body:
        Center(
            child: (_reviews.length >= 0) ?
            ListView.separated(
              itemBuilder: _itemBuilder,
              separatorBuilder: _separatorBuilder,
              itemCount: _reviews.length,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ) :
            const Text("У вас нет отзывов отзывов")
        )
    );
  }

  Future<void> _goToReviews(int barcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final last_barcode = prefs.getInt(barcodeKey);
    prefs.setInt(barcodeKey, barcode);
    await Navigator.of(context).pushNamed(ReviewsPage.routeName);
    if (last_barcode != null) {
      prefs.setInt(barcodeKey, last_barcode);
    }
    await _initReviews();
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return GestureDetector(
        onTap: () => _goToReviews(_reviews[index].book.barcode),
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
                          _reviews[index].book.name,
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
                                  _reviews[index].text,
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

  Widget _separatorBuilder(BuildContext context, int index) {
    return const SizedBox(height: 10);
  }
}
