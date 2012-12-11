import 'package:unittest/unittest.dart';
import 'package:hart/hart.dart';

void main() {
  group('tag', () {
    test('parse', () {
      expect(Hart.parse('doctype 5'), equals('<!DOCTYPE html>'));
      expect(Hart.parse('link'), equals(r'\n<link/>'));
      expect(Hart.parse('p'), equals(r'\n<p></p>'));
    });

    test('with one-line content', () {
      expect(Hart.parse('p content'), equals(r'\n<p>content</p>'));
      expect(Hart.parse('div content'), equals(r'\n<div>content</div>'));
    });

    test('with nesting', () {
      expect(Hart.parse('p\n  segment content'), equals(r'\n<p>\n<segment>content</segment></p>'));
    });

    test('attrs parse', () {
      expect(Hart.parse("link{ rel: 'stylesheet', href: '/stylesheets/main.css', type: 'text/css'}"), equals(r"\n<link${attrs({ 'rel': 'stylesheet', 'href': '/stylesheets/main.css', 'type': 'text/css'})}/>"));
    });

    test('class', () {
      expect(Hart.parse('p.first'), equals(r"\n<p${attrs({ 'class': 'first' })}></p>"));
      expect(Hart.parse('.first'), equals(r"\n<div${attrs({ 'class': 'first' })}></div>"));
    });

    test('id', () {
      expect(Hart.parse('p#id'), equals(r"\n<p${attrs({ 'id': 'id' })}></p>"));
      expect(Hart.parse('#main'), equals(r"\n<div${attrs({ 'id': 'main' })}></div>"));
    });
  });
}
