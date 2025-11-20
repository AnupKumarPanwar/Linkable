import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class EmailParser implements Parser {
  final String text;
  static final RegExp _pattern = RegExp(r"[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

  const EmailParser(this.text);

  @override
  List<Link> parse() {
    return _pattern
        .allMatches(text)
        .map((match) => Link(regExpMatch: match, type: email))
        .toList();
  }
}
