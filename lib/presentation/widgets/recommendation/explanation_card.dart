import 'package:flutter/material.dart';

class ExplanationCard extends StatelessWidget {
  final String explanation;

  const ExplanationCard({
    Key? key,
    required this.explanation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> sections = _parseSections(explanation);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
                SizedBox(width: 12),
                Text(
                  'AI Assessment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D69E3)),
                ),
              ],
            ),
            const Divider(height: 30),
            
            // Show sections
            for (int i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              _formatSection(sections[i]),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _parseSections(String explanation) {
    final List<String> sections = [];
    String currentSection = '';
    
    // Process lines and divide into sections
    for (final line in explanation.split('\n')) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) {
        if (currentSection.isNotEmpty) {
          sections.add(currentSection);
          currentSection = '';
        }
      } else if (trimmedLine.startsWith('ANALYSIS SUMMARY:') || 
                trimmedLine.startsWith('BEST RECOMMENDATION:') ||
                trimmedLine.startsWith('ALTERNATIVE RECOMMENDATION:') ||
                trimmedLine.startsWith('PURCHASE TIPS:') ||
                trimmedLine.contains('ANALYSIS') ||
                trimmedLine.contains('RECOMMENDATION') ||
                trimmedLine.contains('ALTERNATIVE') ||
                trimmedLine.contains('TIPS')) {
        // If this is a header, add the previous section and start a new one
        if (currentSection.isNotEmpty) {
          sections.add(currentSection);
        }
        currentSection = trimmedLine;
      } else {
        // Normal text, add to current section
        if (currentSection.isNotEmpty) {
          currentSection += '\n$trimmedLine';
        } else {
          currentSection = trimmedLine;
        }
      }
    }
    
    // Add the last section
    if (currentSection.isNotEmpty) {
      sections.add(currentSection);
    }
    
    return sections;
  }

  Widget _formatSection(String section) {
    final lines = section.split('\n');
    final isHeader = 
        lines.first.startsWith('ANALYSIS SUMMARY:') || 
        lines.first.startsWith('BEST RECOMMENDATION:') ||
        lines.first.startsWith('ALTERNATIVE RECOMMENDATION:') ||
        lines.first.startsWith('PURCHASE TIPS:') ||
        lines.first.contains('ANALYSIS') ||
        lines.first.contains('RECOMMENDATION') ||
        lines.first.contains('ALTERNATIVE') ||
        lines.first.contains('TIPS') ||
        lines.first.startsWith('#');
                    
    if (isHeader && lines.length > 1) {
      // Header and content
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF5D69E3).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lines.first,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF5D69E3),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lines.sublist(1).join('\n'),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      );
    } else {
      // Normal paragraph
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          section,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      );
    }
  }
} 