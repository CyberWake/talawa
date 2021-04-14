
//flutter packages to be called here
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//pages are called here
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/model/token.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/login_signup/unauth_screen_holder.dart';

class AuthController with ChangeNotifier {
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  Queries _queries = Queries();
  Preferences _pref = Preferences();
  String imgSrc;

  //function that uses refresh token to get new access token and refresh token when access token is expired
  void getNewToken() async {
    String refreshToken = await _pref.getRefreshToken();
    print(refreshToken);
    GraphQLClient _client = graphQLConfiguration.clientToQuery();

    QueryResult result = await _client.mutate(MutationOptions(
        document: gql(_queries.refreshToken(refreshToken))));

    if (result.hasException) {
      print(result.exception);
    } else if (!result.hasException && !result.isLoading) {
      final Token accessToken =
          new Token(tokenString: result.data['refreshToken']['accessToken']);
      await _pref.saveToken(accessToken);
      final Token refreshToken =
          new Token(tokenString: result.data['refreshToken']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      print(refreshToken.tokenString);
    } else {
      return null;
    }
  }

  //clears user and org details and pages stack
  void logout(BuildContext context) async {
    await Preferences.clearUser();
    Navigator.pushReplacement(
        context, CupertinoPageRoute(builder: (context)=> AuthScreenHolder(pageIndex: 1,)));
  }
}
