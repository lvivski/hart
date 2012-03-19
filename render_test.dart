#import('template.dart');

main() {
  print(new Template({
    'title': 'TITLETITLETITLE',
    'newClass': 'newClass',
    'items': [1,2,3]
  }).render());
}