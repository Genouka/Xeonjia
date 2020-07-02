import 'package:flutter/material.dart';
import 'package:xeonjia/models/game_mode.dart';

import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/ui/screens/home/resources/page_list.dart';
import 'package:xeonjia/ui/widgets/toast.dart';
import 'package:xeonjia/util/local_data_controller.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XEONJIA'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
        leading: const Hero(
          tag: 'character',
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Material(
              color: Colors.white70,
              shape: CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(6),
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
              return const Divider(color: Colors.black45);
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
                    fontSize: 20,
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
