import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkable/constants.dart';
import 'package:linkable/email_parser.dart';
import 'package:linkable/http_parser.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';
import 'package:linkable/tel_parser.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Linkable extends StatefulWidget {
  const Linkable({
    Key? key,
    required this.text,
    this.style,
    this.linkStyle = const TextStyle(color: Colors.blue),
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textScaleFactor = 1.0,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.mobileRegExp,
    this.onTelephoneTap,
    this.onLinkTap,
    this.onEmailTap,
    this.mobileSpan,
    this.parsersPriorityOrder = const [tel, email, http],
    this.selectable = false,
  })  : explicitPhoneNumbers = false,
        phoneNumberMatches = const [],
        super(key: key);

  /// Constructor that requires explicit list of phone numbers to be specified.
  /// Those phone numbers will be highlighted as links instead of parsing via
  /// default parser.
  const Linkable.explicitPhoneNumbers({
    Key? key,
    required this.text,
    required this.phoneNumberMatches,
    this.linkStyle = const TextStyle(color: Colors.blue),
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textScaleFactor = 1.0,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.mobileRegExp,
    this.onTelephoneTap,
    this.onLinkTap,
    this.onEmailTap,
    this.mobileSpan,
    this.parsersPriorityOrder = const [tel, email, http],
    this.selectable = false,
  })  : explicitPhoneNumbers = true,
        super(key: key);

  final String text;

  final TextStyle? linkStyle;

  final TextStyle? style;

  final TextAlign textAlign;

  final TextDirection? textDirection;

  final int? maxLines;

  final double textScaleFactor;

  final TextScaler textScaler;

  final StrutStyle? strutStyle;

  final TextWidthBasis textWidthBasis;

  final TextHeightBehavior? textHeightBehavior;

  final void Function(String value)? onTelephoneTap;

  final void Function(String value)? onLinkTap;

  final void Function(String value)? onEmailTap;

  final TextSpan Function(String value, GestureRecognizer function)? mobileSpan;

  final String? mobileRegExp;

  final bool explicitPhoneNumbers;

  /// List of phone numbers to be highlighted as links instead of parsing via
  /// default tel parser.
  final List<String> phoneNumberMatches;

  /// Defines how link will be recognized in case if it has matches for more
  /// then one pattern. Default is [tel, email, http], which means that tel
  /// matches have the highest priority.
  final List<String> parsersPriorityOrder;

  final bool selectable;

  @override
  State<Linkable> createState() => _LinkableState();
}

class _LinkableState extends State<Linkable> {
  final _parsers = <Parser>[];
  final _links = <Link>[];

  @override
  Widget build(BuildContext context) {
    init();

    if (widget.selectable) {
      return SelectableText.rich(
        TextSpan(
          style: widget.style,
          children: _getTextSpans(),
        ),
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        // ignore: deprecated_member_use
        textScaleFactor: widget.textScaleFactor,
        textScaler: widget.textScaler,
        maxLines: widget.maxLines,
        strutStyle: widget.strutStyle,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
      );
    }

    return RichText(
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      // ignore: deprecated_member_use
      textScaleFactor: widget.textScaleFactor,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      strutStyle: widget.strutStyle,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      text: TextSpan(
        style: widget.style,
        children: _getTextSpans(),
      ),
    );
  }

  List<TextSpan> _getTextSpans() {
    final textSpans = <TextSpan>[];
    int i = 0;
    int pos = 0;
    while (i < widget.text.length) {
      textSpans.add(_text(widget.text.substring(
          i,
          pos < _links.length && i <= _links[pos].regExpMatch.start
              ? _links[pos].regExpMatch.start
              : widget.text.length)));
      if (pos < _links.length && i <= _links[pos].regExpMatch.start) {
        textSpans.add(_link(
            widget.text.substring(
                _links[pos].regExpMatch.start, _links[pos].regExpMatch.end),
            _links[pos].type));
        i = _links[pos].regExpMatch.end;
        pos++;
      } else {
        i = widget.text.length;
      }
    }
    return textSpans;
  }

