# Hart
The heart of any Dart app

[![](https://drone.io/lvivski/hart/status.png)](https://drone.io/lvivski/hart/latest)

Templates are similar to HAML but without `%` before each tag.

## Usage
Dart doesn't allow any code evaluation so you have to precompile all your templates.

Template example:
```jade
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
```
Then you have to compile your template. Basic compiler is in `examples/compile.dart`. After compilation you can run it with
```dart
var view = new View();
view.render('index', {
  'title': 'Hart Examples',
  'items': ['first', 'second', 'third']
});
```
so you'll get
```html
<!DOCTYPE html>
<html>
<head>
<title>Hart Examples</title>
<meta name="keywords" content="template language"/>
<meta name="author"/>
<script><![CDATA[
alert("Hart supports embedded javascript!")
]]></script></head>
<body>
<h1 class="markup">Markup examples</h1>
<div id="content">
<p>This example shows you how a basic Hart file looks like.</p></div>
<ul>
<li>first</li>
<li>second</li>
<li>third</li></ul>
<div id="footer">Copyright &copy; 2013</div></body></html>
```
See [example](example) as a reference.

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
