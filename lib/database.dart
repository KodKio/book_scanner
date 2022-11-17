import 'package:postgres/postgres.dart';

class AppDatabase {

  PostgreSQLConnection connection = PostgreSQLConnection(
    '195.19.32.74',
    5432,
    'fn1132_2022',
    username: 'student',
    password: 'bmstu',
  );

  AppDatabase();

  // Fetch Data Section
  List<Map<String, Map<String, dynamic>>> fetchBookDataFuture = [];
  Future<List<Map<String, Map<String, dynamic>>>> fetchBookData(int barcode) async {
    if (connection.isClosed) {
      await connection.open();
    }
    fetchBookDataFuture = await connection.mappedResultsQuery(
        'SELECT bi.name, bi.author FROM books_info bi WHERE barcode = @barcode',
        substitutionValues: {'barcode': barcode}
    );
    return fetchBookDataFuture;
  }

  List<Map<String, Map<String, dynamic>>> fetchReviewsDataFuture = [];
  Future<List<Map<String, Map<String, dynamic>>>> fetchReviewsData(int book) async {
    if (connection.isClosed) {
      await connection.open();
    }
    fetchReviewsDataFuture = await connection.mappedResultsQuery(
        'SELECT bi.name, ba.login, ba.name, br.review FROM books_reviews br JOIN books_accounts ba ON ba.login = br.how JOIN books_info bi ON bi.barcode = br.book WHERE br.book = @book',
        substitutionValues: {'book': book}
    );
    return fetchReviewsDataFuture;
  }

  List<Map<String, Map<String, dynamic>>> fetchUserReviewsDataFuture = [];
  Future<List<Map<String, Map<String, dynamic>>>> fetchUserReviewsData(String login) async {
    if (connection.isClosed) {
      await connection.open();
    }
    fetchUserReviewsDataFuture = await connection.mappedResultsQuery(
        'SELECT bi.name, bi.author, bi.age_limit, br.review, bi.barcode FROM books_reviews br JOIN books_info bi ON bi.barcode = br.book WHERE br.how = @login',
        substitutionValues: {'login': login}
    );
    return fetchUserReviewsDataFuture;
  }

  String newBookFuture = '';
  Future<String> addBook(
      int barcode, String name, String author, int age_limit) async {
    if (connection.isClosed) {
      await connection.open();
    }
    PostgreSQLResult result = await connection.query(
        'INSERT INTO books_info VALUES (@barcode, @name, @author, @age_limit)',
        substitutionValues: {
          'barcode': barcode,
          'name': name,
          'author': author,
          'age_limit': age_limit
        }
    );
    newBookFuture =  (result.affectedRowCount > 0 ? 'reg' : 'nop');
    return newBookFuture;
  }

  List<Map<String, Map<String, dynamic>>> loginUserFuture = [];
  Future<List<Map<String, Map<String, dynamic>>>> loginUser(
      String login, String password) async {
    if (connection.isClosed) {
      await connection.open();
    }
    loginUserFuture = await connection.mappedResultsQuery(
        'SELECT * FROM books_accounts br WHERE login = @login AND password = @password',
        substitutionValues: {
          'login': login,
          'password': password
        }
    );
    return loginUserFuture;
  }

  String newUserFuture = '';
  Future<String> registerUser(
      String username, String login, String password) async {
    try {
    if (connection.isClosed) {
      await connection.open();
    }
      PostgreSQLResult result = await connection.query(
          'INSERT INTO books_accounts VALUES (@username, @login, @password)',
          substitutionValues: {
            'username': username,
            'login': login,
            'password': password
          }
      );
      newBookFuture = 'reg';
    } catch (exc) {
      newBookFuture = 'exc';
      exc.toString();
    }
    return newBookFuture;
  }

  String newReviewFuture = '';
  Future<String> createReview(
      int barcode, String how, String text) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      PostgreSQLResult result = await connection.query(
          'INSERT INTO books_reviews VALUES (@barcode, @how, @text)',
          substitutionValues: {
            'barcode': barcode,
            'how': how,
            'text': text
          }
      );
      newReviewFuture = 'reg';
    } catch (exc) {
      newReviewFuture = 'exc';
      exc.toString();
    }
    return newReviewFuture;
  }

  Future<String> updateReview(
      int barcode, String how, String text) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      PostgreSQLResult result = await connection.query(
          'UPDATE books_reviews SET review = @text WHERE book = @barcode AND how = @how',
          substitutionValues: {
            'barcode': barcode,
            'how': how,
            'text': text
          }
      );
      newReviewFuture = 'reg';
    } catch (exc) {
      newReviewFuture = 'exc';
      exc.toString();
    }
    return newReviewFuture;
  }

  Future<String> deleteReview(int barcode, String how) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      PostgreSQLResult result = await connection.query(
          'DELETE FROM books_reviews WHERE book = @barcode AND how = @how',
          substitutionValues: {
            'barcode': barcode,
            'how': how
          }
      );
      newReviewFuture = 'reg';
    } catch (exc) {
      newReviewFuture = 'exc';
      exc.toString();
    }
    return newReviewFuture;
  }
}