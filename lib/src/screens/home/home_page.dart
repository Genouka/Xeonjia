import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/home/resources/page_list.dart';
import 'package:xeonjia/src/screens/user/user_page.dart';
import 'package:xeonjia/src/util/utils.dart';
import 'package:xeonjia/src/widgets/basic.dart';
import 'package:xeonjia/src/widgets/toast.dart';

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
            gradient: appGradient,
          ),
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
                  image: AssetImage('assets/images/${mainCharacter.imageName}'),
                  fit: BoxFit.cover,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        FadeRoute(UserPage(appBarCollapsed: false)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 70),
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
                  if (pageList[index]['title'] == 'Arena' &&
                      !settings.rulesRead) {
                    Toast.show('You must read "How to play" first', context,
                        gravity: 1, duration: 1);
                  } else {
                    Navigator.push(
                      context,
                      FadeRoute(pageList[index]['page']),
                    );
                  }
                },
              );
            }
          }),
      floatingActionButton: Hero(
        tag: 'Play',
        child: PlayButton(
          page: GamePage(GameMode.story),
          gradient: true,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
