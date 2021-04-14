import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/utils/globals.dart';

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  final page ofPage;
  LoadingShimmer({this.itemCount, this.ofPage});
  @override
  Widget build(BuildContext context) {
    return ofPage == page.feeds
        ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          children: <Widget>[
                            Card(
                              color: Theme.of(context).backgroundColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Shimmer.fromColors(
                                          baseColor: Theme.of(context).backgroundColor,
                                          highlightColor: Colors.transparent,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            width: double.infinity,
                                            color: Theme.of(context).backgroundColor,
                                          ),
                                        ),
                                      )),
                                  Row(children: <Widget>[
                                    SizedBox(
                                      width: 30,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Shimmer.fromColors(
                                        baseColor: Theme.of(context).backgroundColor,
                                        highlightColor: Colors.transparent,
                                        child: Container(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(children: <Widget>[
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          50,
                                      child: Shimmer.fromColors(
                                        baseColor: Theme.of(context).backgroundColor,
                                        highlightColor: Colors.transparent,
                                        child: Container(
                                          color: Theme.of(context).backgroundColor,
                                        ),
                                      ),
                                    ),
                                  ]),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Shimmer.fromColors(
                                      baseColor: Theme.of(context).backgroundColor,
                                      highlightColor: Colors.transparent,
                                      child: Container(
                                        height:25,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Shimmer.fromColors(
                                      baseColor: Theme.of(context).backgroundColor,
                                      highlightColor: Colors.transparent,
                                      child: Container(
                                        height: 20,
                                        width: 250,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            likeButton(index,context),
                                            commentCounter(index,context),
                                            Container(width: 80)
                                          ])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              )
            ],
          )
        : ofPage == page.profile
            ? Column(
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
                          title: Shimmer.fromColors(
                            baseColor: Theme.of(context).backgroundColor,
                            highlightColor: Colors.transparent,
                            child: Text(S.of(context).titleProfile,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.white)),
                          ),
                          trailing: Shimmer.fromColors(
                            baseColor: Theme.of(context).backgroundColor,
                            highlightColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).backgroundColor,
                            highlightColor: Colors.transparent,
                            child: Container(
                              height:25,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).backgroundColor,
                            highlightColor: Colors.transparent,
                            child: Container(
                              height: 20,
                              width: 250,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: itemCount,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).backgroundColor,
                            highlightColor: Colors.transparent,
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                    ),
                  )
                ],
              )
            : SizedBox();
  }

  //function which counts the number of comments on a particular post
  Widget commentCounter(index,context) {
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).backgroundColor,
            highlightColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.comment,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  //function to like
  Widget likeButton(index,context) {
    return Row(children: [
      SizedBox(
        height: 30,
        width: 30,
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).backgroundColor,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(Icons.thumb_up, color: Color(0xff9A9A9A)),
      ),
    ]);
  }
}
