import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/home/resources/page_list.dart';
import 'package:xeonjia/src/screens/user/user_page.dart';
import 'package:xeonjia/src/util/utils.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setScreenDimension(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('X E O N J I A'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.lightBlue[700],
            Colors.lightBlue[400],
            Colors.lightBlue[200]
          ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
        ),
        leading: Hero(
          tag: 'character',
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: Colors.white70,
              shape: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Ink.image(
                    image:
                        AssetImage('assets/images/${mainCharacter.imageName}'),
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          _FadeRoute(page: UserPage(appBarCollapsed: false)),
                        );
                      },
                    )),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: pageList.length,
          itemBuilder: (BuildContext context, int index) {
            if (pageList[index].containsKey('divider')) {
              return Divider(color: Colors.black45);
            } else {
              return ListTile(
                leading: Icon(
                  pageList[index]['icon'].icon,
                  size: 27,
                  color: Colors.grey[600],
                ),
                title: Text(
                  pageList[index]['title'],
                  style: const TextStyle(
                    fontSize: kTextFontSize,
                  ),
                ),
                subtitle: Text(pageList[index]['subtitle']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => pageList[index]['page']),
                  );
                },
              );
            }
          }),
      floatingActionButton: Hero(
        tag: 'Play',
        child: Container(
          width: 150,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              gradient: LinearGradient(colors: [
                Colors.lightBlue[700],
                Colors.lightBlue[400],
                Colors.lightBlue[200]
              ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
          child: FlatButton(
            child: const Text(
              'P L A Y',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamePage()),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _FadeRoute extends PageRouteBuilder {
  final Widget page;
  _FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(opacity: animation, child: child),
        );
}