  TextSpan _text(String text) {
    return TextSpan(text: text, style: widget.style);
  }

  TextSpan _link(String text, String type) {
    if (widget.mobileSpan != null && type == tel) {
      return widget.mobileSpan!(
        text,
        TapGestureRecognizer()..onTap = () => _onTap(text, type),
      );
    }

    return TextSpan(
      text: text,
      style: (widget.style?.merge(widget.linkStyle)) ?? widget.linkStyle,
      recognizer: TapGestureRecognizer()..onTap = () => _onTap(text, type),
    );
  }

  void _onTap(String text, String type) {
    switch (type) {
      case http:
        return widget.onLinkTap != null
            ? widget.onLinkTap!(text)
            : _launch(_getUrl(text, type));
      case email:
        return widget.onEmailTap != null
            ? widget.onEmailTap!(text)
            : _launch(_getUrl(text, type));
      case tel:
        return widget.onTelephoneTap != null
            ? widget.onTelephoneTap!(text)
            : _launch(_getUrl(text, type));
      default:
        return _launch(_getUrl(text, type));
    }
  }

  void _launch(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _getUrl(String text, String type) {
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

  void init() {
    _addParsers();
    _parseLinks();
    _filterLinks();
  }

  void _addParsers() {
    for (final parserType in widget.parsersPriorityOrder) {
      switch (parserType) {
        case tel:
          if (widget.explicitPhoneNumbers) {
            /// If explicitPhoneNumbers is true, then TelParser is not need because
            /// phone number matches are provided by [phoneNumberMatches]
            break;
          }
          _parsers.add(
            TelParser(
              widget.text,
              regExpPattern: widget.mobileRegExp,
            ),
          );
          break;
        case email:
          _parsers.add(EmailParser(widget.text));
          break;
        case http:
          _parsers.add(HttpParser(widget.text));
          break;
      }
    }

    _parsers.add(HttpParser(widget.text));
  }

  void _parseLinks() {
    for (final parserName in widget.parsersPriorityOrder) {
      if (parserName == tel && widget.explicitPhoneNumbers) {
        _parseExplicitPhoneNumbers();
      } else {
        _links.addAll(_getParserByName(parserName).parse().toList());
      }
    }

    if (widget.explicitPhoneNumbers) {
      for (final matchStr in widget.phoneNumberMatches) {
        final match = RegExp(RegExp.escape(matchStr)).firstMatch(widget.text);

        if (match != null) {
          _links.add(Link(regExpMatch: match, type: tel));
        }
      }
    }
  }

  Parser _getParserByName(String name) {
    switch (name) {
      case tel:
        return _parsers.firstWhere((parser) => parser is TelParser);
      case email:
        return _parsers.firstWhere((parser) => parser is EmailParser);
      case http:
        return _parsers.firstWhere((parser) => parser is HttpParser);
      default:
        throw Exception('Parser name $name not found');
    }
  }

  void _parseExplicitPhoneNumbers() {
    for (final matchStr in widget.phoneNumberMatches) {
      final matches = RegExp(RegExp.escape(matchStr)).allMatches(widget.text);

      if (matches.isNotEmpty) {
        for (final match in matches) {
          _links.add(Link(regExpMatch: match, type: tel));
        }
      }
    }
  }

  void _filterLinks() {
    _links.sort((a, b) => a.regExpMatch.start.compareTo(b.regExpMatch.start));

    final filteredLinks = <Link>[];

    if (_links.isNotEmpty) {
      filteredLinks.add(_links[0]);
    }

    for (int i = 0; i < _links.length - 1; i++) {
      if (_links[i + 1].regExpMatch.start > _links[i].regExpMatch.end) {
        filteredLinks.add(_links[i + 1]);
      }
    }

    _links
      ..clear()
      ..addAll(filteredLinks);
  }
}
