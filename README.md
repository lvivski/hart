# Hart
Haml implementation in Dart

## Usage
Dart doesn't allow any code evaluation so you have to precompile all your templates

```
$PATH_TO_DART_SDK/bin/dart bin/hart compile template.haml
```

then use them in your code.

``` dart
#import('gen/template.dart'); // import generated template

main() {
  print(
    new Template({ // initialize template with local variables
      'title': 'TITLETITLETITLE',
      'newClass': 'newClass',
      'items': [1,2,3]
    }).render()
  );
}
```

This will generate

``` html
<!DOCTYPE html>
<html>
<head>
<title>TITLETITLETITLE</title>
<script><![CDATA[
foo
]]></script>
<script src="jquery.js"></script></head>
<body class="one two three">
<h1>Welcome</h1>
<ul id="menu" class="newClass">
<li id="list" class="first">one</li>
<li>two</li>
<li class="last">three</li>
<li>
<ul>
<li>nested</li></ul></li></ul>
<ul>
<li>1</li>
<li>2</li>
<li>3</li></ul>
<div class="article first">article text hereand here</div></body></html>
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
