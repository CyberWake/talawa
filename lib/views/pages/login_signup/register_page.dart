import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import "package:http/http.dart";
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
// pages are called here
import 'package:provider/provider.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/model/token.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/view_models/vm_register.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:talawa/views/widgets/toast_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function updatePage;
  final int currentPageIndex;
  final int previousPageIndex;
  RegisterPage(
      {this.updatePage, this.currentPageIndex, this.previousPageIndex});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _originalPasswordController =
      new TextEditingController();
  FocusNode confirmPassField = FocusNode();
  RegisterViewModel model = new RegisterViewModel();
  bool _progressBarState = false;
  Queries _signupQuery = Queries();
  var _validate = AutovalidateMode.disabled;
  Preferences _pref = Preferences();
  FToast fToast;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  File _image;
  bool _obscureText = true;

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  //function for registering user which gets called when sign up is press
  registerUser() async {
    var byteData = _image.readAsBytesSync();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    var img = MultipartFile.fromBytes(
      'image',
      byteData,
      filename: '${DateTime.now().second}/${_image.path}.jpg',
      contentType: MediaType("image", "jpg"),
    );
    QueryResult result = await _client.mutate(MutationOptions(
      document: gql(_signupQuery.registerUser(
          model.firstName, model.lastName, model.email, model.password)),
      variables: {
        'file': img,
      },
    ));
    if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      print('here: ${result.exception.linkException.originalException}hello');
      if(result.exception.graphqlErrors.length>0){
        _exceptionToast('${result.exception.graphqlErrors[0].message}');
      }else if(result.exception.linkException.originalException.toString() == '' && result.exception.graphqlErrors.length == 0){
        _exceptionToast('Image upload not working');
      }
    } else if (!result.hasException && !result.isLoading) {
      setState(() {
        _progressBarState = true;
      });

      final String userFName = result.data['signUp']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['signUp']['user']['lastName'];
      await _pref.saveUserLName(userLName);

      final Token accessToken =
          new Token(tokenString: result.data['signUp']['accessToken']);
      await _pref.saveToken(accessToken);
      final Token refreshToken =
          new Token(tokenString: result.data['signUp']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['signUp']['user']['_id'];
      await _pref.saveUserId(currentUserId);
      Navigator.pop(context);
      //Navigate user to join organization screen
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => ShowCaseWidget(
                  autoPlayDelay: Duration(seconds: 2),
                  autoPlay: true,
                  builder: Builder(
                    builder: (BuildContext context) {
                      return JoinOrganization(
                        fromProfile: false,
                      );
                    },
                  ))),
          (route) => false);
    }
  }

  //function called when the user is called without the image
  registerUserWithoutImg() async {
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(MutationOptions(
      document: gql(_signupQuery.registerUserWithoutImg(
          model.firstName, model.lastName, model.email, model.password)),
    ));
    if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      print('here: ${result.exception.graphqlErrors[0].message}');
      if(result.exception.graphqlErrors.length>0){
        _exceptionToast('${result.exception.graphqlErrors[0].message}');
      }else if(result.exception.linkException.originalException!=null){
        _exceptionToast('Organization URL not valid');
      }
      //_exceptionToast(result.exception.toString().substring(16, 35));
    } else if (!result.hasException && !result.isLoading) {
      setState(() {
        _progressBarState = true;
      });

      final String userFName = result.data['signUp']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['signUp']['user']['lastName'];
      await _pref.saveUserLName(userLName);
      final Token accessToken =
          new Token(tokenString: result.data['signUp']['accessToken']);
      await _pref.saveToken(accessToken);
      final Token refreshToken =
          new Token(tokenString: result.data['signUp']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['signUp']['user']['_id'];
      await _pref.saveUserId(currentUserId);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => ShowCaseWidget(
                  autoPlayDelay: Duration(seconds: 2),
                  builder: Builder(
                      builder: (context) => JoinOrganization(
                            fromProfile: false,
                          )),
                  autoPlay: true //userID == null,
                  )),
          (route) => false);
    }
  }

  //get image using camera
  _imgFromCamera() async {
    final pickImage = await ImagePicker.pickImage(source: ImageSource.camera);
    File image = File(pickImage.path);
    setState(() {
      _image = image;
    });
  }

  //get image using gallery
  _imgFromGallery() async {
    final pickImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    File image = File(pickImage.path);
    setState(() {
      _image = image;
    });
  }

  Widget registerForm() {
    return Form(
        key: _formKey,
        autovalidateMode: _validate,
        child: Column(
          children: <Widget>[
            AutofillGroup(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autofillHints: <String>[AutofillHints.givenName],
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    controller: _firstNameController,
                    validator: (value) => Validator.validateFirstName(value),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      labelText: S.of(context).labelFirstName,
                      labelStyle: TextStyle(),
                      alignLabelWithHint: true,
                      hintText: S.of(context).hintFirstName,
                      hintStyle: TextStyle(),
                    ),
                    onSaved: (value) {
                      model.firstName = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autofillHints: <String>[AutofillHints.familyName],
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    controller: _lastNameController,
                    validator: Validator.validateLastName,
                    textAlign: TextAlign.left,
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
                        Icons.person,
                      ),
                      labelText: S.of(context).labelLastName,
                      labelStyle: TextStyle(),
                      alignLabelWithHint: true,
                      hintText: S.of(context).hintLastName,
                      hintStyle: TextStyle(),
                    ),
                    onSaved: (value) {
                      model.lastName = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autofillHints: <String>[AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validator.validateEmail,
                    controller: _emailController,
                    textAlign: TextAlign.left,
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
                      hintStyle: TextStyle(),
                    ),
                    onSaved: (value) {
                      model.email = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autofillHints: <String>[AutofillHints.password],
                    textInputAction: TextInputAction.next,
                    obscureText: _obscureText,
                    controller: _originalPasswordController,
                    validator: Validator.validatePassword,
                    textAlign: TextAlign.left,
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
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      labelText: S.of(context).labelPassword,
                      labelStyle: TextStyle(),
                      focusColor: UIData.primaryColor,
                      alignLabelWithHint: true,
                      hintText: S.of(context).hintPassword,
                      hintStyle: TextStyle(),
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      FocusScope.of(context).requestFocus(confirmPassField);
                    },
                    onChanged: (_) {
                      setState(() {});
                    },
                    onSaved: (value) {
                      model.password = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autofillHints: <String>[AutofillHints.password],
                    obscureText: true,
                    focusNode: confirmPassField,
                    validator: (value) => Validator.validatePasswordConfirm(
                      _originalPasswordController.text,
                      value,
                    ),
                    textAlign: TextAlign.left,
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
                      labelText: S.of(context).labelConfirmPassword,
                      hintText: S.of(context).hintConfirmPassword,
                      labelStyle: TextStyle(),
                      focusColor: UIData.primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      child: Text(
                        S.of(context).signUp,
                        style: TextStyle(fontSize: 24),
                      ),
                      onTap: signUp),
                  FloatingActionButton(
                    onPressed: signUp,
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

  signUp() async {
    FocusScope.of(context).unfocus();
    _validate = AutovalidateMode.always;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _image != null ? registerUser() : registerUserWithoutImg();
      setState(() {
        toggleProgressBarState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GraphQLConfiguration>(context, listen: false).getOrgUrl();
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).padding.top,MediaQuery.of(context).padding.top,MediaQuery.of(context).padding.top,MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            constraints: BoxConstraints(
                maxWidth: 300.0, minWidth: 250.0, minHeight: 350.0),
            child: Column(
              children: <Widget>[
                addImage(),
                SizedBox(
                  height: 35,
                ),
                registerForm(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 15, top: 15),
                      child: GestureDetector(
                        onTap: () {
                          widget.updatePage(newPageIndex: 3, newPrevious: 1);
                        },
                        child: Text(
                          S.of(context).signIn,
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
                SizedBox(
                  height:30
                )
              ],
            )),
      ),
    );
  }

  //widget used to add the image
  Widget addImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
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
                  widget.updatePage(newPageIndex: 1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(S.of(context).signUp,
                  style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 35,
                backgroundColor: UIData.secondaryColor,
                child: _image != null
                    ? CircleAvatar(
                        radius: 52,
                        backgroundImage: FileImage(
                          _image,
                        ),
                      )
                    : CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.lightBlue[50],
                        child: Icon(
                          Icons.camera_alt,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: SizedBox(
                width: 80,
                child: Text(
                  S.of(context).labelAddProfileImage,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  //used to show the method user want to choose their pictures
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera_alt_outlined),
                    title: Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  _image != null
                      ? ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Remove Image'),
                          onTap: () {
                            setState(() {
                              _image = null;
                            });
                            Navigator.of(context).pop();
                          })
                      : SizedBox()
                ],
              ),
            ),
          );
        });
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

  //this method is called when the result is an exception
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
