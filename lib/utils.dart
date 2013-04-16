library utils;

plain (String str) => str;
cdata (String str) => '<![CDATA[\n$str\n]]>';
css (String str) => '<style type"text/css">\n/*<![CDATA[*/\n$str\n/*]]>*/</style>';
javascript (String str) => '<script type="text/javascript">\n//<![CDATA[\n$str\n//]]></script>';

attrs(Map attrMap) {
  StringBuffer buf = new StringBuffer();
  for (var key in attrMap.keys) {
    if (attrMap[key] is bool) {
      if (attrMap[key] == true) {
        buf.write(' ${key}="${key}"');
      }
    } else if (attrMap[key] != null) {
      buf.write(' ${key}="${escape(attrMap[key])}"');
    }
  }
  return buf.toString();
}

escape(String str) {
 return str
  .replaceAll('&', '&amp;')
  .replaceAll('>', '&gt;')
  .replaceAll('<', '&lt;')
  .replaceAll('"', '&quot;');
}