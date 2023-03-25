import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xeonjia/ui/screens/info/resources/third_party_licenses.dart';
import 'package:xeonjia/utils/i18n.dart';

class InfoPage extends StatefulWidget {
  @override
  State<InfoPage> createState() => _InfoPageState();
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
      'title': 'Version: %s'.i18n.fill(['2.3.1']),
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
      'title': 'Translate'.i18n,
      'subtitle': 'Translate in your language'.i18n,
      'url': 'https://translate.deepdaikon.xyz/engage/xeonjia/',
      'icon': const Icon(Icons.translate_rounded),
    },
    {
      'title': 'Send email'.i18n,
      'subtitle': 'Ask for something or request a new feature'.i18n,
      'url': 'mailto:deepdaikon' '@' 'tuta.io?subject=Xeonjia Game',
      'icon': const Icon(Icons.email),
    },
    {
      'title': 'Report bugs'.i18n,
      'subtitle': 'Report bugs or request new feature'.i18n,
      'url': 'https://gitlab.com/deepdaikon/Xeonjia/issues',
      'icon': const Icon(Icons.bug_report),
    },
    {
      'title': 'View source code'.i18n,
      'subtitle': 'Look at the source code'.i18n,
      'url': 'https://gitlab.com/deepdaikon/Xeonjia',
      'icon': const Icon(Icons.developer_mode),
    },
    {
      'title': 'View License (GPLv3)'.i18n,
      'subtitle': 'Read software license'.i18n,
      'url': 'https://gitlab.com/deepdaikon/Xeonjia/blob/master/LICENSE',
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
        padding: const EdgeInsets.all(8),
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
              launchUrl(Uri.parse(infoMenuList[index]['url']),
                  mode: LaunchMode.externalApplication);
            } else if (infoMenuList[index]['title'] ==
                'Third Party Licenses'.i18n) {
              _licenseDialog();
            }
          },
        ),
      ),
    );
  }

  /// Display third party licenses in an alert dialog
  void _licenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          var licenseList = <Widget>[];
          for (final license in licenses) {
            licenseList.add(ExpansionTile(
              title: Text(license['lib']!),
              initiallyExpanded: true,
              children: <Widget>[
                SingleChildScrollView(child: Text(license['text']!)),
              ],
            ));
          }
          return AlertDialog(
            title: Text('Third Party Licenses'.i18n),
            content: SizedBox(
                width: double.maxFinite,
                child: ListView(children: licenseList)),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Ok'.i18n),
              ),
            ],
          );
        },
      ),
    );
  }
}
