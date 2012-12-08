library parser;

import 'lexer.dart';

class Parser {
  List tokens;
  Map current;

  Parser(string) {
    this.tokens = Lexer.tokenize(string);
  }

  get peek => tokens[0];

  get next {
    current = tokens[0];
    tokens.removeRange(0,1);
    return current;
  }

  get outdent {
    switch(peek['type']) {
      case 'eof':
        return;
      case 'outdent':
        return next;
      default:
        throw new Exception('expected outdent, got ${peek['type']}');
    }
  }

  get text => next['val'].trim();

  get block {
    StringBuffer buff = new StringBuffer();
    next;
    while (peek['type'] != 'outdent' && peek['type'] != 'eof') {
      buff.add(expr);
    }
    outdent;
    return buff;
  }

  get textBlock {
    var token;
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

  get attrs {
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

  get tag {
    String tagName = next['val'];
    bool selfClosing = Lexer.selfClosingTags.indexOf(tagName) != -1;
    StringBuffer buff = new StringBuffer('\\n<${tagName}${attrs}${selfClosing ? '/' : ''}>');
    switch (peek['type']) {
      case 'text':
        buff.add(text);
        break;
      case 'conditionalComment':
        buff.add(conditionalComment);
        break;
      case 'comment':
        buff.add(comment);
        break;
      case 'outputCode':
        buff.add(outputCode);
        break;
      case 'escapeCode':
        buff.add(escapeCode);
        break;
      case 'indent':
        buff.add(block);
        break;
    }
    if (!selfClosing) {
      buff.add('</${tagName}>');
    }
    return buff;
  }

  get outputCode => next['val'];

  get escapeCode => '\${escape(${next['val'].trim()})}';

  get doctype {
    String type = next['val'].trim().toLowerCase();
    type = type.length > 0 ? type : 'default';
    if (Lexer.doctypes.containsKey(type)) {
      return Lexer.doctypes[type].replaceAll(new RegExp(r'"'), '\\"');
    } else {
      throw new Exception("doctype '${type}' does not exist");
    }
  }

  get conditionalComment {
    var condition= next['val'];
    var buff = peek['type'] == 'indent' ? block : expr;
    return '<!--${condition}>${buff.toString()}<![endif]-->';
  }

  get comment {
    next;
    var buff = peek['type'] == 'indent' ? block : expr;
    return '<!-- ${buff.toString()} -->';
  }

  get code {
    var code = next['val'];
    if (peek['type'] == 'indent') {
      return '\${(){\nStringBuffer buff=new StringBuffer();\n${code}\nbuff.add("${block}");\nreturn buff.toString();\n}()}';
    }
    return '\${(){\n${code};return'';\n}()}';
  }

  get filter {
    var filter = next['val'];
    if (peek['type'] != 'indent') {
      throw new Exception("filter '${filter}' expects a text block");
    }
    return "\${Filters.${filter}('${textBlock}')}";
  }

  get iterate {
    var each = next;
    if (peek['type'] != 'indent') {
      throw new Exception("'- each' expects a block, but got ${peek['type']}");
    }
    return "\${(){\nStringBuffer buff=new StringBuffer();\n${each['val'][2]}.forEach((${each['val'][0]}){\nbuff.add(\"${block}\");\n});return buff.toString();\n}()}";
  }

  get expr {
    switch (peek['type']) {
      case 'id':
      case 'class':
        tokens.insertRange(0, 1, { 'type': 'tag', 'val': 'div' });
        return tag;
      case 'tag':
        return tag;
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
        return iterate;
      case 'code':
        return code;
      case 'escape':
        return next['val'];
      case 'doctype':
        return doctype;
      case 'filter':
        return filter;
      case 'conditionalComment':
        return conditionalComment;
      case 'comment':
        return comment;
      case 'escapeCode':
        return escapeCode;
      case 'outputCode':
        return outputCode;
      case 'newline':
      case 'indent':
      case 'outdent':
        next;
        return expr;
      default:
        throw new Exception('unexpected ${peek['type']}');
    }
  }

  get parsed {
    StringBuffer buff = new StringBuffer();
    while (peek['type'] != 'eof') {
      buff.add(this.expr);
    }
    return buff.toString();
  }
}