import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class TelParser implements Parser {
  String text;

  TelParser(this.text);

  @override
  parse() {
    String pattern = r"\+?\(?([0-9]{2,4})\)?[- ]?([0-9]{3,4})[- ]?([0-9]{3,7})";

    RegExp regExp = RegExp(pattern);

    Iterable<RegExpMatch> allMatches = regExp.allMatches(text);
    List<Link> links = <Link>[];
    for (RegExpMatch match in allMatches) {
      links.add(Link(regExpMatch: match, type: tel));
    }
    return links;
  }
}
