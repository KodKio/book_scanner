class MyBook {
  final int barcode;
  final String name;
  final String author;
  final int age_limit;

  MyBook(this.barcode, this.name, this.author, this.age_limit);
}

class MyUser {
  final String name;
  final String login;
  final int age;

  MyUser(this.login, this.name, this.age);
}

class MyReview {
  final MyBook book;
  final MyUser how;
  final String text;
  final int rate;

  MyReview(this.book, this.how, this.text, this.rate);
}