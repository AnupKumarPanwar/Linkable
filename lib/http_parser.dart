import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class HttpParser implements Parser {
  final String text;
  static final RegExp _pattern = RegExp(
    r"(http(s)?:\/\/)?(www.)?[a-zA-Z0-9]{2,256}\.[a-zA-Z0-9]{2,256}(\.[a-zA-Z0-9]{2,256})?([-a-zA-Z0-9@:%_\+~#?&//=.]*)([-a-zA-Z0-9@:%_\+~#?&//=]+)",
    caseSensitive: false,
  );

  const HttpParser(this.text);

  @override
  List<Link> parse() {
    return _pattern
        .allMatches(text)
        .map((match) => Link(regExpMatch: match, type: http))
        .toList();
  }
}
