library lexer;

class Lexer {
  static Map<String,String> doctypes = const {
    '5'       : '<!DOCTYPE html>',
    'xml'     : '<?xml version="1.0" encoding="utf-8" ?>',
    'default' : '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    'strict'  : '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
    '1.1'     : '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    'basic'   : '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
    'mobile'  : '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
  };

  static List<String> selfClosingTags = const [
    'meta',
    'img',
    'link',
    'br',
    'hr',
    'input',
    'area',
    'base'
  ];


  static final Map<String,RegExp> rules = {
    'indent'            : new RegExp(r'^\n( *)(?! *-#)'),
    'conditionalComment': new RegExp(r'^\/(\[[^\n]+\])'),
    'comment'           : new RegExp(r'^\n? *\/ *'),
    'silentComment'     : new RegExp(r'^\n? *-#([^\n]*)'),
    'doctype'           : new RegExp(r'^!!! *([^\n]*)'),
    'escape'            : new RegExp(r'^\\(.)'),
    'filter'            : new RegExp(r'^:(\w+) *'),
    'each'              : new RegExp(r'^\- *each *(\w+)(?: *, *(\w+))? * in ([^\n]+)'),
    'code'              : new RegExp(r'^\-([^\n]+)'),
    'outputCode'        : new RegExp(r'^!=([^\n]+)'),
    'escapeCode'        : new RegExp(r'^=([^\n]+)'),
    'attrs'             : new RegExp(r'^\{(.*?)\}'),
    'tag'               : new RegExp(r'^%([-a-zA-Z][-a-zA-Z0-9:]*)'),
    'class'             : new RegExp(r'^\.([\w\-]+)'),
    'id'                : new RegExp(r'^\#([\w\-]+)'),
    'text'              : new RegExp(r'^([^\n]+)')
  };

  static List tokenize(String str) {
    str = str.trim().replaceAll(new RegExp(r'\r\n|\r'), '\n');
    Match matches;
    var token;
    int line = 1;
    num lastIndents = 0;
    List tokens = [];
    while (str.length > 0) {
      for (var type in rules.keys) {
        matches = rules[type].firstMatch(str);
        if (matches != null) {
          List matchesList = [];
          for (var i = 1, len = matches.groupCount; i <= len; i++) {
            matchesList.add(matches.group(i));
          }
          token = {
            'type' : type,
            'line' : line,
            'match': matches[0],
            'val' : matchesList.length > 1 ? matchesList : matchesList[0]
          };
          str = str.substring(matches[0].length);
          if (type == 'indent') {
            ++line;
          } else {
            break;
          }
          var indents = token['val'].length / 2;
          if (indents % 1 > 0) {
            throw new Exception("invalid indentation; got ${token['val'].length} spaces, should be multiple of 2");
          } else if (indents - 1 > lastIndents) {
            throw new Exception('invalid indentation; got $indents, when previous was $lastIndents');
          } else if (lastIndents > indents) {
            while (lastIndents-- > indents) {
              tokens.add({
                'type': 'outdent',
                'line': line
              });
            }
          } else if (lastIndents != indents) {
            tokens.add({
              'type': 'indent',
              'line': line
            });
          } else {
            tokens.add({
              'type': 'newline',
              'line': line
            });
          }
          lastIndents = indents;
        }
      }
      if (token != null) {
        if (token['type'] != 'silentComment') {
          tokens.add(token);
        }
        token = null;
      } else {
        throw new Exception('near "${str.substring(15)}"');
      }
    }
    tokens.add({ 'type': 'eof' });
    return tokens;
  }
}
