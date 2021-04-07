//flutter packages are imported here
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
//pages are imported here
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:talawa/commons/collapsing_list_tile_widget.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/apiFuctions.dart';
import 'package:talawa/utils/timer.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/newsfeed/addPost.dart';
import 'package:talawa/views/pages/newsfeed/newsArticle.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:talawa/views/widgets/custom_appbar.dart';
import 'package:talawa/views/widgets/loading.dart';

class NewsFeed extends StatefulWidget {
  NewsFeed({Key key}) : super(key: key);

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Queries _query = Queries();
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  ScrollController scrollController = new ScrollController();
  bool isVisible = true;
  Preferences preferences = Preferences();
  ApiFunctions apiFunctions = ApiFunctions();
  List postList = [];
  List userOrg = [];
  Timer timer = Timer();
  int isSelected = -1;
  String orgId;
  String _currentOrgID;
  Preferences _pref = Preferences();
  bool _progressBarState = false;
  double maxWidth = 210;
  double minWidth = 70;
  bool isCollapsed = true;
  Animation<double> widthAnimation;
  int currentSelectedIndex = 0;

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  @override
  void didChangeDependencies() {
    orgId = Provider.of<Preferences>(context, listen: true).orgId;
    fetchUserDetails();
    super.didChangeDependencies();
  }

  Map<String, bool> likePostMap = new Map<String, bool>();
  // key = postId and value will be true if user has liked a post.

  //setting initial state to the variables
  initState() {
    fetchUserDetails();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: minWidth, end: maxWidth)
        .animate(_animationController);
    super.initState();
    getPosts();
    Provider.of<Preferences>(context, listen: false).getCurrentOrgId();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isVisible)
          setState(() {
            isVisible = false;
          });
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isVisible)
          setState(() {
            isVisible = true;
          });
      }
    });
  }

  Future fetchUserDetails() async {
    final String userID = await _pref.getUserId();

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
        _progressBarState = false;
        userOrg = result.data['users'][0]['joinedOrganizations'];
        isSelected = 0;
        orgId = userOrg[0]['_id'];
        print(userOrg);
        if (userOrg.isEmpty) {
          showError("You are not registered to any organization");
        }
      });
    }
  }

  // bool : Method to get (true/false) if a user has liked a post or Not.
  bool hasUserLiked(String postId) {
    return likePostMap[postId];
  }

  //function to get the current posts
  Future<void> getPosts() async {
    final String currentOrgID = await preferences.getCurrentOrgId();
    final String currentUserID = await preferences.getUserId();
    _currentOrgID = currentUserID;
    String query = Queries().getPostsById(currentOrgID);
    Map result = await apiFunctions.gqlquery(query);
    // print(result);
    setState(() {
      postList =
          result == null ? [] : result['postsByOrganization'].reversed.toList();
      updateLikepostMap(currentUserID);
    });
  }

