import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static String routeName = '/about';

  @override
  _AboutPageState createState() => new _AboutPageState();

}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О нас'),
      ),
      body: const Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text('Выполнено в рамках курса "Базы данных" студентами МГТУ им. Н.Э. Баумана Степановым Николаем и Алымовой Анастасией,\n преподаватель: Гумиргалиев Тимур Рашидович\n ссылка на проект: https://github.com/KodKio/book_scanner')),
      ),
    );
  }
}
