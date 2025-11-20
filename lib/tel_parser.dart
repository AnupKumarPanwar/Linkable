import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class TelParser implements Parser {
  final String text;
  static final RegExp _pattern = RegExp(
    r"\+?\(?([0-9]{2,4})\)?[- ]?([0-9]{3,4})[- ]?([0-9]{3,7})",
  );

  const TelParser(this.text);

  @override
  List<Link> parse() {
    return _pattern
        .allMatches(text)
        .map((match) => Link(regExpMatch: match, type: tel))
        .toList();
  }
}
