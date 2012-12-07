# Hart
Haml implementation in Dart

## Usage
Dart doesn't allow any code evaluation so you have to precompile all your templates

``` dart
import 'package:hart/hart.dart';

main() {
    String template = '''
!!! 5
%html
  %head
    %title= title
    %script
      :cdata
        foo
    %script{ src: 'jquery.js' }
  %body.one.two.three
    %h1 Welcome
    %ul#menu{ class: newClass}
      %li.first#list one
      %li two
      %li.last three
      %li
        %ul
          %li nested
    - if (items !== null)
    %ul
      - each item in items
        %li= item
    %div.article.first
      article text here
      and here
''';
  print(Hart.parse(template));
}
```

## License

(The MIT License)

Copyright (c) 2012 Yehor Lvivski <lvivski@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
