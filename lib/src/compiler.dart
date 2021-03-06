library compiler;

class Compiler {
  static String _getClass(String className, String data) {
    return """

class ${className}View extends View {
  Map locals;

  ${className}View(this.locals);

  noSuchMethod(Invocation mirror) {
    if (locals == null) {
      locals = {};
    }
    if (mirror.isGetter) {
      return locals[MirrorSystem.getName(mirror.memberName)];
    }
  }

  get() {
    return '''
$data
    ''';
  }
}
""";
  }

  static String _getMain(Map<String,String> templates) {
    var buff = new StringBuffer('''

class View {
  Map _views;

  render(String name, Map params) {
    return _views[name](params).get();
  }

  register(String name, handler(Map params)) {
    if (_views == null) {
      _views = {};
    }
    _views[name] = handler;
  }

  View() {
''');
    templates.keys.forEach((key) {
      buff.write("    register('$key', (params) => new ${camelize(key)}View(params));\n");
    });
    buff.write('''
   }
}
''');
    return buff.toString();
  }

  static String compile(Map<String,String> templates) {
    StringBuffer buff = new StringBuffer('''
library view;
import 'dart:mirrors';
import 'package:hart/utils.dart';
''');
    templates.keys.forEach((key) {
      buff.write(_getClass(camelize(key), templates[key]));
    });

    buff.write(_getMain(templates));

    return buff.toString();
  }

  static String camelize(String name) {
    return name.split(new RegExp(r'-|_')).map((part) => part[0].toUpperCase() + part.substring(1)).join('');
  }
}