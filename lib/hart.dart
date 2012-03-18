#library('hart');

#import('dart:io');

#import('parser.dart');

class Hart {
    static compile(data) {
        return new Parser(data).parsed;
    }
}

main() {
    String template = '''
!!! 5
%html
  %head
    %title= title
    %script{ src: 'jquery.js' }
    %script{ src: 'jquery.ui.js' }
  %body.one.two.three
    %h1 Welcome
    %ul#menu.class
      %li.first#list one
      %li two
      %li.last three
      %li
        %ul
          %li nested
''';
    print(Hart.compile(template));
}
