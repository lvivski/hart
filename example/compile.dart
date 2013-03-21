import 'dart:io';

import 'package:hart/hart.dart';

main(){
  var templates = {
    'index': '''
doctype html
html
  head
    title= title
    meta[name="keywords", content="template language"]
    meta[name="author", content=author]
    script
      :cdata
        alert("Hart supports embedded javascript!")
  body
    h1.markup Markup examples
    #content
      p This example shows you how a basic Hart file looks like.
    - if (items != null)
      ul
        - each item in items
          li= item
    div#footer Copyright &copy; 2013
'''};

  new File('example/views.dart').open(FileMode.WRITE).then((file) {
    file.writeString(Hart.compile(templates));
  });
}