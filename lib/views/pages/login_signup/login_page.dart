//flutter packages are called here
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/model/token.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/view_models/vm_login.dart';
import 'package:talawa/views/pages/home_page.dart';
import 'package:talawa/views/widgets/toast_tile.dart';

class LoginPage extends StatefulWidget {
  final Function updatePage;
  final int currentPageIndex;
  final int previousPageIndex;
  LoginPage({this.updatePage, this.currentPageIndex, this.previousPageIndex});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> with TickerProviderStateMixin {
  /// [TextEditingController]'s for email and password.
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  LoginViewModel model = new LoginViewModel();
  bool _progressBarState = false;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  Queries _query = Queries();
  FToast fToast;
  Preferences _pref = Preferences();
  bool _obscureText = true;

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  //providing the initial states to the variables
  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  //function for login user which gets called when sign in is press
  Future loginUser() async {
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(MutationOptions(
        document: gql(_query.loginUser(model.email, model.password))));
    bool connectionCheck = await DataConnectionChecker().hasConnection;
    if (!connectionCheck) {
      print('You are not connected to the internet');
      setState(() {
        _progressBarState = false;
      });
      _exceptionToast(
          'Connection Error. Make sure your Internet connection is stable');
    } else if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      if(result.exception.graphqlErrors.length>0){
        _exceptionToast('${result.exception.graphqlErrors[0].message}');
      }else if(result.exception.linkException.originalException!=null){
        _exceptionToast('Organization URL not valid');
      }
    } else if (!result.hasException && !result.isLoading) {
      setState(() {
        _progressBarState = true;
      });
      _successToast("All Set!");
      final Token accessToken =
          new Token(tokenString: result.data['login']['accessToken']);
      await _pref.saveToken(accessToken);
      final Token refreshToken =
          new Token(tokenString: result.data['login']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['login']['user']['_id'];
      await _pref.saveUserId(currentUserId);
      final String userFName = result.data['login']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['login']['user']['lastName'];
      await _pref.saveUserLName(userLName);

      List organisations = result.data['login']['user']['joinedOrganizations'];
      if (organisations.isEmpty) {
        //skip the steps below
      } else {
        //execute the steps below
        final String currentOrgId =
            result.data['login']['user']['joinedOrganizations'][0]['_id'];
        await _pref.saveCurrentOrgId(currentOrgId);

        final String currentOrgImgSrc =
            result.data['login']['user']['joinedOrganizations'][0]['image'];
        await _pref.saveCurrentOrgImgSrc(currentOrgImgSrc);

        final String currentOrgName =
            result.data['login']['user']['joinedOrganizations'][0]['name'];
        await _pref.saveCurrentOrgName(currentOrgName);
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    openPageIndex: 0,
                  )),
          (route) => false);
    }
  }

  Widget loginForm() {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AutofillGroup(
                child: Column(
              children: <Widget>[
                TextFormField(
                  autofillHints: <String>[AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  controller: _emailController,
                  validator: Validator.validateEmail,
                  style: TextStyle(),
                  //Changed text input action to next
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                    labelText: S.of(context).labelEmail,
                    labelStyle: TextStyle(),
                    alignLabelWithHint: true,
                    hintText: S.of(context).hintEmail,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSaved: (value) {
                    model.email = value;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autofillHints: <String>[AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  obscureText: _obscureText,
                  textAlign: TextAlign.left,
                  controller: _passwordController,
                  validator: Validator.validatePassword,
                  style: TextStyle(),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                    ),
                    suffixIcon: TextButton(
                      onPressed: _toggle,
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    labelText: S.of(context).labelPassword,
                    labelStyle: TextStyle(),
                    focusColor: UIData.primaryColor,
                    alignLabelWithHint: true,
                    hintText: S.of(context).hintPassword,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSaved: (value) {
                    model.password = value;
                  },
                ),
              ],
            )),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      child: Text(
                        S.of(context).signIn,
                        style: TextStyle(fontSize: 24),
                      ),
                      onTap: login),
                  FloatingActionButton(
                    onPressed: login,
                    child: _progressBarState
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                              strokeWidth: 3,
                              backgroundColor: Colors.black,
                            ))
                        : Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).textTheme.button.color,
                          ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  login() async {
    print(_progressBarState);
    if (!_progressBarState) {
      FocusScope.of(context).unfocus();
      //checks to see if all the fields have been validated then authenticate a user
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        loginUser();
        setState(() {
          toggleProgressBarState();
        });
      }
    }
  }

  //main build starts here
  @override
  build(BuildContext context) {
    Provider.of<GraphQLConfiguration>(context, listen: false).getOrgUrl();
    return SingleChildScrollView(
      child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).padding.top),
          constraints: const BoxConstraints(
              maxWidth: 300.0, minWidth: 250.0, minHeight: 300.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                    widget.updatePage(newPageIndex: 1);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 20),
                child: Text(S.of(context).titleWelcomeBack,
                    style:
                        TextStyle(fontSize: 42, fontWeight: FontWeight.w600,color:Theme.of(context).primaryColor)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    loginForm(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: workInProgress,
                            child: Container(
                                margin: EdgeInsets.only(left: 15),
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .textTheme
                                            .button
                                            .color)),
                                child: FaIcon(
                                  FontAwesomeIcons.google,
                                  size: 35,
                                )),
                          ),
                          GestureDetector(
                            onTap: workInProgress,
                            child: Container(
                                margin: EdgeInsets.only(right: 15),
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .textTheme
                                            .button
                                            .color)),
                                child: FaIcon(
                                  FontAwesomeIcons.facebook,
                                  size: 35,
                                )),
                          ),
                        ]),
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            widget.updatePage(newPageIndex: 2, newPrevious: 1);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "${S.of(context).signUp}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: workInProgress,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              S.of(context).textDontHaveAccount,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  workInProgress() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Work in progress'),
            content: Text('Hope you like my work'),
          );
        });
  }

  //the method called when the result is success
  _successToast(String msg) {
    fToast.showToast(
      child: ToastTile(
        msg: msg,
        success: true,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }

  //the method called when the result is an exception
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

  //function toggles _obscureText value
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
