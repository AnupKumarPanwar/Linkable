library linkable;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkable/constants.dart';
import 'package:linkable/emailParser.dart';
import 'package:linkable/httpParser.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';
import 'package:linkable/telParser.dart';
import 'package:url_launcher/url_launcher.dart';

class Linkable extends StatefulWidget {
  final String text;

  final textColor;

  final linkColor;

  final style;

  final textAlign;

  final textDirection;

  final maxLines;

  final overflow;

  final textScaleFactor;

  final softWrap;

  final strutStyle;

  final locale;

  final textWidthBasis;

  final textHeightBehavior;

  Linkable({
    Key key,
    @required this.text,
    this.textColor = Colors.black,
    this.linkColor = Colors.blue,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  _LinkableState createState() => _LinkableState();
}

class _LinkableState extends State<Linkable> {
  List<Parser> _parsers = List<Parser>();
  List<Link> _links = List<Link>();

  @override
  void initState() {
    super.initState();
    _addParsers();
    _parseLinks();
    _filterLinks();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      text: TextSpan(
        text: '',
        style: widget.style,
        children: _getTextSpans(),
      ),
    );
  }

  _addParsers() {
    _parsers.add(EmailParser(widget.text));
    _parsers.add(HttpParser(widget.text));
    _parsers.add(TelParser(widget.text));
  }

  _parseLinks() {
    for (Parser parser in _parsers) {
      _links.addAll(parser.parse().toList());
    }
  }

  _filterLinks() {
    _links.sort(
        (Link a, Link b) => a.regExpMatch.start.compareTo(b.regExpMatch.start));

    List<Link> _filteredLinks = List<Link>();
    if (_links.length > 0) {
      _filteredLinks.add(_links[0]);
    }

    for (int i = 0; i < _links.length - 1; i++) {
      if (_links[i + 1].regExpMatch.start > _links[i].regExpMatch.end) {
        _filteredLinks.add(_links[i + 1]);
      }
    }
    _links = _filteredLinks;
  }

  _getTextSpans() {
    List<TextSpan> _textSpans = List<TextSpan>();
    int i = 0;
    int pos = 0;
    while (i < widget.text.length) {
      _textSpans.add(_text(widget.text.substring(
          i,
          pos < _links.length && i < _links[pos].regExpMatch.start
              ? _links[pos].regExpMatch.start
              : widget.text.length)));
      if (pos < _links.length && i < _links[pos].regExpMatch.start) {
        _textSpans.add(_link(
            widget.text.substring(
                _links[pos].regExpMatch.start, _links[pos].regExpMatch.end),
            _links[pos].type));
        i = _links[pos].regExpMatch.end;
        pos++;
      } else {
        i = widget.text.length;
      }
    }
    return _textSpans;
  }

  _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _text(String text) {
    return TextSpan(text: text, style: TextStyle(color: widget.textColor));
  }

  _link(String text, String type) {
    return TextSpan(
        text: text,
        style: TextStyle(color: widget.linkColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _launch(_getUrl(text, type));
          });
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
}
