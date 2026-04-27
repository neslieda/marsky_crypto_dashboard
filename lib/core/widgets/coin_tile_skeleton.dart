import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CoinTileSkeleton extends StatelessWidget {
  const CoinTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const _Box(width: 28, height: 16, radius: 4),
            const SizedBox(width: 12),
            const CircleAvatar(radius: 18, backgroundColor: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Box(width: 120, height: 14, radius: 4),
                  SizedBox(height: 8),
                  _Box(width: 60, height: 12, radius: 4),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Box(width: 80, height: 14, radius: 4),
                SizedBox(height: 8),
                _Box(width: 50, height: 12, radius: 4),
              ],
            ),
            const SizedBox(width: 8),
            const _Box(width: 24, height: 24, radius: 12),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Box({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class CoinListSkeleton extends StatelessWidget {
  final int itemCount;
  const CoinListSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, __) => const CoinTileSkeleton(),
    );
  }
}
