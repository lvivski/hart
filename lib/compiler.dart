library compiler;

class Compiler {
  static _getClass(String className, String data) {
    return """

class ${className}View extends View {
  Map locals;

  ${className}View(this.locals);

  noSuchMethod(mirror) {
    if (locals === null) {
      locals = {};
    }
    if (mirror.isGetter) {
        return locals[mirror.memberName];
      } else if (mirror.isSetter) {
        locals[mirror.memberName] = mirror.positionalArguments[0];
      }
    }
  }

  get () {
    return '''
$data
    ''';
  }
}
""";
  }
  
  static _getMain(Map templates) {
    var buff = new StringBuffer('''

class View {
  Map _views;
  
  render(name, params) {
    return _views[name](params).get();
  }
  
  register(name, handler) {
    if (_views == null) {
      _views = {};
    }
    _views[name] = handler;
  }

  View() {
''');
    templates.keys.forEach((key) {
      buff.add("    register('$key', (params) => new ${camelize(key)}View(params));\n");
    });
    buff.add('''
   }
}
''');
    return buff.toString();
  }
  
  static compile(Map templates) {
    StringBuffer buff = new StringBuffer('''
library view;
import 'package:hart/utils.dart';
''');
    templates.keys.forEach((key) {
      buff.add(_getClass(camelize(key), templates[key]));  
    });
    
    buff.add(_getMain(templates));
    
    return buff.toString();
  }
  
  static String camelize(String name) {
    return Strings.join(name.split(new RegExp(r'-|_')).map((part) => part[0].toUpperCase().concat(part.substring(1))), '');
  }
}