import 'dart:math';

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
  double _avgRate = 0;
  bool _logined = false;
  List<MyReview> _reviews = [];
  AppDatabase db = AppDatabase();
  bool _FromGoodToBad = true;
  Widget iconInAppBar = Icon(Icons.sort);


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
    int sum = 0;
    for (var elem in data) {
      reviews.add(MyReview(
          _book,
          MyUser(
              elem["books_accounts"]!["login"],
              elem["books_accounts"]!["name"],
              0
          ),
          elem["books_reviews"]!["review"],
          elem["books_reviews"]!["rate"]
      )
      );
      sum += reviews.last.rate;
    }

    reviews.sort((a, b) => a.rate.compareTo(b.rate));
    if (_FromGoodToBad) {
      reviews = reviews.reversed.toList();
    }

    setState(() {
      _reviews = reviews;
      _avgRate = sum / reviews.length;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              _book.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.left
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Text(
                                "${(_reviews.isNotEmpty) ? _avgRate.toStringAsFixed(2) : "0"}/5",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.right
                            )
                          )
                        ]
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

  void _changeOrder() {
    setState(() {
      _FromGoodToBad = !_FromGoodToBad;
      iconInAppBar = Transform.rotate(
        angle: (!_FromGoodToBad) ? (180 * pi / 180) : 0,
        child: const Icon(Icons.sort),
      );
    });
    _initReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Отзывы"),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: IconButton(
                    icon: iconInAppBar,
                    color: Colors.white,
                    onPressed: _changeOrder,
                  )
              )
          ],
        ),
        body:
        Center(
            child: _reviews.isNotEmpty ?
            ListView.separated(
              scrollDirection: Axis.vertical,
              itemBuilder: _itemBuilder,
              separatorBuilder: _separatorBuilder,
              itemCount: _reviews.length + 1,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ) : _buildNoRewiews(context)
        ),
        floatingActionButton: (_logined) ? FloatingActionButton(
          onPressed: _goToEditing,
          child: const Icon(Icons.edit),
        ) : null
    );
  }

  Widget _buildNoRewiews(BuildContext context) {
    return ListView(
      children: [
        _buildBookInfoCard(context),
        const Center(
          child: Text("Нет отзывов"),
        )
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == 0) {
      return _buildBookInfoCard(context);
    } else {
      final firstStar = (_reviews[index - 1].rate >= 1) ? const Icon(
        Icons.star,
        color: Colors.amber,
      ) :
      const Icon(
        Icons.star_border,
        color: Colors.amber,
      );

      final secondStar = (_reviews[index - 1].rate >= 2) ? const Icon(
        Icons.star,
        color: Colors.amber,
      ) :
      const Icon(
        Icons.star_border,
        color: Colors.amber,
      );

      final thirdStar = (_reviews[index - 1].rate >= 3) ? const Icon(
        Icons.star,
        color: Colors.amber,
      ) :
      const Icon(
        Icons.star_border,
        color: Colors.amber,
      );

      final fourthStar = (_reviews[index - 1].rate >= 4) ? const Icon(
        Icons.star,
        color: Colors.amber,
      ) :
      const Icon(
        Icons.star_border,
        color: Colors.amber,
      );

      final fifthStar = (_reviews[index - 1].rate >= 5) ? const Icon(
        Icons.star,
        color: Colors.amber,
      ) :
      const Icon(
        Icons.star_border,
        color: Colors.amber,
      );


      final numLines = '\n'.allMatches(_reviews[index - 1].text).length + 1;
      return GestureDetector(
        onTap: () => _showReview(_reviews[index - 1].how.name, _reviews[index - 1].text),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10)
          ),
          height: 100 + (numLines - 2) * 10 + 30,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_reviews[index - 1].how.name}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.left
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              firstStar,
                              const SizedBox(width: 5),
                              secondStar,
                              const SizedBox(width: 5),
                              thirdStar,
                              const SizedBox(width: 5),
                              fourthStar,
                              const SizedBox(width: 5),
                              fifthStar
                            ],
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      _reviews[index - 1].text,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white)
                    ),
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
