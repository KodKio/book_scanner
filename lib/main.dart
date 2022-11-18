import 'package:book_scanner/add_review_page.dart';
import 'package:book_scanner/database.dart';
import 'package:book_scanner/edit_profile_page.dart';
import 'package:book_scanner/login_page.dart';
import 'package:book_scanner/my_reviews_page.dart';
import 'package:book_scanner/reviews_page.dart';
import 'package:book_scanner/add_book_page.dart';
import 'package:book_scanner/register_page.dart';
import 'package:book_scanner/forget_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan/scan.dart';

const String barcodeKey = "BARCODE";
const String loginKey = "LOGIN";
const String passwordKey = "PASSWORD";
const String usernameKey = "USERNAME";
const String loginedKey = "LOGINED";
const String ageKey = "AGE";

void main() {
  _prepareAndRun();
}

Future<void> _prepareAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final barcode = prefs.getInt(barcodeKey);
  runApp(MyApp(barcode: barcode));
}

class MyApp extends StatelessWidget {
  final int? barcode;
  MyApp({this.barcode, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      routes: {
        AddBookPage.routeName : (BuildContext context) => const AddBookPage(),
        LoginPage.routeName : (BuildContext context) => LoginPage(),
        ReviewsPage.routeName : (BuildContext context) => const ReviewsPage(),
        MyHomePage.routeName : (BuildContext context) => const MyHomePage(),
        RegisterPage.routeName : (BuildContext context) => const RegisterPage(),
        AddReviewPage.routeName : (BuildContext context) => const AddReviewPage(),
        MyReviewsPage.routeName : (BuildContext context) => const MyReviewsPage(),
        ForgetPage.routeName : (BuildContext context) => const ForgetPage(),
        EditProfilePage.routeName : (BuildContext context) => const EditProfilePage()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {

  static const routeName = '/home';

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _textController = TextEditingController();
  final ScanController _scanController = ScanController();
  bool _logined = false;
  String _title = "Главная";
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
      final username = prefs.getString(usernameKey);
      setState(() {
        _title = username!;
      });
    } else {
      setState(() {
        _title = "Главная";
      });
    }
  }

  Future _goToReviews() async {
    if (_textController.text.length != 13) {
      _showBadDialogAlert();
      return;
    }
    if (_textController.text != "") {
      List<Map<String, Map<String, dynamic>>> data =
        await db.fetchBookData(int.parse(_textController.text));
      if (data.length != 0) {
        Navigator.of(context).pushNamed(ReviewsPage.routeName);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(barcodeKey, int.parse(_textController.text));
      } else {
        _showDialogAlert();
      }
    }
  }

  Future<void> _goToLogin() async {
    await Navigator.of(context).pushNamed(LoginPage.routeName);
    await _initLogin();
  }

  Future<void> _goToAdd() async {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AddBookPage.routeName);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(barcodeKey, int.parse(_textController.text));
  }

  Future _showScanner() {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Scaffold(
              appBar: _buildBarcodeScannerAppBar(),
              body: _buildBarcodeScannerBody(),
            ));
        });
      },
    );
  }

  AppBar _buildBarcodeScannerAppBar() {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(color: Colors.lightBlue, height: 4.0),
      ),
      title: const Text('Отсканируйте штрихкод'),
      elevation: 0.0,
      backgroundColor: const Color(0xFF333333),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Center(
            child: Icon(
              Icons.cancel,
              color: Colors.white,
            )),
      ),
      actions: [
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
                onTap: () => _scanController.toggleTorchMode(),
                child: const Icon(Icons.flashlight_on))),
      ],
    );
  }

  Widget _buildBarcodeScannerBody() {
    return SizedBox(
      height: 400,
      child: ScanView(
        controller: _scanController,
        scanAreaScale: .7,
        scanLineColor: Colors.lightBlue,
        onCapture: (data) {
          setState(() {
            _textController.text = data;
            Navigator.of(context).pop();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Введите штрихкод:',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _textController
              )
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.blue,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.add_a_photo),
                onPressed: _showScanner,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Favorite',
                icon: const Icon(Icons.account_circle),
                onPressed: _goToLogin,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToReviews,
        tooltip: 'Go to Friends',
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
    );
  }

  Future _showBadDialogAlert() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Неверный штрихкод"),
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
                  child: const Text("Хорошо")
              )
            ],
            content: Text("Проверьте штрихкод или введите другой"),
          );
        });
  }

  Future _showDialogAlert() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("У нас такой книги нет:("),
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
                  onPressed: _goToAdd,
                  child: const Text("Да")
              ),
            ],
            content: Text("Хотите добавить?"),
          );
        });
  }
}
