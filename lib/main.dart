import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const RandomQuoteApp());
}

// Корневой виджет приложения.
class RandomQuoteApp extends StatelessWidget {
  const RandomQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  // Данные, которые показываются на экране.
  String quote = '';
  String author = '';
  String error = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Загружаем первую цитату сразу после открытия экрана.
    loadQuote();
  }

  // Загружает случайную цитату с API.
  Future<void> loadQuote() async {
    setState(() {
      isLoading = true;
      error = '';
      quote = '';
      author = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          quote = data['content'] as String;
          author = data['author'] as String;
        });
      } else {
        setState(() {
          error = 'Не удалось загрузить цитату';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Ошибка подключения';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Открывает стандартное окно "Поделиться".
  void shareQuote() {
    if (quote.isEmpty) return;
    Share.share('"$quote"\n- $author');
  }

  @override
  Widget build(BuildContext context) {
    // Один простой экран с цитатой, автором и двумя кнопками.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Случайная цитата'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error.isEmpty ? '"$quote"' : error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error.isEmpty ? author : '',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: loadQuote,
                      child: const Text('Новая цитата'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: quote.isEmpty ? null : shareQuote,
                      child: const Text('Поделиться'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
