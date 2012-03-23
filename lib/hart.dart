#library('hart');

#import('dart:io');
#import('parser.dart');

class Hart {
  static compile(data, filepath) {
    new File(filepath).open(FileMode.WRITE, (file){
      String className = camelize(file.name.split('/').last().split('.')[0]);
      file.writeStringSync("""
#library('template');

#source('../lib/utils.dart');

class ${className} {
  Map locals;

  ${className}(this.locals);

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
  
  static String camelize(String name) {
    return Strings.join(name.split(const RegExp(@'-|_')).map((part) => part[0].toUpperCase() + part.substring(1)), '');
  }
}
