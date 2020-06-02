# hypertext

A Flutter widget to add links to your text.

## Install
To install the package, add the following dependency to your `pubspec.yaml`
```
dependencies:
  hypertext: ^3.1.3
  url_launcher: ^5.4.10
```
## Usage
### Basic
```
import 'package:hypertext/hypertext.dart';

Hypertext(
	text:
	"Hi!\nI'm Anup.\n\nYou can email me at 1anuppanwar@gmail.com.\nOr just whatsapp me @ +91-8968894728.\n\nFor more info visit: \ngithub.com/anupkumarpanwar \nor\nhttps://www.linkedin.com/in/anupkumarpanwar/",
);
```

### Attributes
| Key  				| Description   												   	|
|-------------------|-------------------------------------------------------------------|
| `text` 			| The text to be displyed in the widget.  							|
| `textColor` 		|  Color of the non-link text. (default: black)						|
| `linkColor` 		|  Color of the links. (default: blue) 								|
| `style` 			|  TextStyle to be applied on the widget. 							|
| `textAlign` 		|  TextAlign value. (default: TextAlign.start)						|
| `textDirection` 	|  Determines the order to lay children out horizontally. 			|
| `maxLines` 		|  Maximum number of lines to be displyed. 							|
| `overflow` 		|  Handles text that crosses maxLines. (default: TextOverflow.clip)	|
| `textScaleFactor`	|  The number of font pixels for each logical pixel. 				|
| `locale` 			|  Sets text locale.												|

## Screenshot
![Screenshot](./example/screenshot.png)