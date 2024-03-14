import 'package:linkable/constants.dart';
import 'package:linkable/link.dart';
import 'package:linkable/parser.dart';

class HttpParser implements Parser {
  String text;

  HttpParser(this.text);

  @override
  List<Link> parse() {
    const pattern =
        r'\b((www\.|https?://)[^\s]+)|([a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+(:\d+)?(/[^\s]*)?)\b';

    final regExp = RegExp(pattern, caseSensitive: false);
    final allMatches = regExp.allMatches(text);
    final links = <Link>[];

    for (final match in allMatches) {
      String urlString = match.group(0)!;

      if (!urlString.startsWith('http://') &&
          !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }

      final uri = Uri.parse(urlString);

      if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.hasAuthority) {
        links.add(Link(regExpMatch: match, type: http));
      }
    }
    return links;
  }
}
