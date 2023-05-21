import 'dart:math';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart' as skeleton;
import 'package:tononkira/components/list_view.dart';
import 'package:tononkira/main.dart';
import 'package:tononkira/model.dart';
import 'package:tononkira/modules/search.dart';

import '../components/skeleton_list_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  final searchController = TextEditingController();
  List<LyricsOBox> data = [];
  bool loading = false;
  bool noResult = false;
  bool? isConnected;

  @override
  void initState() {
    super.initState();
    data = objectbox.getAllLyrics();
  }

  String error = '';

  @override
  Widget build(BuildContext context) {
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool isDarkMode = brightness == Brightness.dark;
    // if (!kReleaseMode) {
    //   print(isDarkMode);
    // }
    final itemCount = loading ? Random().nextInt(10) + 1 : data.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimSearchBar(
              width: MediaQuery.of(context).size.width * .9,
              textController: searchController,
              onSuffixTap: () {
                setState(() {
                  searchController.clear();
                });
              },
              onSubmitted: (str) async {
                setState(() {
                  error = '';
                  data = [];
                  noResult = false;
                  loading = true;
                });
                try {
                  final res = await fetchHTMLResult(str);
                  setState(() {
                    data = res;
                    noResult = data.isEmpty;
                    loading = false;
                  });
                } catch (e) {
                  setState(() {
                    error = "You're not connected to the internet";
                  });
                }
              },
            ),
          )
        ],
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: error != ''
          ? Center(child: Text(error))
          : loading || data.isNotEmpty
              ? skeleton.Skeleton(
                  isLoading: loading,
                  skeleton: SkeletonListView(
                    itemCount: itemCount,
                  ),
                  child: ListViewComponent(data: data),
                )
              : !noResult && data.isEmpty
                  ? const Center(child: Text('Start by searching for lyrics'))
                  : const Center(
                      child: Text('No result'),
                    ),
    );
  }
}
