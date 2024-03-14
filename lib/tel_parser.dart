import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class TelParser implements Parser {
  const TelParser(
    this.text, {
    this.regExpPattern,
  });

  final String text;
  final String? regExpPattern;

  @override
  List<Link> parse() {
    const pattern =
        r"\+?\(?([0-9]{2,4})\)?[- .]?([0-9]{3,4})[- .]?([0-9]{3,7})";

    final regExp = RegExp(regExpPattern ?? pattern);
    final allMatches = regExp.allMatches(text);
    final links = <Link>[];

    for (final match in allMatches) {
      links.add(Link(regExpMatch: match, type: tel));
    }

    return links;
  }
}
