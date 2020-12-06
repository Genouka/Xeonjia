import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/ui/screens/info/resources/third_party_licenses.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final List<Map<String, dynamic>> infoMenuList = [
    {
      'title': 'By %s'.i18n.fill(['DeepDaikon']),
      'subtitle': 'App developed by %s'.i18n.fill(['DeepDaikon']),
      'url': 'https://deepdaikon.xyz',
      'icon': const Icon(Icons.change_history),
    },
    {
      'title': 'Version: %s'.i18n.fill(['2.0.0']),
      'subtitle': 'App version'.i18n,
      'url': '',
      'icon': const Icon(Icons.looks_two),
    },
    {
      'title': 'Donate'.i18n,
      'subtitle': 'Support the development'.i18n,
      'url': 'https://deepdaikon.xyz/donate',
      'icon': const Icon(Icons.euro),
    },
    {
      'title': 'Updates'.i18n,
      'subtitle': 'Search for updates'.i18n,
      'url': 'https://f-droid.org/packages/xyz.deepdaikon.xeonjia/',
      'icon': const Icon(Icons.system_update),
    },
    {
      'title': 'Changelog'.i18n,
      'subtitle': 'View app changelog'.i18n,
      'url': 'https://gitlab.com/DeepDaikon/Xeonjia/blob/master/CHANGELOG',
      'icon': const Icon(Icons.playlist_add),
    },
    {
      'title': 'View source code'.i18n,
      'subtitle': 'Look at the source code'.i18n,
      'url': 'https://gitlab.com/DeepDaikon/Xeonjia',
      'icon': const Icon(Icons.developer_mode),
    },
    {
      'title': 'Report bugs'.i18n,
      'subtitle': 'Report bugs or request new feature'.i18n,
      'url': 'https://gitlab.com/DeepDaikon/Xeonjia/issues',
      'icon': const Icon(Icons.bug_report),
    },
    {
      'title': 'Send email'.i18n,
      'subtitle': 'Ask for something or request a new feature'.i18n,
      'url': 'mailto:deepdaikon' '@' 'tuta.io?subject=Xeonjia Game',
      'icon': const Icon(Icons.email),
    },
    {
      'title': 'View License (GPLv3)'.i18n,
      'subtitle': 'Read software license'.i18n,
      'url': 'https://gitlab.com/DeepDaikon/Xeonjia/blob/master/LICENSE',
      'icon': const Icon(Icons.chrome_reader_mode),
    },
    {
      'title': 'Third Party Licenses'.i18n,
      'subtitle': 'Read third party notices'.i18n,
      'url': '',
      'icon': const Icon(Icons.code),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Info'.i18n.toUpperCase()), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: infoMenuList.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
          leading: Icon(infoMenuList[index]['icon'].icon, size: 27),
          title: Text(
            infoMenuList[index]['title'],
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(infoMenuList[index]['subtitle']),
          onTap: () async {
            if (infoMenuList[index]['url'].length != 0) {
              final url = Uri.encodeFull(infoMenuList[index]['url']);
              if (await canLaunch(url)) await launch(url);
            } else if (infoMenuList[index]['title'] ==
                'Third Party Licenses'.i18n) {
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
          var _licenseList = <Widget>[];
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
            title: Text('Third Party Licenses'.i18n),
            content: Container(
                width: double.maxFinite,
                child: ListView(children: _licenseList)),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'.i18n),
                onPressed: Navigator.of(context).pop,
              ),
            ],
          );
        },
      ),
    );
  }
}
