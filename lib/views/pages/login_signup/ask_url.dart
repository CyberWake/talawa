import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/views/pages/login_signup/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:talawa/views/widgets/toast_tile.dart';

import 'login_page.dart';

class AskUrl extends StatefulWidget {
  final Function updatePage;
  final int currentPageIndex;
  final int previousPageIndex;
  AskUrl({this.updatePage,this.currentPageIndex,this.previousPageIndex});
  @override
  _AskUrlState createState() => _AskUrlState();
}

class _AskUrlState extends State<AskUrl> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final urlController = TextEditingController();
  Preferences _pref = Preferences();
  String saveMsg;
  String orgUrl, orgImgUrl;
  String urlInput;
  FToast fToast;
  bool isUrlCalled = false;

  AnimationController _loginController;
  // animation
  Animation loginAnimation;

  listenToUrl() {
    if (saveMsg == S.of(context).urlSaved && urlController.text != urlInput) {
      setState(() {
        saveMsg = S.of(context).setUrl;
      });
    }
    urlInput = urlController.text;
  }

  Future<void> checkAndSetUrl() async {
    setState(() {
      isUrlCalled = true;
    });
    String protocol;
    String domain='';
    String endPoint='';
    int endPointSlashIndex;
    if (urlController.text.contains('https')) {
      protocol = 'https';
      domain = urlController.text.substring(8);
      endPointSlashIndex = domain.indexOf('/');
      if (endPointSlashIndex!=-1) {
        endPoint = domain.substring(endPointSlashIndex);
        domain = domain.substring(0, endPointSlashIndex);
      }
    } else if (urlController.text.contains('http')) {
      protocol = 'http';
      domain = urlController.text.substring(7);
      endPointSlashIndex = domain.indexOf('/');
      if (endPointSlashIndex!=-1) {
        endPoint = domain.substring(endPointSlashIndex) + '/';
        domain = domain.substring(0, endPointSlashIndex);
      }
    }
    try {
      if (protocol.compareTo('https') == 0) {
        await http.get(Uri.https('$domain', '$endPoint'));
      } else if (protocol.compareTo('http') == 0) {
        await http.get(Uri.http('$domain', '$endPoint'));
      }
      setApiUrl();
      _setURL();
    } catch (e) {
      _exceptionToast('Incorrect Organization Entered');
    }

    setState(() {
      isUrlCalled = false;
    });
  }

  _exceptionToast(String msg) {
    fToast.showToast(
      child: ToastTile(
        msg: msg,
        success: false,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
    );
  }

  Future setApiUrl() async {
    _loginController.forward();
    orgUrl = urlController.text;
    orgImgUrl = urlController.text + "/talawa/";
    await _pref.saveOrgUrl(orgUrl);
    await _pref.saveOrgImgUrl(orgImgUrl);
  }

  void _setURL() {
    setState(() {
      saveMsg = S.of(context).urlSaved;
    });
  }

  @override
  void initState() {
    urlController.addListener(listenToUrl);
    _loginController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    loginAnimation = Tween(begin: 0.0, end: 1.0).animate(_loginController);
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (saveMsg==null) {
      saveMsg = S.of(context).setUrl;
    }
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              fit:FlexFit.loose,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[500],
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        widget.updatePage(newPageIndex:0);
                      },
                    ),
                  ),
                  Center(
                      child: Image(image: AssetImage(UIData.talawaLogo))),
                ],
              ),
            ),
            Flexible(
              fit:FlexFit.loose,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "TALAWA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                    ),
                  ),
                  Text(
                    ".",
                    style: TextStyle(
                      color: Color(0xFFFEBC59),
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Flexible(
              fit:FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: TextFormField(
                          keyboardType: TextInputType.url,
                          validator: (value) =>
                              Validator.validateURL(
                                  urlController.text),
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(50.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).textSelectionTheme.cursorColor),
                              borderRadius:
                              BorderRadius.circular(50.0),
                            ),
                            prefixIcon: Icon(Icons.web),
                            labelText: S
                                .of(context)
                                .hintSetUrl, //"Type Org URL Here",
                            alignLabelWithHint: true,
                            hintText:
                            'https://talawa-graphql-api.herokuapp.com/graphql',
                          ),
                          controller: urlController,
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        button(
                            buttonId: 0,
                            message: isUrlCalled
                                ? SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                  backgroundColor:
                                  Colors.white),
                            )
                                : Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 15.0),
                              child: Text(
                                saveMsg,
                              ),
                            ),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();

                                await checkAndSetUrl();
                              }
                            })
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.128,
            ),
            Flexible(
              fit:FlexFit.loose,
              child: FadeTransition(
                opacity: loginAnimation,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).padding.top*2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor.withOpacity(0.6)
                  ),
                  margin: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width*0.4,
                            height: MediaQuery.of(context).padding.top*2,
                            child: button(
                                buttonId: 2,
                                message: Text(S.of(context).login,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                onTap: () async {
                                  if (_formKey.currentState.validate() && saveMsg == S.of(context).urlSaved) {
                                    _formKey.currentState.save();
                                    widget.updatePage(newPageIndex:3);
                                  }
                                }),
                          )),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width*0.4,
                            height: MediaQuery.of(context).padding.top*2,
                            child: button(
                              buttonId: 1,
                              message: Text(S.of(context).createAccount,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              onTap: () async {
                                if (_formKey.currentState.validate() && saveMsg == S.of(context).urlSaved) {
                                  _formKey.currentState.save();
                                  widget.updatePage(newPageIndex:2);
                                }
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget button({Widget message, Function onTap,int buttonId}) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: buttonId==2?Colors.transparent:Theme.of(context).primaryColor,
          padding: EdgeInsets.zero,
          shape: buttonId==0?RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ):buttonId==1?RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(15),bottomLeft: Radius.circular(15)),
          ):RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(15),bottomRight: Radius.circular(15)),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:5.0),
          child: FittedBox(child: message),
        ));
  }
}
