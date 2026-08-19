import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../design_system/tokens/fraternus_colors.dart';
import '../../design_system/tokens/fraternus_typography.dart';

/// Renders a [FratNightTemplate.reading] with the physical Frat Night
/// booklet's own styling: `##` section headings in the accent (terracotta)
/// color, `###` sub-headings in forest green, and every bullet-list item
/// rendered as a discussion question — a tan "†" in place of the bullet
/// (the booklet's own dagger marker) with the question text tinted to
/// match, since the palette has no true yellow.
///
/// Authoring convention for [data]:
/// - `##` for major sections — "Prayer", "Welcome", "Ground Rules",
///   "Introduction Questions", "Challenge", etc.
/// - `###` for sub-sections within a section — e.g. "Rule 1: Squad Time is
///   Always Real."
/// - `- ` bullet-list lines for every discussion question a squad leader
///   reads aloud — any bullet list in [data] is treated as questions, so
///   don't use lists for anything else.
/// - plain paragraphs for narrative/instructional text (e.g. the Challenge
///   description).
/// - standard `*emphasis*` / `**strong**` inline markdown works everywhere
///   except inside question text, which renders as plain text.
class FratNightReadingMarkdown extends StatelessWidget {
  const FratNightReadingMarkdown({super.key, required this.data});

  final String data;

  static final _questionStyle = FraternusTypography.body(
    color: FraternusColors.accentSecondary,
  ).copyWith(fontWeight: FontWeight.w600);

  static final _questionMarkerStyle = FraternusTypography.body(
    color: FraternusColors.accentSecondary,
  ).copyWith(fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      styleSheet: MarkdownStyleSheet(
        h2: FraternusTypography.h3(color: FraternusColors.accentPrimary),
        h2Padding: const EdgeInsets.only(top: 20, bottom: 6),
        h3: FraternusTypography.h4(color: FraternusColors.forestGreen),
        h3Padding: const EdgeInsets.only(top: 14, bottom: 4),
        p: FraternusTypography.body(color: FraternusColors.textOnLight),
        pPadding: const EdgeInsets.only(bottom: 8),
        strong: const TextStyle(fontWeight: FontWeight.w700),
        em: const TextStyle(fontStyle: FontStyle.italic),
        listIndent: 22,
        listBulletPadding: const EdgeInsets.only(right: 8),
        blockSpacing: 10,
      ),
      bulletBuilder: (parameters) => Text('†', style: _questionMarkerStyle),
      builders: {'li': _QuestionBuilder(_questionStyle)},
    );
  }
}

/// Replaces the default `li` rendering (which would inherit `p`'s ink
/// color) with the tan "question" color. Renders as plain text — inline
/// markdown inside a question is intentionally not supported, keeping
/// question authoring simple.
class _QuestionBuilder extends MarkdownElementBuilder {
  _QuestionBuilder(this.style);

  final TextStyle style;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Text(element.textContent.trim(), style: style);
  }
}
