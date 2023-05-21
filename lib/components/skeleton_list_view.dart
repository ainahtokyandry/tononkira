import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const SkeletonListView({
    Key? key,
    required this.itemCount,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer(
          direction: ShimmerDirection.ltr,
          gradient: LinearGradient(
            begin: const Alignment(-1.0, -0.5),
            end: const Alignment(1.0, 0.5),
            colors: [
              Colors.grey[300]!,
              Colors.grey[100]!,
              Colors.grey[300]!,
            ],
            stops: const [0.4, 0.5, 0.6],
          ),
          child: ListTile(
            title: Container(
              height: 16,
              width: double.infinity,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
