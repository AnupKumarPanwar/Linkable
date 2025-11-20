library linkable;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkable/constants.dart';
import 'package:linkable/email_parser.dart';
import 'package:linkable/http_parser.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';
import 'package:linkable/tel_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class Linkable extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? linkColor;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final double? textScaleFactor;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  Linkable({
    Key? key,
    required this.text,
    this.textColor = Colors.black,
    this.linkColor = Colors.blue,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  }) : super(key: key);

  List<Link> _parseLinks() {
    final parsers = <Parser>[
      EmailParser(text),
      HttpParser(text),
      TelParser(text),
    ];

    final allLinks = <Link>[];
    for (final parser in parsers) {
      allLinks.addAll(parser.parse());
    }

    if (allLinks.isEmpty) return allLinks;

    // Sort by start position
    allLinks.sort((a, b) => a.regExpMatch.start.compareTo(b.regExpMatch.start));

    // Filter overlapping links, keeping the first occurrence
    final filteredLinks = <Link>[allLinks.first];
    for (var i = 1; i < allLinks.length; i++) {
      if (allLinks[i].regExpMatch.start > filteredLinks.last.regExpMatch.end) {
        filteredLinks.add(allLinks[i]);
      }
    }

    return filteredLinks;
  }

  List<TextSpan> _getTextSpans(List<Link> links) {
    if (links.isEmpty) {
      return [_text(text)];
    }

    final textSpans = <TextSpan>[];
    var currentIndex = 0;

    for (final link in links) {
      final match = link.regExpMatch;
      
      // Add text before the link
      if (currentIndex < match.start) {
        textSpans.add(_text(text.substring(currentIndex, match.start)));
      }

      // Add the link
      final linkText = text.substring(match.start, match.end);
      textSpans.add(_link(linkText, link.type));
      currentIndex = match.end;
    }

    // Add remaining text after the last link
    if (currentIndex < text.length) {
      textSpans.add(_text(text.substring(currentIndex)));
    }

    return textSpans;
  }

  TextSpan _text(String text) {
    return TextSpan(text: text, style: TextStyle(color: textColor));
  }

  TextSpan _link(String text, String type) {
    return TextSpan(
      text: text,
      style: TextStyle(color: linkColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () => _launch(_getUrl(text, type)),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String _getUrl(String text, String type) {
    switch (type) {
      case http:
        return text.startsWith('http') ? text : 'http://$text';
      case email:
        return text.startsWith('mailto:') ? text : 'mailto:$text';
      case tel:
        return text.startsWith('tel:') ? text : 'tel:$text';
      default:
        return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = _parseLinks();
    final textSpans = _getTextSpans(links);

    return SelectableText.rich(
      TextSpan(
        text: '',
        style: style,
        children: textSpans,
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
