import 'dart:io';

import 'views.dart';


main(){
  var view = new View(); 
  print(view.render('index', {
    'title': 'Title',
    'items': ['1','2','3']
  }));
}