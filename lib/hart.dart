#library('hart');

#import('dart:io');
#import('parser.dart');

class Hart {
  static compile(data, filename) {
    new File(filename).open(FileMode.WRITE, (file){
      file.writeStringSync("""
#library('template');

#source('lib/utils.dart');

class Template {
  Map locals;

  Template(this.locals);

  noSuchMethod(String name, List args) {
    if (locals === null) {
      locals = {};
    }
    if (name.length > 4) {
      String prefix = name.substring(0, 4);
      String key   = name.substring(4);
      if (prefix == "get:") {
        return locals[key];
      } else if (prefix == "set:") {
        locals[key] = args[0];
      }
    }
  }

  render () {
    return '''
${new Parser(data).parsed}
    ''';
  }
}
""");
    });
  }
}
