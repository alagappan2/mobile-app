import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_scanner_example/map_page.dart' as map;
import 'package:flutter_barcode_scanner_example/cards.dart';
import 'package:uni_links/uni_links.dart';

final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    new CupertinoApp(debugShowCheckedModeBanner: false,
      home: new HomeScreen(),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    ),
  );
}

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            title: Text('SCAN'),
          ),
        ],onTap: (index) {
//            print('current i = $currentIndex, clicked = $index');

        if (index == currentIndex) {
      switch (index) {
        case 0:
          firstTabNavKey.currentState!.popUntil((r) => r.isFirst);
          break;
        case 1:
          secondTabNavKey.currentState!.popUntil((r) => r.isFirst);
          break;
      }
    }

    currentIndex = index;
  },
      ),

      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoTabView(
            navigatorKey: firstTabNavKey,
            builder: (BuildContext context) => WhereIsMyCar(),
          );
        }  else {
          return CupertinoTabView(
            navigatorKey: secondTabNavKey,
            builder: (BuildContext context) => WhereIsMyCar().scanner(),
          );
        }
      },
    );
  }
}

class WhereIsMyCar extends StatefulWidget {

  scanner() => createState().ParkCarQRScan();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WhereIsMyCar> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<int> _list;
  int? _selectedItem;
  late int _nextItem;
  String link = "";

  Future<String> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      if(initialLink != null) {
        return initialLink;
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
    return "";
  }

  @override
  void initState() {
    print("In InitState");
    initUniLinks().then((value) => this.setState(() {
      link = value;
      print("link : "+value);

      if(value != null && value != "") {
        getParkingString(value);
      }
    }));
    super.initState();

    _list = ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[],
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = 1;
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];

          getMeBack();
        });
      },
      text: "text 111",
    );
  }

  // Used to build an item after it has been removed from the list. This
  // method is needed because a removed item remains visible until its
  // animation has completed (even though it's gone as far this ListModel is
  // concerned). The widget will be used by the
  // [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
      int item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      selected: false,
      text: "Remove",
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert(String text) {
    final int index =_selectedItem == null ? _list.length : _list.indexOf(_selectedItem!);
    _list.insert(index, _nextItem++, text);
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem!));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  Future<void> ParkCarQRScan() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

     getParkingString(barcodeScanRes);
  }

  void getParkingString(String barcodeScanRes){

    setState(() {

      _insert("lat long list");

      Animation<double> animation = AnimationStatus.dismissed as Animation<double>;

      _buildItem(context,_nextItem++,animation);
    });

  }

  Future<void> getMeBack() async {
    Navigator.push(context,new MaterialPageRoute(builder: (ctxt) => new map.MapPage()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(title: const Text('MyWorkplace'),
                leading: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ClipOval(
                    child: Image(
                      image: AssetImage('assets/friend1.jpg'),
                    ),
                  ),
                ),
                actions: <Widget>[
                //IconButton(icon: const Icon(Icons.add_circle),onPressed: _insert("Text"), tooltip: 'insert a new item',),
                IconButton(icon: const Icon(Icons.remove_circle),onPressed: _remove,tooltip: 'remove the selected item',)
                ]),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Image.asset('assets/compass_225.png',
                        color: Colors.blueAccent,),

                        ElevatedButton(
                            onPressed: () => ParkCarQRScan(),
                            child: Text('Park Car'),
                            style :ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(18),
                            ),
                        ),
                        AnimatedList(
                          key: _listKey,
                          initialItemCount: _list.length,
                          itemBuilder: _buildItem,
                          shrinkWrap: true,
                          reverse: true,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),

                        ),
                      ]));
            })));
  }
}