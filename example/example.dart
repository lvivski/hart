import '../lib/hart.dart';

main(){
  var templates = {
    'index': '''
!!! 5
%html
  %head
    %title= title
    %link{ rel: "stylesheet", href: "/stylesheets/main.css", type: "text/css"}
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
'''};

print(Hart.compile(templates));
}