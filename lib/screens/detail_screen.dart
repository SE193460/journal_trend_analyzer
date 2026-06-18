import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/publication.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class DetailScreen extends StatelessWidget {
  final Publication publication;

  const DetailScreen({super.key, required this.publication});

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    if (!urlString.startsWith('http')) {
      urlString = 'https://doi.org/$urlString';
    }
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = publication;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Publication"),
        actions: [
          if (p.doi.isNotEmpty)
            IconButton(
              tooltip: "Open paper",
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              onPressed: () => _launchUrl(p.doi),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHero(p),
          const SizedBox(height: 16),
          _buildOverview(p),
          const SizedBox(height: 16),
          _buildMetrics(p),
          const SizedBox(height: 16),
          _buildTaxonomy(p),
          const SizedBox(height: 16),
          _buildAccessAndFunding(p),
          if (p.abstractText.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAbstract(p),
          ],
        ],
      ),
    );
  }

  // ─── Hero ────────────────────────────────────────────────

  Widget _buildHero(Publication p) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title.isNotEmpty ? p.title : "Untitled work",
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (p.year > 0)
                MetaChip(
                    icon: Icons.calendar_today_rounded,
                    label: "${p.year}",
                    color: AppColors.emerald),
              MetaChip(
                  icon: Icons.format_quote_rounded,
                  label: "${_compact(p.citationCount)} citations",
                  color: AppColors.primary),
              if (p.type.isNotEmpty)
                MetaChip(
                    icon: Icons.category_rounded,
                    label: p.type,
                    color: AppColors.indigo),
              if (p.openAccessStatus.isNotEmpty)
                MetaChip(
                    icon: Icons.lock_open_rounded,
                    label: p.openAccessStatus,
                    color: AppColors.amber),
            ],
          ),
          if (p.doi.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(p.doi),
                icon: const Icon(Icons.description_rounded, size: 18),
                label: const Text("Read full paper"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Sections ────────────────────────────────────────────

  Widget _buildOverview(Publication p) {
    return _group("Overview", Icons.info_outline_rounded, [
      _kv("Source", p.journal.isNotEmpty ? p.journal : "N/A",
          highlight: p.journal.isNotEmpty),
      _kvExpandable("Authors", p.authors),
      _kvExpandable("Institutions", p.institutions),
      _kv("Language", p.language.isNotEmpty ? p.language : "N/A"),
    ]);
  }

  Widget _buildMetrics(Publication p) {
    return _group("Citations & metrics", Icons.insights_rounded, [
      _kv("FWCI", p.fwci > 0 ? p.fwci.toString() : "N/A"),
      _kv("References", p.cites > 0 ? "${p.cites}" : "0"),
      _kv("Cited by", "${p.citationCount}", highlight: true),
      _kv("Related works", "${p.relatedTo}"),
      if (p.doi.isNotEmpty)
        _kv("DOI", p.doi, highlight: true, onTap: () => _launchUrl(p.doi)),
    ]);
  }

  Widget _buildTaxonomy(Publication p) {
    return _group("Topic taxonomy", Icons.account_tree_rounded, [
      _kv("Topic", p.topic.isNotEmpty ? p.topic : "N/A", highlight: true),
      _kv("Subfield", p.subfield.isNotEmpty ? p.subfield : "N/A"),
      _kv("Field", p.field.isNotEmpty ? p.field : "N/A"),
      _kv("Domain", p.domain.isNotEmpty ? p.domain : "N/A"),
      _kv("SDG", p.sdg.isNotEmpty ? p.sdg : "N/A"),
    ]);
  }

  Widget _buildAccessAndFunding(Publication p) {
    return _group("Access & funding", Icons.volunteer_activism_rounded, [
      _kv("Open access",
          p.openAccessStatus.isNotEmpty ? p.openAccessStatus : "N/A"),
      _kvExpandable("Funders", p.funders),
      _kvExpandable("Awards", p.awards),
    ]);
  }

  Widget _buildAbstract(Publication p) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: "Abstract", icon: Icons.notes_rounded),
          const SizedBox(height: 12),
          Text(
            p.abstractText,
            style: const TextStyle(
                fontSize: 14.5, height: 1.65, color: AppColors.body),
          ),
        ],
      ),
    );
  }

  // ─── Building blocks ─────────────────────────────────────

  Widget _group(String title, IconData icon, List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(const Divider(height: 22));
      }
    }
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, icon: icon),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String label, String value,
      {bool highlight = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvExpandable(String label, List<String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(child: ExpandableValue(items: items)),
      ],
    );
  }

  String _compact(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }
}

/// Shows a comma-joined list of values, collapsing long lists behind a
/// "+N more" / "Show less" toggle.
class ExpandableValue extends StatefulWidget {
  final List<String> items;
  final int maxItemsToShow;

  const ExpandableValue({
    super.key,
    required this.items,
    this.maxItemsToShow = 5,
  });

  @override
  State<ExpandableValue> createState() => _ExpandableValueState();
}

class _ExpandableValueState extends State<ExpandableValue> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: AppColors.ink);
    const linkStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary);

    if (widget.items.isEmpty) {
      return const Text("N/A", style: valueStyle);
    }

    final canToggle = widget.items.length > widget.maxItemsToShow;
    final visible = (!canToggle || _expanded)
        ? widget.items
        : widget.items.take(widget.maxItemsToShow).toList();

    final spans = <TextSpan>[
      TextSpan(text: visible.join(", "), style: valueStyle),
    ];
    if (canToggle) {
      spans.add(const TextSpan(text: "  "));
      spans.add(TextSpan(
        text: _expanded
            ? "Show less"
            : "+${widget.items.length - widget.maxItemsToShow} more",
        style: linkStyle,
      ));
    }

    return GestureDetector(
      onTap: canToggle ? () => setState(() => _expanded = !_expanded) : null,
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}
