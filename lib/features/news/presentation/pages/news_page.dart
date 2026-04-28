import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/news_bloc.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.news)),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state.status == NewsStatus.initial ||
              (state.status == NewsStatus.loading && state.items.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == NewsStatus.failure && state.items.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? '-',
              onRetry: () =>
                  context.read<NewsBloc>().add(const NewsLoadRequested()),
            );
          }
          if (state.items.isEmpty) {
            return EmptyView(
              icon: Icons.newspaper_outlined,
              message: l.newsEmpty,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<NewsBloc>().add(const NewsLoadRequested());
              await Future.delayed(const Duration(milliseconds: 350));
            },
            child: ListView.separated(
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = state.items[i];
                return ListTile(
                  title: Text(n.title),
                  subtitle: Text(
                    [
                      if (n.sourceName != null) n.sourceName!,
                      if (n.publishedAt != null) _ago(n.publishedAt!),
                      if (n.currencies.isNotEmpty) n.currencies.join(', '),
                    ].join(' • '),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: n.url));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${n.url} copied')),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
