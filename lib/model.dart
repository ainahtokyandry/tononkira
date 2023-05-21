import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Artist {
  @Id()
  int id;
  String name;
  String link;

  @Property(type: PropertyType.date)
  DateTime dateCreated;

  String get dateCreatedFormat =>
      DateFormat('dd.MM.yy HH:mm:ss').format(dateCreated);

  Artist(
      {this.id = 0,
      required this.name,
      required this.link,
      DateTime? dateCreated})
      : dateCreated = dateCreated ?? DateTime.now();
  ArtistOBox toObjectBox() {
    return ArtistOBox(name: name, link: link);
  }
}

@Entity()
class Lyrics {
  @Id()
  int id;
  String content;
  String link;
  String title;
  final artist = ToOne<Artist>();

  @Property(type: PropertyType.date)
  DateTime dateCreated;

  String get dateCreatedFormat =>
      DateFormat('dd.MM.yy HH:mm:ss').format(dateCreated);

  Lyrics(
      {this.id = 0,
      required this.link,
      required this.content,
      required this.title,
      DateTime? dateCreated})
      : dateCreated = dateCreated ?? DateTime.now();

  LyricsOBox toObjectBox() {
    return LyricsOBox(
        id: id,
        content: content,
        link: link,
        title: title,
        artist: artist.target!.toObjectBox());
  }
}

class LyricsOBox {
  int? id;
  String content;
  String link;
  String title;
  ArtistOBox artist;
  LyricsOBox({
    this.id,
    required this.content,
    required this.link,
    required this.title,
    required this.artist,
  });
}

class ArtistOBox {
  int? id;
  String name;
  String link;
  ArtistOBox({
    this.id,
    required this.name,
    required this.link,
  });
}
