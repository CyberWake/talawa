import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class ChatBubble extends StatelessWidget {
  final bool translate;
  final bool isMe;
  final String message;
  const ChatBubble({
    Key key,
    this.translate,
    this.isMe,
    this.message,
  }) : assert(isMe != null && message != null && translate!=null);

  static Future<String> translateMessage(
      String message, BuildContext context) async {
    Locale myLocale = Localizations.localeOf(context);
    String toLanguage;
    Translation translation;
    if(myLocale.languageCode.compareTo('zh')==0){
      toLanguage = '${myLocale.languageCode}-${myLocale.countryCode.toLowerCase()}';
    }else{
      toLanguage = '${myLocale.languageCode}';
    }
    try {
      translation = await GoogleTranslator().translate(
        message,
        from: 'auto',
        to: toLanguage,
      );
    } on Exception catch (e) {
      print(e.toString()+' $toLanguage');
      translation.text = message;
    }
    return translation.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: isMe ? 0 : 15,
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).primaryColor.withOpacity(0.5)
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: isMe
                          ? Radius.circular(5)
                          : Radius.circular(30),
                      topLeft: isMe
                          ? Radius.circular(30)
                          : Radius.circular(5),
                      bottomLeft: Radius.circular(30))),
              child: Column(
                children: [
                  Padding(
                    padding: translate && !isMe
                        ? const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6.5)
                        : const EdgeInsets.all(13.0),
                    child: Text(
                      message,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: translate && !isMe ? 13 : 17),
                    ),
                  ),
                  translate && !isMe
                      ? FutureBuilder(
                    future: translateMessage(message, context),
                      builder:
                          (BuildContext context, AsyncSnapshot snapshot) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6.5),
                              child: Text(
                                snapshot.hasData?snapshot.data:'...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            );
                        })
                      : SizedBox()
                ],
              ),
            ),
          ),
          SizedBox(
            width: isMe ? 15 : 0,
          ),
        ],
      ),
    );
  }
}
