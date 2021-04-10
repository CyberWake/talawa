import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:talawa/commons/collapsing_list_tile_widget.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/apiFunctions.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/members/memberDetails.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:talawa/views/widgets/chat_bubble.dart';

class Manage extends StatefulWidget {
  Manage({Key key}) : super(key: key);

  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> with TickerProviderStateMixin {
  final FocusNode _searchNode = FocusNode();
  final FocusNode _messageNode = FocusNode();
  final TextEditingController _filter = new TextEditingController();
  final ScrollController _controllerVertical = ScrollController();
  final ScrollController _controllerHorizontal = ScrollController();
  final ScrollController _controllerChat = ScrollController();
  AnimationController _drawerAnimationController;
  AnimationController _attachmentAnimationController;
  final TextEditingController _textController = TextEditingController();
  Queries _query = Queries();
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  Preferences _pref = Preferences();
  List userOrg = [];
  List adminsList = [];
  List membersList = [];
  List participantsList = [];
  List searchList = [];
  List messages = [];
  Map creator;
  int isSelected = -1;
  String orgId;
  Map selectedMap;
  double maxWidth = 185;
  double minWidth = 70;
  double maxAttachmentWidth = 200;
  double minAttachmentWidth = 0;
  bool isCollapsed = true;
  Animation<double> drawerWidthAnimation;
  Animation<double> attachmentHeightAnimation;
  int currentSelectedIndex = 0;
  bool _progressBarState = false;
  bool chatPageOpen = false;
  bool loading = true;
  bool isSearchClicked = false;
  bool translateActive = false;
  IconData cancelAttachmentIcon = Icons.attach_file;

  @override
  void initState() {
    fetchUserDetails();
    _drawerAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    drawerWidthAnimation = Tween<double>(begin: minWidth, end: maxWidth)
        .animate(_drawerAnimationController);
    _attachmentAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    attachmentHeightAnimation =
        Tween<double>(begin: minAttachmentWidth, end: maxAttachmentWidth)
            .animate(_attachmentAnimationController);
    super.initState();
  }

  search(String searchText) {
    if (_filter.text.isNotEmpty) {
      searchList = [];
      for (int i = 0; i < participantsList.length; i++) {
        if ('${participantsList[i]['firstName']} ${participantsList[i]['lastName']}'
            .toLowerCase()
            .contains(searchText)) {
          setState(() {
            searchList.add(participantsList[i]);
          });
        }
      }
    } else {
      searchList = [];
    }
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
        document: gql(_query.fetchUserInfo), variables: {'id': userID}));
    if (result.isLoading) {
      setState(() {
        _progressBarState = true;
      });
    } else if (result.hasException) {
      print(result.exception);
      print('error');
      setState(() {
        _progressBarState = false;
        showError(result.exception.toString());
      });
    } else if (!result.hasException && !result.isLoading) {
      setState(() {
        print('\n\n\n');
        _progressBarState = false;
        userOrg = result.data['users'][0]['joinedOrganizations'];
        isSelected = 0;
        print('length: ${userOrg.length}');
        if (userOrg.isEmpty) {
          showError("You are not registered to any organization");
        } else {
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
          MutationOptions(document: gql(_query.fetchOrgById(selectedOrgId))));
      if (result.hasException) {
        print(result.exception);
        //_exceptionToast(result.exception.toString());
      } else if (!result.hasException) {
        print('here1');
        //save new current org in preference
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

  getMembers() async {
    setState(() {
      loading = true;
    });
    if (orgId != null) {
      ApiFunctions apiFunctions = ApiFunctions();
      var result = await apiFunctions.gqlquery(Queries().fetchOrgById(orgId));
      if (result != null) {
        creator = result['organizations'][0]['creator'];
        adminsList = result['organizations'][0]['admins'];
        membersList = result['organizations'][0]['members'];
        participantsList = membersList;
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
      duration: const Duration(milliseconds: 800),
    );
    setState(() {
      chatPageOpen = !chatPageOpen;
    });
  }

  List<IconData> icons = [
    Icons.note,
    Icons.camera_alt,
    Icons.photo,
    Icons.location_on_rounded,
    Icons.contact_page_rounded,
    Icons.headset_mic,
  ];

  List<Map> eventsList = [
    {
      '_id': 'fgfien2rucnyciasd87dgegf',
      'firstName': 'Event',
      'lastName': '1',
      'image': null,
      'unread': '2',
    },
    {
      '_id': 'fgfien2rucnyddskjbcigegf',
      'firstName': 'Event',
      'lastName': '2',
      'image': null,
      'unread': '9+',
    }
  ];

  List<Map> groupLists = [
    {
      '_id': 'fsfla405iugwciau09livt59o',
      'firstName': 'Stage',
      'lastName': 'Management',
      'image': null,
      'unread': '7',
    },
    {
      '_id': 'lkhfhcw349iuwugc9gcqfojfl',
      'firstName': 'Backend',
      'lastName': 'Discussion',
      'image': null,
      'unread': '9+',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      //appBar: CustomAppBar('NewsFeed', key: Key('MANAGE_APP_BAR')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _drawerAnimationController,
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
                      width: drawerWidthAnimation.value,
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView.separated(
                              itemCount: userOrg.length,
                              separatorBuilder: (context, index) {
                                return Divider(height: 12.0);
                              },
                              itemBuilder: (context, index) {
                                return CollapsingListTile(
                                  onTap: () {
                                    switchOrg(userOrg[index]['_id'].toString(),
                                        index);
                                  },
                                  isSelected: index == isSelected,
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
                                  animationController:
                                      _drawerAnimationController,
                                );
                              },
                            ),
                          ),
                          CollapsingListTile(
                            onTap: () {
                              pushNewScreen(context,
                                  screen: JoinOrganization(
                                    fromProfile: true,
                                  ),
                                  withNavBar: false);
                            },
                            title: S.of(context).joinCreateOrg,
                            image: SizedBox(
                              width: 35,
                              child: Icon(
                                Icons.add,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            animationController: _drawerAnimationController,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isCollapsed = !isCollapsed;
                                isCollapsed
                                    ? _drawerAnimationController.forward()
                                    : _drawerAnimationController.reverse();
                              });
                            },
                            child: AnimatedIcon(
                              icon: AnimatedIcons.list_view,
                              progress: _drawerAnimationController,
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
                          color: Colors.grey.withOpacity(0.2)),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width * 0.63,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: TextFormField(
                                      focusNode: _searchNode,
                                      controller: _filter,
                                      autofocus: false,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration.collapsed(
                                        hintText:
                                            S.of(context).hintSearchMember,
                                        hintStyle: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          loading = false;
                                          isSearchClicked = true;
                                        });
                                      },
                                      onChanged: (input) {
                                        print(input);
                                        search(input);
                                      },
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = false;
                                      isSearchClicked = !isSearchClicked;
                                    });
                                    print(isSearchClicked);
                                    if (isSearchClicked) {
                                      _searchNode.requestFocus();
                                    } else {
                                      _filter.clear();
                                      searchList.clear();
                                      _searchNode.unfocus();
                                    }
                                  },
                                  icon: Icon(
                                    isSearchClicked
                                        ? Icons.cancel_outlined
                                        : Icons.search,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Scrollbar(
                              controller: _controllerVertical,
                              thickness: 5.0,
                              radius: Radius.circular(10),
                              child: isSearchClicked
                                  ? ListView(
                                      shrinkWrap: true,
                                      controller: _controllerVertical,
                                      children: List.generate(searchList.length,
                                          (index) {
                                        return memberTile(
                                            member: searchList[index]);
                                      }),
                                    )
                                  : loading
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : ListView(
                                          shrinkWrap: true,
                                          controller: _controllerVertical,
                                          children: [
                                            subList(
                                                listName: S.of(context).creator,
                                                itemLength:
                                                    creator == null ? 0 : 1,
                                                listNumber: 1),
                                            subList(
                                                listName: S.of(context).admins,
                                                itemLength: adminsList.length,
                                                listNumber: 2),
                                            subList(
                                                listName:
                                                    S.of(context).eventChats,
                                                itemLength: eventsList.length,
                                                listNumber: 3),
                                            subList(
                                                listName: S.of(context).groups,
                                                itemLength: groupLists.length,
                                                listNumber: 4),
                                            subList(
                                                listName: S.of(context).members,
                                                itemLength: membersList.length,
                                                listNumber: 5),
                                          ],
                                        ),
                            ),
                          ),
                        ],
                      )),
                  chatPage(),
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
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          maintainState: true,
          title: Text('$listName',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
          children: List.generate(itemLength, (index) {
            if (listNumber == 1) {
              return memberTile(member: creator);
            } else if (listNumber == 2) {
              return memberTile(member: adminsList[index]);
            } else if (listNumber == 3) {
              return memberTile(member: eventsList[index]);
            } else if (listNumber == 4) {
              return memberTile(member: groupLists[index]);
            } else if (listNumber == 5) {
              return memberTile(member: membersList[index]);
            } else {
              return SizedBox();
            }
          }),
        ),
      ),
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Text(
                  '${member['firstName']} ${member['lastName']}',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle1.color,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                member['unread'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            padding: EdgeInsets.all(2),
                            width: 25,
                            alignment: Alignment.center,
                            color: Theme.of(context)
                                .textSelectionTheme
                                .selectionColor,
                            child: Text(
                              '${member['unread']}',
                              style: TextStyle(fontSize: 12),
                            )),
                      )
                    : SizedBox(),
                Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).accentColor,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget chatPage() {
    return GestureDetector(
      onTap: chatPageOpen ? () {} : scrollListChat,
      onHorizontalDragUpdate: chatPageOpen
          ? (DragUpdateDetails details) {
              if (details.delta.direction <= 0.0) {
                scrollListChat();
              }
            }
          : (DragUpdateDetails details) {},
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
        width: MediaQuery.of(context).size.width * 0.975,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.grey.withOpacity(0.2)),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Row(children: [
                    IconButton(
                        icon: Icon(
                          chatPageOpen ? Icons.arrow_back_ios : Icons.menu,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: scrollListChat),
                    selectedMap == null
                        ? CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                Theme.of(context).textTheme.subtitle1.color,
                            backgroundImage: AssetImage('assets/images/team.png'))
                        : selectedMap['image'] == null
                            ? CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).textTheme.subtitle1.color,
                                radius: 25,
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
                                    )))
                            : CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                    Provider.of<GraphQLConfiguration>(context)
                                            .displayImgRoute +
                                        selectedMap['image'])),
                    selectedMap == null
                        ? SizedBox()
                        : InkWell(
                            onTap: () {
                              pushNewScreen(context,
                                  screen: MemberDetail(
                                    member: selectedMap,
                                    color: Colors.blue,
                                    admins: adminsList,
                                    creatorId: creator['_id'],
                                  ),
                                  withNavBar: false);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                '${selectedMap['firstName']} ${selectedMap['lastName']}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        child: Icon(
                          Icons.phone,
                          size: 30,
                          color: Colors.white,
                          semanticLabel: 'Make a voice call',
                        ),
                        onTap: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        child: Icon(
                          Icons.video_call,
                          size: 30,
                          color: Colors.white,
                          semanticLabel: 'Make a video call',
                        ),
                        onTap: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: PopupMenuButton(
                        child: Icon(
                          Icons.more_vert,
                          size: 30,
                          color: Colors.white,
                          semanticLabel: 'More Options',
                        ),
                        itemBuilder: (BuildContext context) {
                          return {'Translate'}.map((String choice) {
                            return PopupMenuItem(
                              child: StatefulBuilder(
                                builder: (BuildContext context, void Function(void Function()) setState) {
                                  return SwitchListTile(
                                    title: Text(choice),
                                    onChanged: (bool value) {
                                      setState(() {
                                        translateActive = !translateActive;
                                      });
                                      _messageNode.unfocus();
                                    },
                                    value: translateActive,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ]),
                ),
                Flexible(
                    fit: FlexFit.tight,
                    child: ListView.builder(
                      controller: _controllerChat,
                      shrinkWrap: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatBubble(
                          translate: translateActive,
                          isMe: index % 2 == 0,
                          message: messages[index],
                        );
                      },
                    )),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.emoji_emotions,
                                semanticLabel: 'Send emoji message',
                                color: Theme.of(context).primaryColor,
                                size: 25,
                              ),
                              onPressed: () {
                                if (!chatPageOpen) {
                                  scrollListChat();
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                focusNode: _messageNode,
                                autofocus: false,
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
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ),
                            InkWell(
                              child: Icon(
                                cancelAttachmentIcon,
                                semanticLabel: 'Attach a document',
                                size: 25,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () {
                                print('running');
                                if (attachmentHeightAnimation.value ==
                                    maxAttachmentWidth) {
                                  setState(() {
                                    cancelAttachmentIcon = Icons.attach_file;
                                  });
                                  _attachmentAnimationController.reverse();
                                } else {
                                  setState(() {
                                    cancelAttachmentIcon = Icons.cancel_outlined;
                                  });
                                  _attachmentAnimationController.forward();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.mic,
                                semanticLabel: 'Record voice message',
                                color: Theme.of(context).primaryColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).backgroundColor,
                      onPressed: () {
                        if (_textController.text.length > 0) {
                          setState(() {
                            messages.add(_textController.text);
                          });
                          Future.delayed(Duration(milliseconds: 2000));
                          _controllerChat.animateTo(
                              _controllerChat.position.maxScrollExtent+200,
                              duration: Duration(milliseconds: 100),
                              curve: Curves.linear);
                          _textController.clear();
                        }
                      },
                      child: Icon(
                        Icons.send,
                        semanticLabel: 'Send Text Message',
                        size: 25,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ],
                ),
                AnimatedBuilder(
                    animation: _attachmentAnimationController,
                    builder: (context, widget) {
                      return Container(
                          height: attachmentHeightAnimation.value,
                          child: GridView.count(
                            crossAxisCount: 3,
                            padding:
                                EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                            crossAxisSpacing: 40,
                            mainAxisSpacing: 20,
                            children: List.generate(
                                6,
                                (index) => SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: FloatingActionButton(
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      onPressed: () {},
                                      child: Icon(
                                        icons[index],
                                        size: 30,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ))),
                          ));
                    })
              ],
            ),
          ],
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
