import 'package:hypertext/constants.dart';
import 'package:hypertext/link.dart';
import 'package:hypertext/parser.dart';

class EmailParser implements Parser {
  String text;

  EmailParser(this.text);

  parse() {
    String pattern = r"[\w-\.]+@([\w-]+\.)+[\w-]{2,4}";

    RegExp regExp = RegExp(pattern);

    Iterable<RegExpMatch> _allMatches = regExp.allMatches(text);
    List<Link> _links = List<Link>();
    for (RegExpMatch match in _allMatches) {
      _links.add(Link(regExpMatch: match, type: email));
    }
    return _links;
  }
}
