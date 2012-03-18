#library('parser');

#import('lexer.dart');

class Parser {
    List tokens;
    Map current;

    Parser(string) {
        this.tokens = Lexer.tokenize(string);
    }

    get peek() => tokens[0];

    get next() {
        current = tokens[0];
        tokens.removeRange(0,1);
        return current;
    }

    get outdent() {
        switch(peek['type']) {
            case 'eof':
                return;
            case 'outdent':
                return next;
            default:
                throw new Exception('expected outdent, got ${peek['type']}');
        }
    }

    get text() => next['val'].trim();

    get block() {
        StringBuffer buf = new StringBuffer();
        next;
        while (peek['type'] !== 'outdent' && peek['type'] !== 'eof') {
            buf.add(expr);
        }
        outdent;
        return buf;
    }

    get textBlock() {
        var token;
        num indents = 1;
        StringBuffer buf = new StringBuffer();
        next;
        while (peek['type'] !== 'eof' && indents) {
            switch((token = next)['type']) {
                case 'newline':
                    buf.add(@'\n');
                    buf.add(Strings.join(new List(indents), '  '));
                    break;
                case 'indent':
                    ++indents;
                    buf.add(@'\n');
                    buf.add(Strings.join(new List(indents), '  '));
                    break;
                case 'outdent':
                    --indents;
                    if (indents === 1) {
                        buf.add(@'\n');
                    }
                    break;
                default:
                    buf.add(token.match.replaceAll(const RegExp(@'"'), '\"'));
            }
        }
        return buf;
    }

    get attrs() {
        List attributes = ['attrs', 'class', 'id'];
        List classes = [];
        List buf = [];
        while (attributes.indexOf(peek['type']) !== -1) {
            switch (peek['type']) {
                case 'id':
                    buf.add(" 'id': '${next['val']}' ");
                    break;
                case 'class':
                    classes.add(next['val']);
                    break;
                case 'attrs':
                    const RegExp(@'(\w+) *:', ignoreCase:true).allMatches(next['val']).forEach((match){
                        buf.add(current['val'].replaceAll(match[1], "'${match[1]}'"));
                    });
            }
        }
        if (classes.length > 0) {
            buf.add(" 'class': '${Strings.join(classes, ' ')}' ");
        }
        return buf.length > 0
                ? '\${attrs({${Strings.join(buf, ',')})}'
                : '';
    }

    get tag() {
        var tagName = next['val'];
        bool selfClosing = Lexer.selfClosingTags.indexOf(tagName) !== -1;
        StringBuffer buf = new StringBuffer('\\n<${tagName}${attrs}' + (selfClosing ? '/>' : '>'));
        switch (peek['type']) {
            case 'text':
                buf.add(text);
                break;
            case 'conditionalComment':
                buf.add(conditionalComment);
                break;
            case 'comment':
                buf.add(comment);
                break;
            case 'outputCode':
                buf.add(outputCode);
                break;
            case 'escapeCode':
                buf.add(escapeCode);
                break;
            case 'indent':
                buf.add(block);
        }
        if (!selfClosing) {
            buf.add('</${tagName}>');
        }
        return buf;
    }

    get outputCode() => next['val'];

    get escapeCode() => '\${escape(${next['val'].trim()})}';

    get doctype() {
        var type = next['val'].trim().toLowerCase();
        type = type.length > 0 ? type : 'default';
        if (Lexer.doctypes.containsKey(type)) {
            return Lexer.doctypes[type].replaceAll(const RegExp(@'"'), '\\"');
        } else {
            throw new Exception("doctype '${type}' does not exist");
        }
    }

    get conditionalComment() {
        var condition= next['val'];
        var buf = peek['type'] === 'indent'
                    ? block
                    : expr;
        return '<!--${condition}>${buf.toString()}<![endif]-->';
    }

    get comment() {
        next;
        var buf = peek['type'] === 'indent'
                    ? block
                    : expr;
        return '<!-- ${buf.toString()} -->';
    }

    get expr() {
        switch (peek['type']) {
            case 'id':
            case 'class':
                tokens.insertRange(0, 1, { 'type': 'tag', 'val': 'div' });
                return tag;
            case 'tag':
                return tag;
            case 'text':
                List buf = [];
                while (peek['type'] === 'text') {
                    buf.add(next['val'].trim());
                    if (peek['type'] === 'newline') {
                        next;
                    }
                }
                return Strings.join(buf, ' ');
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
                throw new Exception('unexpected ' + peek['type']);
        }
    }

    get parsed() {
        StringBuffer buf = new StringBuffer();
        while (peek['type'] !== 'eof') {
            buf.add(this.expr);
        }
        return buf.toString();
    }
}
