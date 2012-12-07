library hart;

import 'parser.dart';
import 'compiler.dart';

class Hart {
  static parse(String data) {
    return new Parser(data).parsed;
  }
  
  static compile(Map templates) {
    templates.keys.forEach((key) => templates[key] = parse(templates[key]));
    
    return Compiler.compile(templates);
  }
}