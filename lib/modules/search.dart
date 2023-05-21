import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tononkira/model.dart';

Future<List<LyricsOBox>> fetchHTMLResult(String query) async {
  final response = await http
      .get(Uri.parse("https://tononkira.serasera.org/tononkira?q=$query"));
  if (response.statusCode == 200) {
    return scrapeData(response.body);
  } else {
    throw Exception('Failed to fetch HTML');
  }
}

List<LyricsOBox> scrapeData(String htmlString) {
  final document = parser.parse(htmlString);
  final data = <Map<String, String>>[];
  document.querySelectorAll('div.border.p-2.mb-3 a').forEach((el) {
    final text = el.text;
    final link = el.attributes['href']?.replaceAll('/ankafizo', '');
    data.add({'text': text, 'link': link ?? ''});
  });

  final chunkedData = chunk(data, 3);

  return chunkedData.map((el) {
    return LyricsOBox(
        content: '',
        link: el[2]['link']!,
        title: el[0]['text']!,
        artist: ArtistOBox(link: el[1]['link']!, name: el[1]['text']!));
  }).toList();
}

List<List<T>> chunk<T>(List<T> list, int size) {
  List<List<T>> chunks = [];
  int i = 0;
  while (i < list.length) {
    chunks.add(list.sublist(i, i + size));
    i += size;
  }
  return chunks;
}
