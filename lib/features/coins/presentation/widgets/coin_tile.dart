import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/coin.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const CoinTile({
    super.key,
    required this.coin,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = coin.change;
    final changeColor = (change ?? 0) >= 0
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${coin.rank ?? '-'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _CoinIcon(url: coin.iconUrl, symbol: coin.symbol, heroTag: 'coin-icon-${coin.uuid}'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.symbol,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.price(coin.price),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.percent(coin.change),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFavorite
                    ? const Color(0xFFFFB300)
                    : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: onFavoriteToggle,
              tooltip: isFavorite
                  ? AppLocalizations.of(context).removeFavorite
                  : AppLocalizations.of(context).addFavorite,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  final String? url;
  final String symbol;
  final String heroTag;
  const _CoinIcon({
    required this.url,
    required this.symbol,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: 18,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        symbol.isEmpty ? '?' : symbol[0],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    Widget child;
    if (url == null || url!.isEmpty || url!.endsWith('.svg')) {
      child = fallback;
    } else {
      child = ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      );
    }
    return Hero(
      tag: heroTag,
      flightShuttleBuilder: (_, __, ___, ____, _____) => Material(
        type: MaterialType.transparency,
        child: child,
      ),
      child: child,
    );
  }
}
