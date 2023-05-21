import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import './model.dart';
import 'objectbox.g.dart'; // created by `flutter pub run build_runner build`

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late final Store _store;

  // Keeping reference to avoid Admin getting closed.
  // ignore: unused_field
  late final Admin _admin;

  /// Two Boxes: one for Tasks, one for Tags.
  late final Box<Artist> _artistBox;
  late final Box<Lyrics> _lyricsBox;

  ObjectBox._create(this._store) {
    // Optional: enable ObjectBox Admin on debug builds.
    // https://docs.objectbox.io/data-browser
    if (Admin.isAvailable()) {
      // Keep a reference until no longer needed or manually closed.
      _admin = Admin(_store);
    }

    _artistBox = Box<Artist>(_store);
    _lyricsBox = Box<Lyrics>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    // Note: setting a unique directory is recommended if running on desktop
    // platforms. If none is specified, the default directory is created in the
    // users documents directory, which will not be unique between apps.
    // On mobile this is typically fine, as each app has its own directory
    // structure.

    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(
        directory: p.join(
            (await getApplicationDocumentsDirectory()).path, "tononkira"));
    return ObjectBox._create(store);
  }

  Stream<List<Lyrics>> getAllLyricsSortedByDate() {
    // Query for all tasks, sorted by their date.
    // https://docs.objectbox.io/queries
    final qBuilderTasks =
        _lyricsBox.query().order(Lyrics_.dateCreated, flags: Order.descending);
    // Build and watch the query,
    // set triggerImmediately to emit the query immediately on listen.
    return qBuilderTasks
        .watch(triggerImmediately: true)
        // Map it to a list of tasks to be used by a StreamBuilder.
        .map((query) => query.find());
  }

  Lyrics getLyrics(int id) => _lyricsBox.get(id)!;

  void saveLyrics(Lyrics? lyrics, String content, Artist artist, String title,
      String link) {
    if (content.isEmpty || link.isEmpty) {
      // Do not allow an empty task text.
      // A real app might want to display an UI hint about that.
      return;
    }
    if (lyrics == null) {
      // Add a new task (task id is 0).
      lyrics = Lyrics(content: content, link: link, title: title);
    } else {
      // Update an existing task (task id is > 0).
      lyrics.content = content;
    }
    // Set or update the target of the to-one relation to Tag.
    lyrics.artist.target = artist;
    _lyricsBox.putAsync(lyrics);
  }

  void removeLyrics(int lyricsId) => _lyricsBox.removeAsync(lyricsId);

  Future<int> addLyrics(
      String content, String link, String title, int artistId) async {
    if (link.isEmpty || content.isEmpty) {
      // Do not allow an empty tag name.
      // A real app might want to display an UI hint about that.
      return -1;
    }
    // Do not allow adding a tag with an existing name.
    // A real app might want to display an UI hint about that.
    final existingLyrics = await _lyricsBox.getAllAsync();
    final artist = await _artistBox.getAsync(artistId);
    for (var existingLyric in existingLyrics) {
      if (existingLyric.link == link) {
        return existingLyric.id;
      }
    }

    final lyrics = Lyrics(content: content, link: link, title: title);
    lyrics.artist.target = artist;

    return await _lyricsBox.putAsync(lyrics);
  }

  Future<int> addArtist(String name, String link) async {
    if (link.isEmpty || name.isEmpty) {
      // Do not allow an empty tag name.
      // A real app might want to display an UI hint about that.
      return -1;
    }
    // Do not allow adding a tag with an existing name.
    // A real app might want to display an UI hint about that.
    final existingArtists = await _artistBox.getAllAsync();
    for (var existingArtist in existingArtists) {
      if (existingArtist.link == link) {
        return existingArtist.id;
      }
    }

    final artist = Artist(name: name, link: link);
    return await _artistBox.putAsync(artist);
  }

  Artist getArtist(int id) => _artistBox.get(id)!;
  Artist? getArtistByLink(String link) =>
      _artistBox.query(Artist_.link.equals(link)).build().findFirst();
  Lyrics? getLyricsByLink(String link) =>
      _lyricsBox.query(Lyrics_.link.equals(link)).build().findFirst();

  List<LyricsOBox> getAllLyrics() =>
      _lyricsBox.getAll().map((e) => e.toObjectBox()).toList();
  List<Artist> getAllArtists() => _artistBox.getAll();

  Future<List<Lyrics>> getAllLyricsAsync() => _lyricsBox.getAllAsync();
}
