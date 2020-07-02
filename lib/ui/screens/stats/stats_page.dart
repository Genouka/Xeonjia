import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/stats/resources/stat_list.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List statsList = statsListGenerator();
    return Scaffold(
      appBar: AppBar(
        title: const Text('STATS'),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: statsList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            statsList[index]['title'],
            style: const TextStyle(fontSize: 20),
          ),
          /*subtitle: Text(
                    statsList[index]['subtitle'],
                    style: TextStyle(fontSize: 20 - 4),
                  ),*/
          trailing: Text(statsList[index]['value'].toString()),
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
