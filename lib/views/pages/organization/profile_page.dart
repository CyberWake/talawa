//flutter packages are  imported here

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';
//pages are imported here
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/controllers/org_controller.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/Settings/settings_page.dart';
import 'package:talawa/views/pages/organization/organization_settings.dart';
import 'package:talawa/views/widgets/about_tile.dart';
import 'package:talawa/views/widgets/alert_dialog_box.dart';
import 'package:talawa/views/pages/organization/update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final bool autoLogin;
  final bool isCreator;
  final List test;
  ProfilePage({this.isCreator, this.test,this.autoLogin});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey _updateProfile = GlobalKey();
  GlobalKey _leaveOrg = GlobalKey();
  GlobalKey _appSettings = GlobalKey();
  GlobalKey _orgSettings = GlobalKey();
  GlobalKey _logout = GlobalKey();
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Queries _query = Queries();
  Preferences _preferences = Preferences();
  AuthController _authController = AuthController();
  List userDetails = [];
  List orgAdmin = [];
  List org = [];
  List admins = [];
  List curOrganization = [];
  bool isCreator;
  bool isPublic;
  String creator;
  String userID;
  String orgName;
  int count=0;
  OrgController _orgController = OrgController();
  String orgId;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

  @override
  void didChangeDependencies() {
    // When parent widget `updateShouldNotify: true`,
    // child widget can obtain new value when setting `listen: true`.
    orgId = Provider.of<Preferences>(context, listen: true).orgId;
    admins = [];
    fetchUserDetails();
    super.didChangeDependencies();
  }

  //providing initial states to the variables
  @override
  void initState() {
    super.initState();
    if (widget.isCreator != null && widget.test != null) {
      userDetails = widget.test;
      isCreator = widget.isCreator;
      org = userDetails[0]['joinedOrganizations'];
    }
    //Provider.of<Preferences>(context, listen: false).getCurrentOrgName();
    fetchUserDetails();
  }

  //used to fetch the users details from the server
  Future fetchUserDetails() async {
    orgName = await _preferences.getCurrentOrgName();
    orgId = await _preferences.getCurrentOrgId();
    userID = await _preferences.getUserId();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(QueryOptions(
        document: gql(_query.fetchUserInfo), variables: {'id': userID}));
    if (result.hasException) {
      print(result.exception);
    } else if (!result.hasException) {
        userDetails = result.data['users'];
        org = userDetails[0]['joinedOrganizations'];
      //print(userDetails);
      int notFound = 0;
      for (int i = 0; i < org.length; i++) {
        if (org[i]['_id'] == orgId) {
          break;
        } else {
          notFound++;
        }
      }
      if (notFound == org.length && org.length > 0) {
        _orgController.setNewOrg(context, org[0]['_id'], org[0]['name']);
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgName(org[0]['name']);
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgId(org[0]['_id']);
        await _preferences.saveCurrentOrgImgSrc(org[0]['image']);
      }
      fetchOrgAdmin();
    }
  }

  //used to fetch Organization Admin details
  Future fetchOrgAdmin() async {
    orgName = await _preferences.getCurrentOrgName();
    orgId = await _preferences.getCurrentOrgId();
    if (orgId != null) {
      GraphQLClient _client = graphQLConfiguration.authClient();
      QueryResult result = await _client
          .query(QueryOptions(document: gql(_query.fetchOrgById(orgId))));
      if (result.hasException) {
        print(result.exception.toString());
      } else if (!result.hasException) {
        curOrganization = result.data['organizations'];
        creator = result.data['organizations'][0]['creator']['_id'];
        isPublic = result.data['organizations'][0]['isPublic'];
        result.data['organizations'][0]['admins']
            .forEach((userId) => admins.add(userId));
        for (int i = 0; i < admins.length; i++) {
          if (admins[i]['_id'] == userID) {
            isCreator = true;
            break;
          } else {
            isCreator = false;
          }
        }
      }
    } else {
      isCreator = false;
    }
    setState(() {});
  }

  //function used when someone wants to leave organization
  Future leaveOrg() async {
    List remaindingOrg = [];
    String newOrgId;
    String newOrgName;
    final String orgId = await _preferences.getCurrentOrgId();

    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .mutate(MutationOptions(document: gql(_query.leaveOrg(orgId))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      print('loop');
      return leaveOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      print('exception: ${result.exception.toString()}');
      //_exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.isLoading) {
      //set org at the top of the list as the new current org
      print('done');
      setState(() {
        remaindingOrg = result.data['leaveOrganization']['joinedOrganizations'];
        if (remaindingOrg.isEmpty) {
          newOrgId = null;
        } else if (remaindingOrg.isNotEmpty) {
          setState(() {
            newOrgId = result.data['leaveOrganization']['joinedOrganizations']
                [0]['_id'];
            newOrgName = result.data['leaveOrganization']['joinedOrganizations']
                [0]['name'];
          });
        }
      });

      _orgController.setNewOrg(context, newOrgId, newOrgName);
      Provider.of<Preferences>(context, listen: false)
          .saveCurrentOrgName(newOrgName);
      Provider.of<Preferences>(context, listen: false)
          .saveCurrentOrgId(newOrgId);
    }
  }

  //main build starts from here
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userDetails.isNotEmpty && isCreator != null && !widget.autoLogin && count<3){
        print('here');
        if (!isCreator) {
          ShowCaseWidget.of(context).startShowCase([_updateProfile,_leaveOrg,_appSettings,_logout,]);
        }else{
          ShowCaseWidget.of(context).startShowCase([_updateProfile,_orgSettings,_appSettings,_logout,]);
        }
        count++;
      }
    });
    return Scaffold(
        key: Key('PROFILE_PAGE_SCAFFOLD'),
        backgroundColor: Theme.of(context).backgroundColor,
        body: userDetails.isEmpty || isCreator == null
            ? Center(
                child: CircularProgressIndicator(
                key: Key('loading'),
              ))
            : Column(
                key: Key('body'),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                            title: Tooltip(
                              message: 'Profile Page',
                              child: Text(S.of(context).titleProfile,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.white)),
                            ),
                            trailing: Tooltip(
                              message:'Profile Picture',
                              child: userDetails[0]['image'] != null
                                  ? CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          Provider.of<GraphQLConfiguration>(
                                                      context)
                                                  .displayImgRoute +
                                              userDetails[0]['image']))
                                  : CircleAvatar(
                                      radius: 45.0,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                          userDetails[0]['firstName']
                                                  .toString()
                                                  .substring(0, 1)
                                                  .toUpperCase() +
                                              userDetails[0]['lastName']
                                                  .toString()
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                          style: TextStyle(
                                            color: UIData.primaryColor,
                                          )),
                                    ),
                            )),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Tooltip(
                            message: 'Logged in as ${userDetails[0]['firstName'].toString()} ${userDetails[0]['lastName'].toString()}',
                            child: Text(
                                userDetails[0]['firstName'].toString() +
                                    " " +
                                    userDetails[0]['lastName'].toString(),
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Tooltip(
                            message: orgName==null?'No Organization joined':'Current organization is $orgName',
                            child: Text(
                                "${S.of(context).textCurrentOrganization} " +
                                    (orgName ?? 'No Organization Joined'),
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Expanded(
                    child: ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          Showcase(
                            description: 'Update your profile from here',
                            key: _updateProfile,
                            child: Tooltip(
                              message: 'Update Profile',
                              child: ListTile(
                                tileColor: Theme.of(context).backgroundColor,
                                key: Key('Update Profile'),
                                title: Text(
                                  S.of(context).updateProfile,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                leading: Icon(
                                  Icons.edit,
                                  color:Theme.of(context).primaryColor
                                ),
                                onTap: () {
                                  pushNewScreen(
                                    context,
                                    screen: UpdateProfilePage(
                                      userDetails: userDetails,
                                    ),
                                    withNavBar: false,
                                  );
                                },
                              ),
                            ),
                          ),
                          isCreator == null
                              ? SizedBox()
                              : isCreator == true
                                  ? OpenContainer(
                                      closedElevation: 0.0,
                                      openElevation: 0.0,
                                      closedBuilder: (BuildContext c,
                                          VoidCallback action) {
                                        return Showcase(
                                          key: _orgSettings,
                                          description: 'Open Organization Settings',
                                          child: Tooltip(
                                            message: 'Open Organization Settings',
                                            child: ListTile(
                                                tileColor: Theme.of(context)
                                                    .backgroundColor,
                                                key: Key('Organization Settings'),
                                                title: Text(
                                                  S.of(context).orgSetting,
                                                  style:
                                                      TextStyle(fontSize: 18.0),
                                                ),
                                                leading: Icon(
                                                  Icons.settings,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                onTap: () => action()),
                                          ),
                                        );
                                      },
                                      openBuilder: (BuildContext c,
                                          VoidCallback action) {
                                        return OrganizationSettings(
                                            creator: creator == userID,
                                            public: isPublic,
                                            organization: curOrganization);
                                      })
                                  : org.length == 0
                                      ? SizedBox()
                                      : Showcase(key: _leaveOrg,description: 'Leave Current Organization',
                                        child: Tooltip(
                                          message: 'Leave Current Organization',
                                          child: ListTile(
                                              key: Key('Leave This Organization'),
                                              tileColor:
                                                  Theme.of(context).backgroundColor,
                                              title: Text(
                                                S.of(context).leaveOrg,
                                                style: TextStyle(fontSize: 18.0),
                                              ),
                                              leading: Icon(
                                                Icons.exit_to_app,
                                                color:
                                                    Theme.of(context).primaryColor,
                                              ),
                                              onTap: () async {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertBox(
                                                          message:
                                                              "Are you sure you want to leave this organization?",
                                                          function: leaveOrg);
                                                    });
                                              }),
                                        ),
                                      ),
                          Showcase(
                            key: _appSettings,
                            description: 'Open Application Setting',
                            child: Tooltip(
                              message: 'Application Settings',
                              child: ListTile(
                                tileColor: Theme.of(context).backgroundColor,
                                leading: Icon(Icons.settings,color: Theme.of(context).primaryColor,),
                                title: Text(
                                  S.of(context).settings,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                onTap: () {
                                  pushNewScreen(context, screen: SettingsPage(),withNavBar: false);
                                },
                              ),
                            ),
                          ),
                          Showcase(
                            key: _logout,
                            description: 'Logout from application',
                            child: Tooltip(
                              message: 'Logout from application',
                              child: ListTile(
                                key: Key('Logout'),
                                tileColor: Theme.of(context).backgroundColor,
                                title: Text(
                                  S.of(context).logout,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                leading: Icon(
                                  Icons.exit_to_app,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertBox(
                                          message: S.of(context).textConfirmLogout,
                                          function: () {
                                            _authController.logout(context);
                                          },
                                        );
                                      });
                                },
                              ),
                            ),
                          ),
                          MyAboutTile(),
                        ],
                      ).toList(),
                    ),
                  )
                ],
              ));
  }
}