// void : function to set the map of userLikedPost
  void updateLikepostMap(String currentUserID) {
    // traverse through post objects.
    for (var item in postList) {
      likePostMap[item['_id']] = false;
      //Get userIds who liked the post.
      var _likedBy = item['likedBy'];
      for (var user in _likedBy) {
        if (user['_id'] == currentUserID) {
          //if(userId is in the list we make value true;)
          likePostMap[item['_id']] = true;
        }
      }
    }
  }

  //function to addlike
  Future<void> addLike(String postID) async {
    String mutation = Queries().addLike(postID);
    Map result = await apiFunctions.gqlmutation(mutation);
    print(result);
    getPosts();
  }

  //function to remove the likes
  Future<void> removeLike(String postID) async {
    String mutation = Queries().removeLike(postID);
    Map result = await apiFunctions.gqlmutation(mutation);
    print(result);
    getPosts();
  }

  Future switchOrg(String index, int selected) async {
    if (index.compareTo(orgId) == 0) {
      print('${userOrg[0]['_id']} | $orgId ');
      Navigator.pop(context);
    } else {
      GraphQLClient _client = graphQLConfiguration.clientToQuery();
      QueryResult result = await _client.mutate(
          MutationOptions(documentNode: gql(_query.fetchOrgById(index))));
      if (result.hasException) {
        print(result.exception);
        //_exceptionToast(result.exception.toString());
      } else if (!result.hasException) {
        print('here');
        /*_successToast("Switched to " +
            result.data['organizations'][0]['name'].toString());
        */
        setState(() {
          isSelected = selected;
        });
        //save new current org in preference
        final String currentOrgId = result.data['organizations'][0]['_id'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgId(currentOrgId);
        final String currentOrgName = result.data['organizations'][0]['name'];
        Provider.of<Preferences>(context, listen: false)
            .saveCurrentOrgName(currentOrgName);
        final String currentOrgImgSrc =
            result.data['organizations'][0]['image'];
        await _pref.saveCurrentOrgImgSrc(currentOrgImgSrc);
        Navigator.pop(context);
      }
    }
  }

  //the main build starts from here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(S.of(context).titleNewsFeeds, key: Key('NEWSFEED_APP_BAR')),
        floatingActionButton: addPostFab(),
        drawer: drawer(),
        body: postList.isEmpty
            ? Center(
                child: Loading(
                key: UniqueKey(),
              ))
            : RefreshIndicator(
                onRefresh: () async {
                  getPosts();
                },
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: postList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(top: 20),
                                child: Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        pushNewScreen(
                                          context,
                                          screen: NewsArticle(
                                              post: postList[index]),
                                        );
                                      },
                                      child: Card(
                                        color: Colors.white,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.all(5.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  child: Image.asset(
                                                      UIData.shoppingImage),
                                                )),
                                            Row(children: <Widget>[
                                              SizedBox(
                                                width: 30,
                                              ),
                                              Container(
                                                  child: Text(
                                                postList[index]['title']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              )),
                                            ]),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(children: <Widget>[
                                              SizedBox(
                                                width: 30,
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      50,
                                                  child: Text(
                                                    postList[index]["text"]
                                                        .toString(),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 10,
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                  )),
                                            ]),
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: <Widget>[
                                                      likeButton(index),
                                                      commentCounter(index),
                                                      Container(width: 80)
                                                    ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )));
  }

  //function to add the post on the news feed
  Widget addPostFab() {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 1000),
      closedElevation: 6.0,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(28),
        ),
      ),
      closedBuilder: (BuildContext c, VoidCallback action) =>
          FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: UIData.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 5.0,
        onPressed: () => action(),
      ),
      openBuilder: (BuildContext c, VoidCallback action) => AddPost(),
    );
  }

  //function which counts the number of comments on a particular post
  Widget commentCounter(index) {
    return Row(
      children: [
        Text(
          postList[index]['commentCount'].toString(),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        IconButton(
            icon: Icon(Icons.comment),
            color: Colors.grey,
            onPressed: () async {
              pushNewScreenWithRouteSettings(context,
                      screen: NewsArticle(
                        post: postList[index],
                      ),
                      settings: RouteSettings(),
                      withNavBar: false)
                  .then((value) {
                if (value != null && value) {
                  getPosts();
                }
              });
            })
      ],
    );
  }

  //function to like
  Widget likeButton(index) {
    return Row(children: [
      Text(
        postList[index]['likeCount'].toString(),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
      IconButton(
          icon: Icon(Icons.thumb_up),
          color: likePostMap[postList[index]['_id']]
              ? Color(0xff007397)
              : Color(0xff9A9A9A),
          onPressed: () {
            if (postList[index]['likeCount'] !=
                0) if (likePostMap[postList[index]['_id']] == false) {
              //If user has not liked the post addLike().
              addLike(postList[index]['_id']);
            } else {
              //If user has  liked the post remove().
              removeLike(postList[index]['_id']);
            }
            else {
              //if the likeCount is 0 addLike().
              addLike(postList[index]['_id']);
            }
          })
    ]);
  }

  Widget drawer() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, widget) => Stack(
          children: [
            isCollapsed
                ? Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                  )
                : SizedBox(),
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
                        separatorBuilder: (context, counter) {
                          return Divider(height: 12.0);
                        },
                        itemBuilder: (context, counter) {
                          return CollapsingListTile(
                            onTap: () {
                              switchOrg(
                                  userOrg[counter]['_id'].toString(), counter);
                            },
                            isSelected: isSelected == counter,
                            title: userOrg[counter]['name'],
                            image: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: userOrg[counter]['image'] == null
                                    ? Image.asset(
                                        "assets/images/team.png",
                                        fit: BoxFit.fill,
                                      )
                                    : Image.network(
                                        Provider.of<GraphQLConfiguration>(
                                                    context)
                                                .displayImgRoute +
                                            userOrg[counter]['image'],
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
                      title: S.of(context).joinCreateOrg,
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
                      height: 50.0,
                    ),
                  ],
                ),
              ),
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
