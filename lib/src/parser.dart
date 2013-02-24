library parser;

import 'lexer.dart';

class Parser {
  List tokens;
  Map<String,String> current;

  Parser(string) {
    this.tokens = Lexer.tokenize(string);
  }

  Map<String,String> get peek => tokens[0];

  Map<String,String> get next {
    current = tokens[0];
    tokens.removeRange(0,1);
    return current;
  }

  Map _outdent() {
    switch(peek['type']) {
      case 'eof':
        return null;
      case 'outdent':
        return next;
      default:
        throw new Exception('expected outdent, got ${peek['type']}');
    }
  }

  String _text() => next['val'].trim();

  StringBuffer _block() {
    var buff = new StringBuffer();
    next;
    while (peek['type'] != 'outdent' && peek['type'] != 'eof') {
      buff.write(_expr());
    }
    _outdent();
    return buff;
  }

  StringBuffer _textBlock() {
    var indents = 1,
        buff = new StringBuffer();
    Map token;
    next;
    while (peek['type'] != 'eof' && indents > 0) {
      switch((token = next)['type']) {
        case 'newline':
          buff.write(r'\n');
          buff.write(new List.fixedLength(indents).join(' '));
          break;
        case 'indent':
          ++indents;
          buff.write(r'\n');
          buff.write(new List.fixedLength(indents).join(' '));
          break;
        case 'outdent':
          --indents;
          if (indents == 1) {
            buff.write(r'\n');
          }
          break;
        default:
          buff.write(token['match'].replaceAll(new RegExp(r'"'), r'\"'));
          break;
      }
    }
    return buff;
  }

  _attrs() {
    var attributes = ['attrs', 'class', 'id'],
        classes = [],
        buff = [];
    while (attributes.indexOf(peek['type']) != -1) {
      switch (peek['type']) {
        case 'id':
          buff.add(" 'id': '${next['val']}' ");
          break;
        case 'class':
          classes.add(next['val']);
          break;
        case 'attrs':
          var matches = new RegExp(r'(\w+) *=', caseSensitive:false).allMatches(next['val']);
          for (Match match in matches) {
            current['val'] = current['val'].replaceAll(match[1], "'${match[1]}'")
                                           .replaceFirst('=', ':');
          }
          buff.add(current['val']);
          break;
      }
    }
    if (classes.length > 0) {
      buff.add(" 'class': '${classes.join(' ')}' ");
    }
    return buff.length > 0 ?
        "\${attrs({${buff.join(',')}})}" : '';
  }

  _tag() {
    var tagName = next['val'],
        selfClosing = Lexer.selfClosingTags.indexOf(tagName) != -1,
        buff = new StringBuffer('\\n<${tagName}${_attrs()}${selfClosing ? '/' : ''}>');
    switch (peek['type']) {
      case 'text':
        buff.write(_text());
        break;
      case 'conditionalComment':
        buff.write(_conditionalComment());
        break;
      case 'comment':
        buff.write(_comment());
        break;
      case 'outputCode':
        buff.write(_outputCode());
        break;
      case 'escapeCode':
        buff.write(_escapeCode());
        break;
      case 'indent':
        buff.write(_block());
        break;
    }
    if (!selfClosing) {
      buff.write('</${tagName}>');
    }
    return buff;
  }

  String _outputCode() => next['val'];

  String _escapeCode() => '\${escape(${next['val'].trim()})}';

  String _doctype() {
    var type = next['val'].trim().toLowerCase();
    type = type.length > 0 ? type : 'default';
    if (Lexer.doctypes.containsKey(type)) {
      return Lexer.doctypes[type].replaceAll(new RegExp(r'"'), '\\"');
    } else {
      throw new Exception("doctype '${type}' does not exist");
    }
  }

  String _conditionalComment() {
    var condition= next['val'],
        buff = peek['type'] == 'indent' ? _block() : _expr();
    return '<!--${condition}>${buff.toString()}<![endif]-->';
  }

  String _comment() {
    next;
    var buff = peek['type'] == 'indent' ? _block() : _expr();
    return '<!-- ${buff.toString()} -->';
  }

  String _code() {
    var code = next['val'];
    if (peek['type'] == 'indent') {
      return '\${(){\nStringBuffer buff=new StringBuffer();\n${code}\nbuff.write("${_block()}");\nreturn buff.toString();\n}()}';
    }
    return '\${(){\n${code};return \'\';\n}()}';
  }

  String _filter() {
    var filter = next['val'];
    if (peek['type'] != 'indent') {
      throw new Exception("filter '${filter}' expects a text block");
    }
    return "\${Filters.${filter}('${_textBlock()}')}";
  }

  String _iterate() {
    var each = next;
    if (peek['type'] != 'indent') {
      throw new Exception("'- each' expects a block, but got ${peek['type']}");
    }
    return "\${(){\nStringBuffer buff=new StringBuffer();\n${each['val'][2]}.forEach((${each['val'][0]}){\nbuff.write(\"${_block()}\");\n});return buff.toString();\n}()}";
  }

  _expr() {
    switch (peek['type']) {
      case 'id':
      case 'class':
        tokens.insertRange(0, 1, { 'type': 'tag', 'val': 'div' });
        return _tag();
      case 'tag':
        return _tag();
      case 'text':
        var buff = new StringBuffer();
        while (peek['type'] == 'text') {
          buff.write(" ${next['val'].trim()}");
          if (peek['type'] == 'newline') {
            next;
          }
        }
        return buff;
      case 'each':
        return _iterate();
      case 'code':
        return _code();
      case 'escape':
        return next['val'];
      case 'doctype':
        return _doctype();
      case 'filter':
        return _filter();
      case 'conditionalComment':
        return _conditionalComment();
      case 'comment':
        return _comment();
      case 'escapeCode':
        return _escapeCode();
      case 'outputCode':
        return _outputCode();
      case 'newline':
      case 'indent':
      case 'outdent':
        next;
        return _expr();
      default:
        throw new Exception('unexpected ${peek['type']}');
    }
  }

  String get parsed {
    var buff = new StringBuffer();
    while (peek['type'] != 'eof') {
      buff.write(_expr());
    }
    return buff.toString();
  }
}