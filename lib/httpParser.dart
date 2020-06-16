import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class HttpParser implements Parser {
  String text;

  HttpParser(this.text);

  parse() {
    String pattern =
        r"[(http(s)?):\/\/(www\.)?a-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-z0-9@:%_\+.~#?&//=]*)";

    RegExp regExp = RegExp(pattern, caseSensitive: false);

    Iterable<RegExpMatch> _allMatches = regExp.allMatches(text);
    List<Link> _links = List<Link>();
    for (RegExpMatch match in _allMatches) {
      _links.add(Link(regExpMatch: match, type: http));
    }
    return _links;
  }
}
