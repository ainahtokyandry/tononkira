import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';

Future<String> getLyricsByUrl(String url) async {
  final response = await http.get(Uri.parse(url));
  final document = parse(response.body);
  final lyricBox =
      document.querySelector('.home-search + div.row.g-3.py-3 .col-md-8');
  lyricBox?.nodes.removeWhere((node) => node.nodeType != Node.TEXT_NODE);

  return lyricBox!.text.trim();
}
