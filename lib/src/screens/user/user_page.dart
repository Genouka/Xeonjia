import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/resources/weapon_details.dart';
import 'package:xeonjia/src/screens/user/resources/content_list.dart';
import 'package:xeonjia/src/util/local_data_controller.dart';
import 'package:xeonjia/src/widgets/toast.dart';

// Text controller used to edit character name
TextEditingController _textFieldController =
    TextEditingController(text: mainCharacter.name);

class UserPage extends StatefulWidget {
  // True if app bar should start collapsed
  final bool appBarCollapsed;

  UserPage({@required this.appBarCollapsed});

  @override
  _UserPageState createState() =>
      _UserPageState(appBarCollapsed: appBarCollapsed);
}

class _UserPageState extends State<UserPage> {
  // True if app bar should start collapsed
  final bool appBarCollapsed;
  _UserPageState({@required this.appBarCollapsed});

  // Sliver app bar height
  double _expandedHeight;

  // Variable used to track if character name is being edited
  bool _editMode = false;

  // Text displayed if character has no enough money to buy something
  String _noEnoughMoney = "You don't have enough money";

  @override
  Widget build(BuildContext context) {
    // List of character stats
    List<Map<String, String>> characterStatsList =
        characterStatsListGenerator();

    _expandedHeight = MediaQuery.of(context).size.width / 4 + 80;

    return WillPopScope(
        onWillPop: () async {
          // Restore system UI overlays before exit
          // That because the android keyboard disables hidden system bars
          await SystemChrome.restoreSystemUIOverlays();
          return true;
        },
        child: Scaffold(
            body: NestedScrollView(
                controller: ScrollController(
                    initialScrollOffset:
                        appBarCollapsed ? _expandedHeight - 55 : 0),
                headerSliverBuilder: (BuildContext context,
                        bool innerBoxIsScrolled) =>
                    <Widget>[
                      SliverAppBar(
                        floating: false,
                        pinned: false,
                        snap: false,
                        expandedHeight: _expandedHeight,
                        centerTitle: true,
                        title: _editMode
                            ? TextField(
                                controller: _textFieldController,
                                autofocus: true,
                                showCursor: false,
                                autocorrect: false,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: kTextFontSize,
                                    color: Colors.white),
                                onSubmitted: (text) {
                                  saveNewName(text);
                                },
                              )
                            : Text(mainCharacter.name,
                                style:
                                    const TextStyle(fontSize: kTextFontSize)),

                        // Flexible space that contains character images
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Colors.lightBlue[700],
                                    Colors.lightBlue[400],
                                    Colors.lightBlue[200]
                                  ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight)),
                              padding: const EdgeInsets.only(top: 80),
                              child: Row(children: [
                                Hero(
                                  tag: 'character',
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/${mainCharacter.imageName}'),
                                      fit: BoxFit.fitHeight,
                                      width: MediaQuery.of(context).size.width /
                                          4),
                                ),
                                for (int direction in [2, 3, 4])
                                  Image(
                                      image: AssetImage(
                                          'assets/images/character-$direction.png'),
                                      fit: BoxFit.fitHeight,
                                      width: MediaQuery.of(context).size.width /
                                          4),
                              ])),
                        ),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(_editMode ? Icons.done : Icons.edit),
                            onPressed: () {
                              setState(() {
                                _editMode
                                    ? saveNewName(_textFieldController.text)
                                    : _editMode = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],

                // List of character information and stats
                body: ListView(children: [
                  ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigoAccent[300],
                      child: Text(mainCharacter.level.toString()),
                    ),
                    title: Text('Level: ' + mainCharacter.level.toString()),
                    children: [
                      ListTile(
                        title: const Text('Experience points'),
                        leading: const Text(''),
                        trailing:
                            Text('${mainCharacter.experiencePoints.round()}'),
                      ),
                      ListTile(
                        title: const Text('XP required for the next level'),
                        leading: const Text(''),
                        trailing: Text(
                          ((mainCharacter.experienceRemaining).toString()),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigoAccent[300],
                      child: Icon(Icons.attach_money),
                    ),
                    title: const Text('Money'),
                    trailing: Text(mainCharacter.money.toString()),
                  ),

                  // Tile that contains character stats
                  Container(
                    child: ExpansionTile(
                        title: const Text('Player Stats'),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent[300],
                          child: Icon(
                            Icons.show_chart,
                          ),
                        ),
                        initiallyExpanded: true,
                        children: <Widget>[
                          Column(children: [
                            for (var index in characterStatsList)
                              ListTile(
                                title: Text(index['name']),
                                leading: const Text(''),
                                trailing: Text(index['value']),
                              ),
                          ])
                        ]),
                  ),

                  // Tile that contains weapon stats
                  Container(
                    child: ExpansionTile(
                        title: const Text('Weapons'),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent[300],
                          child: Icon(
                            Icons.flare,
                          ),
                        ),
                        initiallyExpanded: true,
                        children: <Widget>[
                          ...weaponTileList(),
                          Column(children: [
                            ButtonBar(
                              children: <Widget>[
                                if (mainCharacter
                                    .jsonAvailableWeaponList.isNotEmpty)
                                  FlatButton(
                                    onPressed: () {
                                      weaponSelectorDialog();
                                    },
                                    child: const Text('Choose weapons'),
                                  ),
                                if (weaponDetails.length -
                                        (mainCharacter.jsonWeaponList.length +
                                            mainCharacter
                                                .jsonAvailableWeaponList
                                                .length) >
                                    0)
                                  FlatButton(
                                    onPressed: () {
                                      weaponPurchaseDialog();
                                    },
                                    child: const Text('Buy new weapons'),
                                  )
                              ],
                            )
                          ])
                        ]),
                  ),
                ]))));
  }

  // Return the list of weapons carried by the character
  List<Widget> weaponTileList() {
    List<Widget> weaponTileList = [];
    mainCharacter.jsonWeaponList.forEach((weaponId, weaponLevel) {
      weaponTileList.add(SizedBox(
        height: 60,
        child: ListTile(
          title: Text(weaponDetails[int.parse(weaponId)]['name'] +
              (weaponId != '0' ? ' - LV: $weaponLevel' : '')),
          leading: const Text(''),
          trailing: Icon(Icons.info_outline),
          onTap: () {
            weaponDetailDialog(int.parse(weaponId), weaponLevel);
          },
        ),
      ));
    });
    return weaponTileList;
  }

  // Display weapons details in a dialog
  void weaponDetailDialog(int weaponId, int weaponLevel) {
    // Upgrade weapon price. It depends on weapon level
    int _price = (weaponLevel + 1) * (weaponLevel + 1) * 500;

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title:
                  Text('${weaponDetails[weaponId]['name']} - LV: $weaponLevel'),
              content: SingleChildScrollView(
                  child: Text(weaponDetails[weaponId]['description'])),
              actions: <Widget>[
                if (weaponId != 0)
                  FlatButton(
                    textColor: mainCharacter.money - _price < 0
                        ? Colors.red
                        : Colors.green[700],
                    child: Text('Upgrade (-$_price)'),
                    onPressed: () {
                      upgradeWeapon(weaponId, weaponLevel, _price);
                    },
                  ),
                FlatButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  // Dialog that permits to select weapons to keep in game
  void weaponSelectorDialog() {
    List<dynamic> unlockedWeapons = [
      ...mainCharacter.jsonWeaponList.keys,
      ...mainCharacter.jsonAvailableWeaponList.keys
    ];
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              List<Widget> weaponTileList = [];
              unlockedWeapons.forEach((weaponId) {
                // Do not show punch
                if (weaponId != '0') {
                  weaponTileList.add(CheckboxListTile(
                    title: Text(
                        '${weaponDetails[int.parse(weaponId)]['name']} - LV: ${mainCharacter.jsonWeaponList[weaponId] ?? mainCharacter.jsonAvailableWeaponList[weaponId]}'),
                    value: mainCharacter.jsonWeaponList.containsKey(weaponId),
                    onChanged: (weaponAdded) {
                      setState(() {
                        editBroughtWeapon(weaponId, added: weaponAdded);
                      });
                    },
                  ));
                }
              });
              return AlertDialog(
                title: const Text('Select Weapons'),
                content: Container(
                    width: double.maxFinite,
                    child: ListView(
                      children: weaponTileList,
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
            }));
  }

  // Dialog used to buy new weapons
  void weaponPurchaseDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              List<Widget> weaponTileList = [];
              weaponDetails.forEach((weapon) {
                if (!mainCharacter.jsonWeaponList
                        .containsKey(weapon['id'].toString()) &&
                    !mainCharacter.jsonAvailableWeaponList
                        .containsKey(weapon['id'].toString())) {
                  weaponTileList.add(ExpansionTile(
                    title: Text('${weapon['name']}'),
                    initiallyExpanded: true,
                    children: <Widget>[
                      SingleChildScrollView(child: Text(weapon['description'])),
                      FlatButton(
                        textColor: mainCharacter.money - weapon['prize'] < 0
                            ? Colors.red
                            : Colors.green[700],
                        child: Text('Buy (-${weapon['prize']})'),
                        onPressed: () {
                          setState(() {
                            purchaseWeapon(weapon);
                          });
                        },
                      )
                    ],
                  ));
                }
              });
              return AlertDialog(
                title: const Text('Select Weapons'),
                content: Container(
                    width: double.maxFinite,
                    child: ListView(
                      children: weaponTileList,
                    )),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }));
  }

  // Save new character name
  void saveNewName(String newName) {
    setState(() {
      mainCharacter.name = newName;
      saveUserData();
      _editMode = false;
    });
  }

  // Update user page state
  void refreshPage() {
    setState(() {});
  }

  // Increase weapon level if possible
  void upgradeWeapon(int weaponId, int weaponLevel, int price) {
    if (mainCharacter.money - price >= 0) {
      if (mainCharacter.level < weaponLevel + 1) {
        Toast.show(
            'Your level is too low to buy this.\n'
            'You could only own weapon at level equal or less than yours.',
            context);
      } else {
        setState(() {
          ++mainCharacter.jsonWeaponList[weaponId.toString()];
          mainCharacter.money -= price;
        });
        saveUserData();
        Navigator.of(context).pop();
      }
    } else {
      Toast.show(_noEnoughMoney, context);
    }
  }

  // Edit weapons order
  void editBroughtWeapon(String weaponId, {@required bool added}) {
    if (added) {
      if (mainCharacter.jsonWeaponList.length <= mainCharacter.level) {
        mainCharacter.jsonWeaponList[weaponId] =
            mainCharacter.jsonAvailableWeaponList[weaponId];
        mainCharacter.jsonAvailableWeaponList.remove(weaponId);
      } else {
        Toast.show("You can't keep so many weapons at your level", context);
      }
    } else {
      mainCharacter.jsonAvailableWeaponList[weaponId] =
          mainCharacter.jsonWeaponList[weaponId];
      mainCharacter.jsonWeaponList.remove(weaponId);
    }
    saveUserData();
    refreshPage();
  }

  // Buy a weapon if possible
  void purchaseWeapon(Map<String, dynamic> weapon) {
    if (mainCharacter.money - weapon['prize'] >= 0) {
      if (mainCharacter.jsonWeaponList.length <= mainCharacter.level) {
        mainCharacter.jsonWeaponList[weapon['id'].toString()] = 0;
        Toast.show('You bought ${weapon['name']}', context);
      } else {
        mainCharacter.jsonAvailableWeaponList[weapon['id'].toString()] = 0;
        Toast.show(
            "You bought ${weapon['name']} but you can't keep so many weapons at your level. It is disabled for now",
            context);
      }
      mainCharacter.money -= weapon['prize'];
      saveUserData();
      refreshPage();
      if (weaponDetails.length -
              (mainCharacter.jsonWeaponList.length +
                  mainCharacter.jsonAvailableWeaponList.length) ==
          0) Navigator.of(context).pop();
    } else {
      Toast.show(_noEnoughMoney, context);
    }
  }
}
