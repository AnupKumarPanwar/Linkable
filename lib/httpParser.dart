import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class HttpParser implements Parser {
  String text;

  HttpParser(this.text);

  parse() {
    String pattern =
        r"(http(s)?:\/\/)?(www.)?[a-zA-Z0-9]{2,256}\.[a-zA-Z0-9]{2,256}(\.[a-zA-Z0-9]{2,256})?([-a-zA-Z0-9@:%_\+~#?&//=.]*)([-a-zA-Z0-9@:%_\+~#?&//=]+)";

    RegExp regExp = RegExp(pattern, caseSensitive: false);

    Iterable<RegExpMatch> _allMatches = regExp.allMatches(text);
    List<Link> _links = <Link>[];
    for (RegExpMatch match in _allMatches) {
      _links.add(Link(regExpMatch: match, type: http));
    }
    return _links;
  }
}
