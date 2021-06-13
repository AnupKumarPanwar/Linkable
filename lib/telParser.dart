import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class TelParser implements Parser {
  String text;

  TelParser(this.text);

  parse() {
    String pattern = r"\+?\(?([0-9]{2,4})\)?[- ]?([0-9]{3,4})[- ]?([0-9]{3,7})";

    RegExp regExp = RegExp(pattern);

    Iterable<RegExpMatch> _allMatches = regExp.allMatches(text);
    List<Link> _links = <Link>[];
    for (RegExpMatch match in _allMatches) {
      _links.add(Link(regExpMatch: match, type: tel));
    }
    return _links;
  }
}
