import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/services/preferences.dart';
import 'package:flutter/material.dart';

class GraphQLConfiguration with ChangeNotifier {
  Preferences _pref = Preferences();
  static String token;
  static String orgURI;

//prefix route for showing images
  String displayImgRoute;

  getToken() async {
    print('in get token');
    final id = await _pref.getToken();
    token = id;
    authLink = AuthLink(getToken: ()async=>'Bearer $token');
    getOrgUrl();
  }

  getOrgUrl() async {
    final url = await _pref.getOrgUrl();
    final imgUrl = await _pref.getOrgImgUrl();
    orgURI = url;
    httpLink = HttpLink("${orgURI}/graphql",);
    displayImgRoute = imgUrl;
    finalAuthLink = authLink.concat(httpLink);
    notifyListeners();
    print('uri  : ${httpLink.uri}');
  }

  static HttpLink httpLink = HttpLink("${orgURI}/graphql",);

  static AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer $token',
  );

  static Link finalAuthLink = authLink.concat(httpLink);

  GraphQLClient clientToQuery() {
    return GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    );
  }

  GraphQLClient authClient() {
    getToken();
    return GraphQLClient(
      cache: GraphQLCache(),
      link: finalAuthLink,
    );
  }
}
