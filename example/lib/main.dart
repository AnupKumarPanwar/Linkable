import 'package:flutter/material.dart';
import 'package:hypertext/hypertext.dart';

void main() => runApp(new HypertextExample());

class HypertextExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hypertext example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hypertext example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Hypertext(
                textAlign: TextAlign.center,
                text:
                    "Hi!\nI'm Anup.\n\nYou can email me at 1anuppanwar@gmail.com.\nOr just whatsapp me @ +91-8968894728.\n\nFor more info visit: \ngithub.com/anupkumarpanwar \nor\nhttps://www.linkedin.com/in/anupkumarpanwar/",
                style: TextStyle(fontSize: 20),
                textColor: Colors.black,
                linkColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
