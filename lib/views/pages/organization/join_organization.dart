//flutter packages are imported here
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Pages are imported here
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/home_page.dart';
import 'package:talawa/views/widgets/alert_dialog_box.dart';
import 'package:talawa/views/widgets/toast_tile.dart';
import 'package:talawa/views/widgets/loading.dart';

import 'create_organization.dart';
import 'package:showcaseview/showcaseview.dart';

class JoinOrganization extends StatefulWidget {
  JoinOrganization({Key key, this.msg, this.fromProfile = false});
  final bool fromProfile;
  final String msg;
  @override
  _JoinOrganizationState createState() => _JoinOrganizationState();
}

class _JoinOrganizationState extends State<JoinOrganization> {
  GlobalKey _search = GlobalKey();
  GlobalKey _select = GlobalKey();
  bool show = true;
  int count = 0;
  int selectedIndex = -1;
  Queries _query = Queries();
  String token;
  static String itemIndex;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  FToast fToast;
  List organizationInfo = [];
  List filteredOrgInfo = [];
  List joinedOrg = [];
  AuthController _authController = AuthController();
  String isPublic;
  TextEditingController searchController = TextEditingController();
  bool _isLoaderActive = false;
  bool disposed = false;

  @override
  void initState() {
    //creating the initial state for all the variables
    super.initState();
    fToast = FToast();
    fToast.init(context);
    fetchOrg();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  void searchOrgName(String orgName) {
    //it is the search bar to search the organization
    filteredOrgInfo.clear();
    if (orgName.isNotEmpty) {
      for (int i = 0; i < organizationInfo.length; i++) {
        String name = organizationInfo[i]['name'];
        if (name.toLowerCase().contains(orgName.toLowerCase())) {
          setState(() {
            filteredOrgInfo.add(organizationInfo[i]);
          });
        }
      }
    } else {
      setState(() {
        filteredOrgInfo.add(organizationInfo);
      });
    }
  }

  Future fetchOrg() async {
    if (widget.fromProfile) {
      setState(() {
        show = false;
      });
    }
    //function to fetch the org from the server
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .query(QueryOptions(document: gql(_query.fetchOrganizations)));
    if (result.hasException) {
      print(result.exception);
      showError(result.exception.toString());
    } else if (!result.hasException && !disposed) {
      setState(() {
        organizationInfo = result.data['organizations'];
      });
    }
  }

  Future joinPrivateOrg() async {
    //function called if the person wants to enter a private organization
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client.mutate(MutationOptions(
        document: gql(_query.sendMembershipRequest(itemIndex))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return joinPrivateOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.isLoading) {
      print(result.data);
      _successToast("Request Sent to Organization Admin");

      if (widget.fromProfile) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, _) => ShowCaseWidget(
              autoPlayDelay: Duration(seconds: 2),
              autoPlay: true,
              builder: Builder(
                builder: (BuildContext context) {
                  return HomePage(
                    openPageIndex: 3,
                  );
                },
              )),
        ));
      }
    }
  }

  Future joinPublicOrg() async {
    //function which will be called if the person wants to join the organization which is not private
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .mutate(MutationOptions(document: gql(_query.getOrgId(itemIndex))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return joinPublicOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.isLoading) {
      setState(() {
        joinedOrg =
            result.data['joinPublicOrganization']['joinedOrganizations'];
      });

      //set the default organization to the first one in the list
      if (joinedOrg.length == 1) {
        final String currentOrgId = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['_id'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgId(currentOrgId);
        //await _pref.saveCurrentOrgId(currentOrgId);
        final String currentOrgImgSrc = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['image'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgImgSrc(currentOrgImgSrc);
        //await _pref.saveCurrentOrgImgSrc(currentOrgImgSrc);
        final String currentOrgName = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['name'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgName(currentOrgName);
        //await _pref.saveCurrentOrgName(currentOrgName);
      }
      _successToast("Sucess!");

      //Navigate user to newsfeed
      if (widget.fromProfile) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, _) => ShowCaseWidget(
              autoPlayDelay: Duration(seconds: 2),
              autoPlay: true,
              builder: Builder(
                builder: (BuildContext context) {
                  return HomePage(
                    openPageIndex: 3,
                  );
                },
              )),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (organizationInfo.isNotEmpty && !widget.fromProfile && count < 3) {
        ShowCaseWidget.of(context).startShowCase([_search, _select]);
      }
    });
    count++;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(S.of(context).titleJoinOrg,
            style: TextStyle(color: Colors.white)),
      ),
      body: organizationInfo.isEmpty
          ? Center(
              child: Loading(
              key: Key('new'),
                refresh: (){fetchOrg();},
            ))
          : Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    S.of(context).textJoinOrgGreeting,
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.normal),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  !widget.fromProfile
                      ? Showcase(
                          description: 'Search for a organization',
                          key: _search,
                          child: TextFormField(
                            onChanged: (value) {
                              searchOrgName(value);
                            },
                            controller: searchController,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                fillColor: Theme.of(context).backgroundColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 0.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 0.0),
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child:
                                      Icon(Icons.search, color: Colors.black),
                                ),
                                hintText: S.of(context).hintSearchOrg),
                          ),
                        )
                      : TextFormField(
                          onChanged: (value) {
                            searchOrgName(value);
                          },
                          controller: searchController,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              fillColor: Theme.of(context).backgroundColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(Icons.search, color: Colors.black),
                              ),
                              hintText: S.of(context).hintSearchOrg),
                        ),
                  SizedBox(height: 15),
                  Expanded(
                      child: !widget.fromProfile
                          ? Showcase(
                              onTargetClick: () {
                                setState(() {
                                  show = false;
                                });
                              },
                              onToolTipClick: () {
                                setState(() {
                                  show = false;
                                });
                              },
                              disposeOnTap: true,
                              key: _select,
                              description:
                                  'Select an organization from the list',
                              child: getList(searchController.text.isNotEmpty
                                  ? filteredOrgInfo
                                  : organizationInfo),
                            )
                          : getList(searchController.text.isNotEmpty
                              ? filteredOrgInfo
                              : organizationInfo)),
                  SizedBox(
                    height: show ? 80 : 0,
                  )
                ],
              )),
      floatingActionButton: Tooltip(
          message: 'Create new organization',
          child: OpenContainer(
            transitionDuration: Duration(milliseconds: 1000),
            closedElevation: 6.0,
            openColor: Theme.of(context).scaffoldBackgroundColor,
            closedColor: Theme.of(context).scaffoldBackgroundColor,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(28),
              ),
            ),
            closedBuilder: (BuildContext c, VoidCallback action) =>
                FloatingActionButton(
              heroTag: 'joinFab',
              child: Icon(Icons.add),
              backgroundColor: UIData.secondaryColor,
              foregroundColor: Colors.white,
              elevation: 5.0,
              onPressed: () => action(),
            ),
            openBuilder: (BuildContext c, VoidCallback action) =>
                CreateOrganization(
              isFromProfile: widget.fromProfile,
            ),
          )),
    );
  }

  Widget getList(List organizations) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
            itemCount: organizations.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final organization = organizations[index];
              return generateTile(organization,index);
            }));
  }

  Widget generateTile(Map organization,int index) {
    return Card(
      child: ListTile(
        leading: organization['image'] != null
            ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    Provider.of<GraphQLConfiguration>(context).displayImgRoute +
                        organization['image']))
            : CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/images/team.png")),
        title: organization['isPublic'].toString() != 'false'
            ? Row(
                children: [
                  Flexible(
                    child: Text(
                      organization['name'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.lock_open, color: Colors.green, size: 16)
                ],
              )
            : Row(
                children: [
                  Flexible(
                    child: Text(
                      organization['name'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.lock, color: Colors.red, size: 16)
                ],
              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(organization['description'].toString(),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(
                'Created by: ' +
                    organization['creator']['firstName'].toString() +
                    ' ' +
                    organization['creator']['lastName'].toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )),
          ),
          onPressed: () {
            itemIndex = organization['_id'].toString();
            if (organization['isPublic'].toString() == 'false') {
                isPublic = 'false';
                selectedIndex = index;
            } else {
                isPublic = 'true';
                selectedIndex = index;
            }
            setState(() {});
            confirmOrgDialog();
          },
          child: _isLoaderActive && (selectedIndex == index)
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                )
              : new Text(S.of(context).join),
        ),
        isThreeLine: true,
      ),
    );
  }

  void confirmOrgDialog() {
    //this is the pop up shown when the confirmation is required
    showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(
          transitionDuration: Duration(milliseconds: 800),
          reverseTransitionDuration: Duration(milliseconds: 500),
        ),
        builder: (BuildContext context) => AlertBox(
              message: S.of(context).textConfirmJoinOrg,
              function: () async {
                setState(() {
                  _isLoaderActive = true;
                });
                if (isPublic == 'true') {
                  await joinPublicOrg().whenComplete(() => setState(() {
                        _isLoaderActive = false;
                      }));
                } else if (isPublic == 'false') {
                  await joinPrivateOrg().whenComplete(() => setState(() {
                        _isLoaderActive = false;
                      }));
                }
              },
            ));
  }

  Widget showError(String msg) {
    return Center(
      child: Text(
        msg,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

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

  _exceptionToast(String msg) {
    fToast.showToast(
      child: ToastTile(
        msg: msg,
        success: false,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }
}
