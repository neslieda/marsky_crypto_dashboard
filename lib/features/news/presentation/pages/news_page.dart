import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../ai/presentation/cubit/ai_cubit.dart';
import '../../../ai/presentation/widgets/ai_insight_card.dart';
import '../bloc/news_bloc.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.news),
        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (a, b) => a.items.length != b.items.length,
            builder: (ctx, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Summarize',
                icon: const Icon(Icons.auto_awesome_rounded),
                onPressed: () => _openSummary(ctx, state),
              );
            },
          ),
        ],
      ),
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

  Future<void> _openSummary(BuildContext context, NewsState state) async {
    final lang = Localizations.localeOf(context).languageCode;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetCtx) {
        return BlocProvider(
          create: (_) => sl<AiCubit>()
            ..summarizeNews(items: state.items, languageCode: lang),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (_, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    lang == 'tr' ? 'Haber Ozeti' : 'News Summary',
                    style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Builder(builder: (ctx) {
                  return AiInsightCard(
                    title: lang == 'tr' ? 'AI Ozet' : 'AI Summary',
                    icon: Icons.summarize_rounded,
                    generateLabel: lang == 'tr' ? 'Tekrar' : 'Retry',
                    onGenerate: () => ctx.read<AiCubit>().summarizeNews(
                          items: state.items,
                          languageCode: lang,
                        ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
