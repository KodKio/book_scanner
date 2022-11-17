import 'package:flutter/material.dart';

class MyBook {
  final int barcode;
  final String name;
  final String author;
  final int age;

  MyBook(this.barcode, this.name, this.author, this.age);
}

class MyUser {
  final String name;
  final String login;
  String? email;

  MyUser(this.login, this.name);
}

class MyReview {
  final MyBook book;
  final MyUser how;
  final String text;

  MyReview(this.book, this.how, this.text);
}