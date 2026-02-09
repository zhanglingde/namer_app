

import 'package:english_words/english_words.dart';

class History{
  int id;
  String first;
  String second;
  DateTime createTime;

  History({
    required this.id,
    required this.first,
    required this.second,
    required this.createTime
  });


  Map<String, Object?> toMap() {
    return {

      'first': first,
      'second': second,
      'create_time': createTime.toIso8601String(),
    };
  }

  WordPair convertWordPair(){
    return WordPair(first, second);
  }

}