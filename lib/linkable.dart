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

  final List<Parser> _parsers = <Parser>[];
  final List<Link> _links = <Link>[];

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

  @override
  Widget build(BuildContext context) {
    init();
    return SelectableText.rich(
      TextSpan(
        text: '',
        style: style,
        children: _getTextSpans(),
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

  _getTextSpans() {
    List<TextSpan> textSpans = <TextSpan>[];
    int i = 0;
    int pos = 0;
    while (i < text.length) {
      textSpans.add(_text(text.substring(
          i,
          pos < _links.length && i <= _links[pos].regExpMatch.start
              ? _links[pos].regExpMatch.start
              : text.length)));
      if (pos < _links.length && i <= _links[pos].regExpMatch.start) {
        textSpans.add(_link(
            text.substring(
                _links[pos].regExpMatch.start, _links[pos].regExpMatch.end),
            _links[pos].type));
        i = _links[pos].regExpMatch.end;
        pos++;
      } else {
        i = text.length;
      }
    }
    return textSpans;
  }

  _text(String text) {
    return TextSpan(text: text, style: TextStyle(color: textColor));
  }

  _link(String text, String type) {
    return TextSpan(
        text: text,
        style: TextStyle(color: linkColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _launch(_getUrl(text, type));
          });
  }

  _launch(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  _getUrl(String text, String type) {
    switch (type) {
      case http:
        return text.substring(0, 4) == 'http' ? text : 'http://$text';
      case email:
        return text.substring(0, 7) == 'mailto:' ? text : 'mailto:$text';
      case tel:
        return text.substring(0, 4) == 'tel:' ? text : 'tel:$text';
      default:
        return text;
    }
  }

  init() {
    _addParsers();
    _parseLinks();
    _filterLinks();
  }

  _addParsers() {
    _parsers.add(EmailParser(text));
    _parsers.add(HttpParser(text));
    _parsers.add(TelParser(text));
  }

  _parseLinks() {
    for (Parser parser in _parsers) {
      _links.addAll(parser.parse().toList());
    }
  }

  _filterLinks() {
    _links.sort(
        (Link a, Link b) => a.regExpMatch.start.compareTo(b.regExpMatch.start));

    List<Link> filteredLinks = <Link>[];
    if (_links.isNotEmpty) {
      filteredLinks.add(_links[0]);
    }

    for (int i = 0; i < _links.length - 1; i++) {
      if (_links[i + 1].regExpMatch.start > _links[i].regExpMatch.end) {
        filteredLinks.add(_links[i + 1]);
      }
    }
    _links.clear();
    _links.addAll(filteredLinks);
  }
}
