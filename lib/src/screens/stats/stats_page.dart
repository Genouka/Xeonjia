import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/stats/resources/stat_list.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> statsList = statsListGenerator();
    return Scaffold(
      appBar: AppBar(
        title: const Text('S T A T S'),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: statsList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            statsList[index]['title'],
            style: const TextStyle(fontSize: kTextFontSize),
          ),
          /*subtitle: Text(
                    statsList[index]['subtitle'],
                    style: TextStyle(fontSize: kTextFontSize - 4),
                  ),*/
          trailing: Text(statsList[index]['value'].toString()),
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
