#library('utils');

class Filters {
  static plain (str)   => str;
  static cdata (str)   => '<![CDATA[\n${str}\n]]>';
  static css  (str)   => '<style type"text/css">\n/*<![CDATA[*/\n${str}\n/*]]>*/</style>';
  static javascript (str) => '<script type="text/javascript">\n//<![CDATA[\n${str}\n//]]></script>';
}

attrs (attrMap) {
  StringBuffer buf = new StringBuffer();
  for (var key in attrMap.getKeys()) {
    if (attrMap[key] is bool) {
      if (attrMap[key] === true) {
        buf.add(' ${key}="${key}"');
      }
    } else if (attrMap[key] !== null) {
      buf.add(' ${key}="${escape(attrMap[key])}"');
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
