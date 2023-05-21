import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:tononkira/main.dart';
import 'package:tononkira/model.dart';
import 'package:tononkira/modules/get_lyrics_by_url.dart';

class LyricsPage extends StatefulWidget {
  final LyricsOBox item;

  const LyricsPage({super.key, required this.item});

  @override
  State<StatefulWidget> createState() => _LyricsPage();
}

class _LyricsPage extends State<LyricsPage> {
  late Future<String> _dataFuture;
  late Future<dynamic> existingLyrics;
  bool loading = false;
  bool? isConnected;

  @override
  void initState() {
    super.initState();
    final data = objectbox.getLyricsByLink(widget.item.link);
    if (data == null || data.content.isEmpty) {
      _dataFuture = getLyricsByUrl(widget.item.link);
    } else {
      widget.item.id = data.id;
      _dataFuture = Future.value(data.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _dataFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              // Display the data
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () async {
                      // Here we save or delete the lyrics
                      setState(() {
                        loading = true;
                      });
                      if (widget.item.id != null) {
                        // Delete and go to the homepage
                        objectbox.removeLyrics(widget.item.id as int);
                        setState(() {
                          widget.item.id = null;
                        });

                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute<void>(
                        //     builder: (BuildContext context) => const Home(),
                        //   ),
                        // );
                      } else {
                        // Save
                        final artist = await objectbox.addArtist(
                            widget.item.artist.name, widget.item.artist.link);
                        final lyrics = await objectbox.addLyrics(snapshot.data,
                            widget.item.link, widget.item.title, artist);
                        setState(() {
                          widget.item.id = lyrics;
                        });
                      }
                      setState(() {
                        loading = false;
                      });
                    },
                    icon: widget.item.id != null
                        ? const Icon(FluentIcons.delete_16_regular)
                        : loading
                            ? const CircularProgressIndicator()
                            : const Icon(FluentIcons.arrow_download_16_regular),
                  )
                ],
                title: Center(
                  child: ListTile(
                    title: Text(
                      widget.item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(widget.item.artist.name),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10),
                  child: Text(snapshot.data),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // Display an error message
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: const Center(
                child: Text("'You're not connected to the internet"),
              ),
            );
          } else {
            // Display a loading spinner
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
