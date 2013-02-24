library utils;

class Filters {
  static String plain (str) => str;
  static String cdata (str) => '<![CDATA[\n${str}\n]]>';
  static String css (str) => '<style type"text/css">\n/*<![CDATA[*/\n${str}\n/*]]>*/</style>';
  static String javascript (str) => '<script type="text/javascript">\n//<![CDATA[\n${str}\n//]]></script>';
}

String attrs (Map attrMap) {
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

String escape (String str) {
 return str.toString()
  .replaceAll('&', '&amp;')
  .replaceAll('>', '&gt;')
  .replaceAll('<', '&lt;')
  .replaceAll('"', '&quot;');
}