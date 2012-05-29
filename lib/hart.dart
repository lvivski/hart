#library('hart');

#import('parser.dart');

class Hart {
  static parse(String data) {
    return new Parser(data).parsed;
  }
}
