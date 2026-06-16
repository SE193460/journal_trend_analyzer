import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/publication.dart';

class DetailScreen extends StatelessWidget {
  final Publication publication;

  const DetailScreen({
    super.key,
    required this.publication,
  });

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    
    if (!urlString.startsWith('http')) {
      urlString = 'https://doi.org/$urlString';
    }

    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work", style: TextStyle(color: Colors.black87, fontSize: 16)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.api, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, size: 20), onPressed: () {}),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publication.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 16),
              if (publication.doi.isNotEmpty) ...[
                InkWell(
                  onTap: () => _launchUrl(publication.doi),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E9E9E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lock, color: Colors.white, size: 14),
                        SizedBox(width: 8),
                        Text(
                          "HTML",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.open_in_new, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: 16),
              
              _buildInfoRow("Year: ", publication.year > 0 ? publication.year.toString() : "N/A"),
              const SizedBox(height: 8),
              _buildInfoRow("Type: ", publication.type.isNotEmpty ? publication.type : "N/A"),
              const SizedBox(height: 8),
              if (publication.journal.isNotEmpty) ...[
                _buildInfoRow("Source: ", publication.journal, isBlue: true),
                const SizedBox(height: 8),
              ],
              ExpandableListRow(label: "Authors: ", items: publication.authors),
              const SizedBox(height: 8),
              ExpandableListRow(label: "Institutions: ", items: publication.institutions),
              const SizedBox(height: 8),
              _buildInfoRow("Language: ", publication.language.isNotEmpty ? publication.language : "N/A"),
              const SizedBox(height: 16),
              
              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: 16),
              
              _buildInfoRow("FWCI: ", publication.fwci > 0 ? publication.fwci.toString() : "N/A"),
              const SizedBox(height: 8),
              _buildInfoRow("Cites: ", publication.cites > 0 ? publication.cites.toString() : "0", isBlue: true),
              const SizedBox(height: 8),
              _buildInfoRow("Cited by: ", publication.citationCount > 0 ? publication.citationCount.toString() : "0", isBlue: true),
              const SizedBox(height: 8),
              _buildInfoRow("Related to: ", publication.relatedTo > 0 ? publication.relatedTo.toString() : "0", isBlue: true),
              if (publication.doi.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow("DOI: ", publication.doi, isBlue: true, onTap: () => _launchUrl(publication.doi)),
              ],
              const SizedBox(height: 16),

              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: 16),

              _buildInfoRow("Topic: ", publication.topic.isNotEmpty ? publication.topic : "N/A", isBlue: true),
              const SizedBox(height: 8),
              _buildInfoRow("Subfield: ", publication.subfield.isNotEmpty ? publication.subfield : "N/A", isBlue: true),
              const SizedBox(height: 8),
              _buildInfoRow("Field: ", publication.field.isNotEmpty ? publication.field : "N/A", isBlue: true),
              const SizedBox(height: 8),
              _buildInfoRow("Domain: ", publication.domain.isNotEmpty ? publication.domain : "N/A", isBlue: true),
              const SizedBox(height: 8),
              _buildInfoRow("SDG: ", publication.sdg.isNotEmpty ? publication.sdg : "N/A", isBlue: true),
              const SizedBox(height: 16),

              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: 16),
              _buildInfoRow("Open Access status: ", publication.openAccessStatus.isNotEmpty ? publication.openAccessStatus : "N/A"),
              const SizedBox(height: 16),

              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: 16),
              
              ExpandableListRow(label: "Funders: ", items: publication.funders),
              const SizedBox(height: 8),
              ExpandableListRow(label: "Awards: ", items: publication.awards),
              const SizedBox(height: 16),

              if (publication.abstractText.isNotEmpty) ...[
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 16),
                const Text(
                  "Abstract",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                ),
                const SizedBox(height: 8),
                Text(
                  publication.abstractText,
                  style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBlue = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF222222)),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 15, 
                color: isBlue ? const Color(0xFF1976D2) : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableListRow extends StatefulWidget {
  final String label;
  final List<String> items;

  const ExpandableListRow({super.key, required this.label, required this.items});

  @override
  State<ExpandableListRow> createState() => _ExpandableListRowState();
}

class _ExpandableListRowState extends State<ExpandableListRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Text.rich(TextSpan(children: [
        TextSpan(text: widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF222222))),
        const TextSpan(text: "N/A", style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
      ]));
    }

    const int maxItemsToShow = 5;
    
    List<TextSpan> spans = [
      TextSpan(
        text: widget.label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF222222)),
      ),
    ];

    if (widget.items.length <= maxItemsToShow || _isExpanded) {
      spans.add(TextSpan(
        text: widget.items.join(', '),
        style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      ));
      if (_isExpanded && widget.items.length > maxItemsToShow) {
        spans.add(const TextSpan(text: "  "));
        spans.add(const TextSpan(
          text: "Show less",
          style: TextStyle(fontSize: 15, color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
        ));
      }
    } else {
      String displayedItems = widget.items.take(maxItemsToShow).join(', ');
      int remainingCount = widget.items.length - maxItemsToShow;
      
      spans.add(TextSpan(
        text: displayedItems,
        style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      ));
      spans.add(const TextSpan(text: "  "));
      spans.add(TextSpan(
        text: "+$remainingCount more",
        style: const TextStyle(fontSize: 15, color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
      ));
    }

    return GestureDetector(
      onTap: () {
        if (widget.items.length > maxItemsToShow) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}