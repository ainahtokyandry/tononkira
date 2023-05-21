import 'package:flutter/material.dart';
import 'package:tononkira/model.dart';

import '../pages/lyrics.dart';

class ListViewComponent extends StatelessWidget {
  final List<LyricsOBox> data;
  const ListViewComponent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // if (kDebugMode) {
    //   print(data);
    // }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        color: Colors.black,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.artist.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LyricsPage(item: item),
              ),
            );
          },
        );
      },
    );
  }
}
