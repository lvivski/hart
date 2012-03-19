class Filters {
    static plain (str)      => str;
    static cdata (str)      => '<![CDATA[\n${str}\n]]>';
    static css   (str)      => '<style type"text/css">\n/*<![CDATA[*/\n${str}\n/*]]>*/</style>';
    static javascript (str) => '<script type="text/javascript">\n//<![CDATA[\n${str}\n//]]></script>';
}

attrs (attrs) {
    StringBuffer buf = new StringBuffer();
    for (var key in attrs.getKeys()) {
        if (attrs[key] is bool) {
            if (attrs[key] === true) {
                buf.add(' ${key}="${key}"');
            }
        } else if (attrs[key] !== null) {
            buf.add(' ${key}="${escape(attrs[key])}"');
        }
    }
    return buf.toString();
}

escape (String str) {
  return str.toString()
    .replaceAll('&', '&amp;')
    .replaceAll('>', '&gt;')
    .replaceAll('<', '&lt;')
    .replaceAll('"', '&quot;');
}
