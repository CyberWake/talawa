//flutter package imported here
import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';

//imported the pages here
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';

//We are currently adding the app bar here

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  final String title;

  @override
  final Size preferredSize;

  CustomAppBar(
    this.title, {
    Key key,
  })  : preferredSize = Size.fromHeight(55.0),
        super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  Queries _query = Queries();
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  Preferences preferences = Preferences();
  String _imgSrc;
  String _orgId;
  String _orgName;

  @override
  void initState() {
    super.initState();
    getImg();
  }

  @override
  void didChangeDependencies() {
    // When parent widget `updateShouldNotify: true`,
    // child widget can obtain new value when setting `listen: true`.
    _orgId = Provider.of<Preferences>(context, listen: true).orgId;
    getImg();
    super.didChangeDependencies();
  }

  Future getImg() async { //this function gets the image from the graphql query
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    String orgId = await preferences.getCurrentOrgId();

    QueryResult result = await _client
        .query(QueryOptions(documentNode: gql(_query.fetchOrgById(orgId))));
    if (result.hasException) {
      print(result.exception);
    } else if (!result.hasException) {
      // print(result.data);
      setState(() {
        _imgSrc = result.data['organizations'][0]['image'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GestureDetector(
        onTap: (){
          Scaffold.of(context).openDrawer();
        },
        child: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      leading: GestureDetector(
        onTap: (){
          Scaffold.of(context).openDrawer();
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Arc(
                arcType: ArcType.CONVEX,
                edge: Edge.RIGHT,
                height: 14.0,
                clipShadows: [ClipShadow(color: Colors.white)],
                child: new Container(
                  height: 28,
                  width: 6,
                  color: Colors.white,
                ),
              ),),
            Align(
              alignment: Alignment.centerRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: _imgSrc == null
                      ? Image.asset(
                    "assets/images/team.png",
                    fit: BoxFit.fill,
                  )
                      : Image.network(
                    Provider.of<GraphQLConfiguration>(
                        context)
                        .displayImgRoute +
                        _imgSrc,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            /*_imgSrc != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(15.0,5,5,5),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          Provider.of<GraphQLConfiguration>(context).displayImgRoute +
                              _imgSrc),
                    ))
                : Padding(
                    padding: const EdgeInsets.fromLTRB(15.0,5,5,5),
                    child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/images/team.png")),
                  ),*/
          ],
        ),
      ),
    );
  }
}
