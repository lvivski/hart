library parser;

import 'lexer.dart';

class Parser {
  List tokens;
  Map current;

  Parser(string) {
    this.tokens = Lexer.tokenize(string);
  }

  Map get peek => tokens[0];

  Map get next {
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
    StringBuffer buff = new StringBuffer();
    next;
    while (peek['type'] != 'outdent' && peek['type'] != 'eof') {
      buff.add(_expr());
    }
    _outdent();
    return buff;
  }

  StringBuffer _textBlock() {
    Map token;
    num indents = 1;
    StringBuffer buff = new StringBuffer();
    next;
    while (peek['type'] != 'eof' && indents > 0) {
      switch((token = next)['type']) {
        case 'newline':
          buff.add(r'\n');
          buff.add(Strings.join(new List(indents), ' '));
          break;
        case 'indent':
          ++indents;
          buff.add(r'\n');
          buff.add(Strings.join(new List(indents), ' '));
          break;
        case 'outdent':
          --indents;
          if (indents == 1) {
            buff.add(r'\n');
          }
          break;
        default:
          buff.add(token['match'].replaceAll(new RegExp(r'"'), r'\"'));
      }
    }
    return buff;
  }

  _attrs() {
    List attributes = ['attrs', 'class', 'id'];
    List classes = [];
    List buff = [];
    while (attributes.indexOf(peek['type']) != -1) {
      switch (peek['type']) {
        case 'id':
          buff.add(" 'id': '${next['val']}' ");
          break;
        case 'class':
          classes.add(next['val']);
          break;
        case 'attrs':
          Iterable<Match> matches = new RegExp(r'(\w+) *:', ignoreCase:true).allMatches(next['val']);
          for (Match match in matches) {
            current['val'] = current['val'].replaceAll(match[1], "'${match[1]}'");
          }
          buff.add(current['val']);
          break;
      }
    }
    if (classes.length > 0) {
      buff.add(" 'class': '${Strings.join(classes, ' ')}' ");
    }
    return buff.length > 0 ?
        "\${attrs({${Strings.join(buff, ',')}})}" : '';
  }

  _tag() {
    String tagName = next['val'];
    bool selfClosing = Lexer.selfClosingTags.indexOf(tagName) != -1;
    StringBuffer buff = new StringBuffer('\\n<${tagName}${_attrs()}${selfClosing ? '/' : ''}>');
    switch (peek['type']) {
      case 'text':
        buff.add(_text());
        break;
      case 'conditionalComment':
        buff.add(_conditionalComment());
        break;
      case 'comment':
        buff.add(_comment());
        break;
      case 'outputCode':
        buff.add(_outputCode());
        break;
      case 'escapeCode':
        buff.add(_escapeCode());
        break;
      case 'indent':
        buff.add(_block());
        break;
    }
    if (!selfClosing) {
      buff.add('</${tagName}>');
    }
    return buff;
  }

  String _outputCode() => next['val'];

  String _escapeCode() => '\${escape(${next['val'].trim()})}';

  String _doctype() {
    String type = next['val'].trim().toLowerCase();
    type = type.length > 0 ? type : 'default';
    if (Lexer.doctypes.containsKey(type)) {
      return Lexer.doctypes[type].replaceAll(new RegExp(r'"'), '\\"');
    } else {
      throw new Exception("doctype '${type}' does not exist");
    }
  }

  String _conditionalComment() {
    String condition= next['val'];
    StringBuffer buff = peek['type'] == 'indent' ? _block() : _expr();
    return '<!--${condition}>${buff.toString()}<![endif]-->';
  }

  String _comment() {
    next;
    StringBuffer buff = peek['type'] == 'indent' ? _block() : _expr();
    return '<!-- ${buff.toString()} -->';
  }

  String _code() {
    String code = next['val'];
    if (peek['type'] == 'indent') {
      return '\${(){\nStringBuffer buff=new StringBuffer();\n${code}\nbuff.add("${_block()}");\nreturn buff.toString();\n}()}';
    }
    return '\${(){\n${code};return'';\n}()}';
  }

  String _filter() {
    String filter = next['val'];
    if (peek['type'] != 'indent') {
      throw new Exception("filter '${filter}' expects a text block");
    }
    return "\${Filters.${filter}('${_textBlock()}')}";
  }

  String _iterate() {
    Map each = next;
    if (peek['type'] != 'indent') {
      throw new Exception("'- each' expects a block, but got ${peek['type']}");
    }
    return "\${(){\nStringBuffer buff=new StringBuffer();\n${each['val'][2]}.forEach((${each['val'][0]}){\nbuff.add(\"${_block()}\");\n});return buff.toString();\n}()}";
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
        StringBuffer buff = new StringBuffer();
        while (peek['type'] == 'text') {
          buff.add(" ${next['val'].trim()}");
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
    StringBuffer buff = new StringBuffer();
    while (peek['type'] != 'eof') {
      buff.add(_expr());
    }
    return buff.toString();
  }
}