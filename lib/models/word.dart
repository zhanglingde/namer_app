

import 'package:english_words/english_words.dart';

class Word{
  int id;
  String first;
  String second;
  DateTime addTime;

  Word({
    required this.id,
    required this.first,
    required this.second,
    required this.addTime
  });


  Map<String, Object?> toMap() {
    return {
      'first': first,
      'second': second,
      'add_time': addTime.toIso8601String(),
    };
  }

  WordPair convertWordPair(){
    return WordPair(first, second);
  }

}