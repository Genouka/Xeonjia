import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:xeonjia/resources/global_variables.dart';
import 'package:xeonjia/resources/third_party_licenses.dart';
import 'package:xeonjia/ui/screens/info/resources/info_menu_list.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INFO'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: infoMenuList.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
          leading: Icon(
            infoMenuList[index]['icon'].icon,
            size: 27,
          ),
          title: Text(
            infoMenuList[index]['title'],
            style: const TextStyle(
              fontSize: kTextFontSize,
            ),
          ),
          subtitle: Text(infoMenuList[index]['subtitle']),
          onTap: () {
            if (infoMenuList[index]['url'].length != 0) {
              launch('${infoMenuList[index]['url']}');
            } else if (infoMenuList[index]['title'] == 'Third Party Licenses') {
              _licenseDialog();
            }
          },
        ),
      ),
    );
  }

  // Display third party licenses in an alert dialog
  void _licenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          List<Widget> _licenseList = [];
          licenses.forEach((license) {
            _licenseList.add(ExpansionTile(
              title: Text(license['lib']),
              initiallyExpanded: true,
              children: <Widget>[
                SingleChildScrollView(child: Text(license['text'])),
              ],
            ));
          });
          return AlertDialog(
            title: const Text('Third Party Licenses'),
            content: Container(
                width: double.maxFinite,
                child: ListView(
                  children: _licenseList,
                )),
            actions: <Widget>[
              FlatButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
