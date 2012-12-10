library hart;

import 'src/parser.dart';
import 'src/compiler.dart';

class Hart {
  static String parse(String data) {
    return new Parser(data).parsed;
  }

  static String compile(Map templates) {
    templates.keys.forEach((key) => templates[key] = parse(templates[key]));

    return Compiler.compile(templates);
  }
}