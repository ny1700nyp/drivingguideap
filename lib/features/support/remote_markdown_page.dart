import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';

/// Full-screen page that loads markdown from a URL and renders it.
class RemoteMarkdownPage extends StatefulWidget {
  const RemoteMarkdownPage({
    super.key,
    required this.title,
    required this.rawUrl,
  });

  final String title;
  final String rawUrl;

  @override
  State<RemoteMarkdownPage> createState() => _RemoteMarkdownPageState();
}

class _RemoteMarkdownPageState extends State<RemoteMarkdownPage> {
  late final Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<String> _load() async {
    final response = await http
        .get(Uri.parse(widget.rawUrl))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final body = response.body;
    if (body.trim().isEmpty) {
      throw Exception('empty body');
    }
    return body;
  }

  Future<void> _onLinkTap(String? href) async {
    if (href == null) {
      return;
    }
    final uri = Uri.tryParse(href);
    if (uri == null) {
      return;
    }
    if (!await canLaunchUrl(uri)) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final mdStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockSpacing: 12,
      h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      a: theme.textTheme.bodyLarge?.copyWith(
        color: scheme.primary,
        decoration: TextDecoration.underline,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<String>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.supportDocumentLoadError,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          return Markdown(
            data: snapshot.data!,
            selectable: true,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            onTapLink: (text, href, title) {
              unawaited(_onLinkTap(href));
            },
            styleSheet: mdStyle,
          );
        },
      ),
    );
  }
}
