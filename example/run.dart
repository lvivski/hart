import 'dart:io';

import 'views.dart';


main(){
  var view = new View();
  print(view.render('index', {
    'title': 'Hart Examples',
    'items': ['first', 'second', 'third']
  }));
}