import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/info/resources/third_party_licenses.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

class InfoPage extends StatefulWidget {
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final List<Map<String, dynamic>> infoMenuList = [
    {
      'title': 'DeepDaikon Project',
      'subtitle': 'Game developed by %s'.i18n.fill(['DeepDaikon']),
      'url': 'https://deepdaikon.xyz',
      'icon': const Icon(Icons.change_history),
    },
    {
      'title': 'Version: %s'.i18n.fill(['2.5.0']),
      'subtitle': 'App version'.i18n,
      'url': '',
      'icon': const Icon(Icons.looks_3_outlined),
    },
    {
      'title': 'Donate'.i18n,
      'subtitle': 'Contribute to the project'.i18n,
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
      'subtitle': 'Ask for something'.i18n,
      'url': 'mailto:deepdaikon' '@' 'tuta.io?subject=Xeonjia Game',
      'icon': const Icon(Icons.email),
    },
    {
      'title': 'Report bugs'.i18n,
      'subtitle': 'Report the bugs you found'.i18n,
      'url': 'https://gitlab.com/deepdaikon/Xeonjia/issues',
      'icon': const Icon(Icons.bug_report),
    },
    {
      'title': 'Source code'.i18n,
      'subtitle': 'View the source code'.i18n,
      'url': 'https://gitlab.com/deepdaikon/Xeonjia',
      'icon': const Icon(Icons.developer_mode),
    },
    {
      'title': 'License (GPLv3)'.i18n,
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
  int focusItem = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'.i18n.toUpperCase()),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w600,
          fontFamily: settings.font,
        ),
        leading: Container(),
        actions: [
          closeButton(
            context,
            (bool focus) => setState(() => focus ? focusItem = -1 : null),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: gradientDecoration(),
        child: ScrollConfiguration(
          behavior: NoGlow(),
          child: Container(
            color: Colors.black45,
            child: Column(
              children: [
                Container(height: 80),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: infoMenuList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          color: focusItem == index
                              ? Colors.white24
                              : Colors.white12,
                          child: ListTile(
                            onFocusChange: (bool focus) => setState(() {
                              focus ? focusItem = index : null;
                            }),
                            leading: Icon(
                              infoMenuList[index]['icon'].icon,
                              size: 27,
                              color: Colors.white70,
                            ),
                            title: Text(
                              infoMenuList[index]['title'],
                              style: TextStyle(
                                  fontSize: 32, fontFamily: settings.font),
                            ),
                            subtitle: Text(infoMenuList[index]['subtitle'],
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white70,
                                    fontFamily: settings.font)),
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
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              title: Text(license['lib']!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 32, fontFamily: 'dd5x7')),
              initiallyExpanded: true,
              children: <Widget>[
                SingleChildScrollView(
                    child: Text(license['text']!,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: settings.font))),
              ],
            ));
          }
          return AlertDialog(
            title: Text('Third Party Licenses'.i18n,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontFamily: settings.font)),
            content: SizedBox(
                width: double.maxFinite,
                child: ListView(children: licenseList)),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Ok'.i18n,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: settings.font)),
              ),
            ],
          );
        },
      ),
    );
  }
}
