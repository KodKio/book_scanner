import 'package:postgres/postgres.dart';

class AppDatabase {
  PostgreSQLConnection connection = PostgreSQLConnection(
    '195.19.32.74',
    5432,
    'fn1132_2022',
    username: 'student',
    password: 'bmstu',
  );

  AppDatabase() {
    _createTables();
  }

  Future<void> _createTables() async {
    if (connection.isClosed) {
      await connection.open();
    }
    PostgreSQLResult result = await connection.query(
        '''CREATE TABLE IF NOT EXISTS public.books_accounts
        (name text not null,
         login text constraint books_accounts_pk primary key,
         password text not null,
         age integer default 0
        )'''
    );
    result = await connection.query(
        '''CREATE TABLE IF NOT EXISTS public.books_info 
        (barcode bigint constraint books_info_pk primary key,
         name text not null,
         author text,
         age_limit integer default 0
        )'''
    );
    result = await connection.query(
        '''CREATE TABLE IF NOT EXISTS public.books_reviews 
        (book bigint constraint books_reviews_books_info_barcode_fk references public.books_info,
         how text constraint books_reviews_books_accounts_login_fk references public.books_accounts,
         review text,
         rate integer,
         constraint books_reviews_pk primary key (how, book)
        )'''
    );
  }

  List<Map<String, Map<String, dynamic>>> fetchBookDataFuture = [];
  Future<List<Map<String, Map<String, dynamic>>>> fetchBookData(int barcode) async {
    if (connection.isClosed) {
      await connection.open();
    }
    fetchBookDataFuture = await connection.mappedResultsQuery(
        'SELECT bi.name, bi.author, bi.age_limit FROM books_info bi WHERE barcode = @barcode',
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
        'SELECT bi.name, ba.login, ba.name, br.review, br.rate FROM books_reviews br JOIN books_accounts ba ON ba.login = br.how JOIN books_info bi ON bi.barcode = br.book WHERE br.book = @book',
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
      String username, String login, String password, int age) async {
    try {
    if (connection.isClosed) {
      await connection.open();
    }
      await connection.query(
          'INSERT INTO books_accounts VALUES (@username, @login, @password, @age)',
          substitutionValues: {
            'username': username,
            'login': login,
            'password': password,
            'age': age,
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
      int barcode, String how, String text, int rate) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      await connection.query(
          'INSERT INTO books_reviews VALUES (@barcode, @how, @text, @rate)',
          substitutionValues: {
            'barcode': barcode,
            'how': how,
            'text': text,
            'rate': rate
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
      int barcode, String how, String text, int rate) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      await connection.query(
          'UPDATE books_reviews SET review = @text, rate = @rate WHERE book = @barcode AND how = @how',
          substitutionValues: {
            'barcode': barcode,
            'how': how,
            'text': text,
            'rate': rate
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
      await connection.query(
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

  Future<bool> foundUserByLoginAndAge(String login, int age) async {
    if (connection.isClosed) {
      await connection.open();
    }
    loginUserFuture = await connection.mappedResultsQuery(
        'SELECT * FROM books_accounts br WHERE login = @login AND age = @age',
        substitutionValues: {
          'login': login,
          'age': age
        }
    );
    return loginUserFuture.isNotEmpty;
  }

  Future<String> updateUserPassword(String login, String password) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      await connection.query(
          'UPDATE books_accounts SET password = @password WHERE login = @login',
          substitutionValues: {
            'login': login,
            'password': password
          }
      );
      newReviewFuture = 'reg';
    } catch (exc) {
      newReviewFuture = 'exc';
      exc.toString();
    }
    return newReviewFuture;
  }

  Future<String> updateUser(String login, String username, String password, int age) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      await connection.query(
          'UPDATE books_accounts SET password = @password, age = @age, name = @username WHERE login = @login',
          substitutionValues: {
            'login': login,
            'password': password,
            'age': age,
            'username': username
          }
      );
      newReviewFuture = 'reg';
    } catch (exc) {
      newReviewFuture = 'exc';
      exc.toString();
    }
    return newReviewFuture;
  }

  Future<String> deleteUser(String login) async {
    try {
      if (connection.isClosed) {
        await connection.open();
      }
      await connection.query(
          'DELETE FROM books_accounts WHERE login = @login',
          substitutionValues: {
            'login': login
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