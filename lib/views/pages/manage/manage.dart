import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:talawa/commons/collapsing_list_tile_widget.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/apiFuctions.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:talawa/views/widgets/chat_bubble.dart';
import 'package:talawa/views/widgets/custom_appbar.dart';

class Manage extends StatefulWidget {
  Manage({Key key}) : super(key: key);

  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> with SingleTickerProviderStateMixin {
  final ScrollController _controllerVertical = ScrollController();
  final ScrollController _controllerHorizontal = ScrollController();
  final ScrollController _controllerChat = ScrollController();
  AnimationController _animationController;
  final TextEditingController _textController = TextEditingController();
  Queries _query = Queries();
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  Preferences _pref = Preferences();
  List userOrg = [];
  List adminsList = [];
  List membersList = [];
  List messages = [];
  Map creator;
  int isSelected = -1;
  String orgId;
  Map selectedMap;
  double maxWidth = 210;
  double minWidth = 70;
  bool isCollapsed = true;
  Animation<double> widthAnimation;
  int currentSelectedIndex = 0;
  bool _progressBarState = false;
  bool chatPageOpen = false;
  bool loading = true;

  @override
  void initState() {
    fetchUserDetails();
    getMembers();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    widthAnimation = Tween<double>(begin: minWidth, end: maxWidth)
        .animate(_animationController);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    orgId = Provider.of<Preferences>(context, listen: true).orgId;
    getMembers();
    super.didChangeDependencies();
  }

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  Future fetchUserDetails() async {
    final String userID = await _pref.getUserId();
    userOrg = [];
    GraphQLClient _client = graphQLConfiguration.clientToQuery();

    QueryResult result = await _client.query(QueryOptions(
        documentNode: gql(_query.fetchUserInfo), variables: {'id': userID}));
    if (result.loading) {
      setState(() {
        _progressBarState = true;
      });
    } else if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
        showError(result.exception.toString());
      });
    } else if (!result.hasException && !result.loading) {
      setState(() {
        print('\n\n\n');
        _progressBarState = false;
        userOrg = result.data['users'][0]['joinedOrganizations'];
        isSelected = 0;
        if (userOrg.isEmpty) {
          showError("You are not registered to any organization");
        }else{
          getMembers();
        }
      });
    }
  }

  Future switchOrg(String selectedOrgId, int selected) async {
    if (selectedOrgId.compareTo(orgId) == 0) {
      print('${userOrg[0]['_id']} | $orgId ');
    } else {
      GraphQLClient _client = graphQLConfiguration.clientToQuery();
      QueryResult result = await _client.mutate(
          MutationOptions(documentNode: gql(_query.fetchOrgById(selectedOrgId))));
      if (result.hasException) {
        print(result.exception);
        //_exceptionToast(result.exception.toString());
      } else if (!result.hasException) {
        print('here1');
        //save new current org in preference
/*        for(int i=0;i<userOrg.length;i++){
          if(userOrg[i]['_id']==selectedOrgId){
            userOrg.removeAt(i);
            break;
          }
        }
        print(userOrg);
        userOrg.insert(0, result.data['organizations'][0]);*/
        setState(() {
          orgId = result.data['organizations'][0]['_id'];
          isSelected = selected;
        });
        final String currentOrgId = result.data['organizations'][0]['_id'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgId(currentOrgId);
        final String currentOrgName = result.data['organizations'][0]['name'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgName(currentOrgName);
        final String currentOrgImgSrc =
            result.data['organizations'][0]['image'];
        await _pref.saveCurrentOrgImgSrc(currentOrgImgSrc);
      }
    }
  }

  Future<List> getMembers() async {
    if (orgId != null) {
      ApiFunctions apiFunctions = ApiFunctions();
      var result = await apiFunctions.gqlquery(Queries().fetchOrgById(orgId));
      if (result != null) {
        creator = result['organizations'][0]['creator'];
        adminsList = result['organizations'][0]['admins'];
        membersList = result['organizations'][0]['members'];
        for (int i = 0; i < adminsList.length; i++) {
          for (int j = 0; j < membersList.length; j++) {
            if (membersList[j]['_id'].compareTo(adminsList[i]['_id']) == 0) {
              membersList.removeAt(j);
            }
          }
          if (adminsList[i]['_id'].compareTo(creator['_id']) == 0) {
            adminsList.removeAt(i);
          }
        }
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        membersList = [];
        loading = false;
      });
    }
  }

  scrollListChat() {
    _controllerHorizontal.animateTo(
      chatPageOpen ? 0.0 : _controllerHorizontal.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    setState(() {
      chatPageOpen = !chatPageOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.5),
      extendBodyBehindAppBar: true,
      //appBar: CustomAppBar('NewsFeed', key: Key('MANAGE_APP_BAR')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, widget) => Stack(
            children: [
              ListView(
                physics: NeverScrollableScrollPhysics(),
                controller: _controllerHorizontal,
                scrollDirection: Axis.horizontal,
                children: [
                  Material(
                    elevation: 80.0,
                    child: Container(
                      width: widthAnimation.value,
                      color: UIData.primaryColor,
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) {
                                return Divider(height: 12.0);
                              },
                              itemBuilder: (context, index) {
                                return CollapsingListTile(
                                  onTap: () {
                                    switchOrg(
                                        userOrg[index]['_id'].toString(),
                                        index);
                                  },
                                  isSelected: index== isSelected,
                                  title: userOrg[index]['name'],
                                  image: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: userOrg[index]['image'] == null
                                          ? Image.asset(
                                              "assets/images/team.png",
                                              fit: BoxFit.fill,
                                            )
                                          : Image.network(
                                              Provider.of<GraphQLConfiguration>(
                                                          context)
                                                      .displayImgRoute +
                                                  userOrg[index]['image'],
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                  animationController: _animationController,
                                );
                              },
                              itemCount: userOrg.length,
                            ),
                          ),
                          CollapsingListTile(
                            onTap: () {
                              Navigator.pop(context);
                              pushNewScreen(context,
                                  screen: JoinOrganization(
                                    fromProfile: true,
                                  ),
                                  withNavBar: false);
                            },
                            title: 'Join/Create\nOrganization',
                            image: SizedBox(
                              width: 35,
                              child: Icon(
                                Icons.add,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            animationController: _animationController,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isCollapsed = !isCollapsed;
                                isCollapsed
                                    ? _animationController.forward()
                                    : _animationController.reverse();
                              });
                            },
                            child: AnimatedIcon(
                              icon: AnimatedIcons.list_view,
                              progress: _animationController,
                              color: Colors.white,
                              size: 50.0,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.6)),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: loading
                          ? Center(child: CircularProgressIndicator())
                          : Scrollbar(
                              controller: _controllerVertical,
                              thickness: 5.0,
                              radius: Radius.circular(10),
                              child: ListView(
                                shrinkWrap: true,
                                controller: _controllerVertical,
                                children: [
                                  subList(
                                      listName: 'Creator',
                                      itemLength: 1,
                                      listNumber: 1),
                                  subList(
                                      listName: 'Admins',
                                      itemLength: adminsList.length,
                                      listNumber: 2),
                                  subList(
                                      listName: 'Members',
                                      itemLength: membersList.length,
                                      listNumber: 3),
                                ],
                              ),
                            )),
                  GestureDetector(
                    onTap: chatPageOpen ? () {} : scrollListChat,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                      width: MediaQuery.of(context).size.width * 0.975,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.8)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: UIData.primaryColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                            ),
                            child: Row(children: [
                              IconButton(
                                  icon: Icon(
                                    chatPageOpen
                                        ? Icons.arrow_back_ios
                                        : Icons.menu,
                                    size: 35,
                                  ),
                                  onPressed: scrollListChat),
                              selectedMap == null
                                  ? CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          AssetImage('assets/images/team.png'))
                                  : selectedMap['image'] == null
                                      ? CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor: Colors.white,
                                          child: Text(
                                              selectedMap['firstName']
                                                      .toString()
                                                      .substring(0, 1)
                                                      .toUpperCase() +
                                                  selectedMap['lastName']
                                                      .toString()
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                color: UIData.primaryColor,
                                              )),
                                        )
                                      : CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                              Provider.of<GraphQLConfiguration>(
                                                          context)
                                                      .displayImgRoute +
                                                  selectedMap['image'])),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Hero(
                                    tag: selectedMap == null
                                        ? 'null'
                                        : selectedMap['_id'],
                                    child: Text(
                                      selectedMap == null
                                          ? ' '
                                          : '${selectedMap['firstName']} ${selectedMap['lastName']}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    )),
                              )
                            ]),
                          ),
                          Flexible(
                              fit: FlexFit.tight,
                              child: ListView.builder(
                                controller: _controllerChat,
                                //reverse: true,
                                itemCount: messages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ChatBubble(
                                    isMe: index % 2 == 0,
                                    message: messages[index],
                                  );
                                },
                              )),
                          Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.only(bottom: 0),
                            color: Colors.white,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.photo),
                                  iconSize: 25,
                                  onPressed: () {},
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Send a message..',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.send),
                                    iconSize: 25,
                                    onPressed: () {
                                      if (_textController.text.length > 0) {
                                        setState(() {
                                          messages.add(_textController.text);
                                        });
                                        _controllerChat.animateTo(
                                            _controllerChat
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 100),
                                            curve: Curves.linear);
                                        _textController.clear();
                                      }
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget subList({int listNumber, String listName, int itemLength}) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleTile('$listName'),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: itemLength,
              itemBuilder: (BuildContext context, int index) {
                if (listNumber == 1) {
                  return memberTile(member: creator);
                } else if (listNumber == 2) {
                  return memberTile(member: adminsList[index]);
                } else {
                  return memberTile(member: membersList[index]);
                }
              }),
        ],
      ),
    );
  }

  Widget titleTile(String title) {
    return Center(
        child: Text('$title',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)));
  }

  Widget memberTile({Map member}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMap = member;
          messages = [];
        });
        scrollListChat();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: Hero(
          tag: '${member['_id']}',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${member['firstName']} ${member['lastName']}',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_right)
            ],
          ),
        ),
      ),
    );
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
}
