import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cryptocoin/Configuration/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Config config = Config();
  List list = List();
  List website = List();
  ScrollController _scrollController;
  int postion = 0;
  int perpage = 100;
  getData() async {
    _refreshIndicatorKey.currentState?.show();
    var response = await http.get(
      "https://api.nomics.com/v1/currencies/ticker?key=d623b626a574a877977e0b4dc5731ba1&convert=INR&per-page=$perpage&page=1",
    );
    list.clear();
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      for (var a in data) {
        list.add({
          "logo_url": a['logo_url'],
          "id": a['id'],
          'status': a['status'],
          'price': a['price'],
          'name': a['name'],
          'change': (double.parse(a['1d']['price_change']) /
                  double.parse(a['price']) *
                  100)
              .toStringAsFixed(2)
        });
      }
    }
    setState(() {});
    loadmore();
  }

  loadmore() async {
    var response = await http.get(
      "https://api.nomics.com/v1/currencies/ticker?key=d623b626a574a877977e0b4dc5731ba1&convert=INR&per-page=$perpage&page=2",
    );
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      for (var a in data) {
        list.add({
          "logo_url": a['logo_url'],
          "id": a['id'],
          'status': a['status'],
          'price': a['price'],
          'name': a['name'],
          "change": (double.parse(a['1d']['price_change']) /
                  double.parse(a['price']) *
                  100)
              .toStringAsFixed(2)
        });
      }
      print(list.length);
      setState(() {});
    } else {
      print("something event wrong ${response.statusCode}");
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(
          height: 20,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.ethereum,
              size: 35,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        title: Text(
          "Crypto",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: config.baseColor,
      ),
      backgroundColor: config.baseColor,
      body: LiquidPullToRefresh(
        key: _refreshIndicatorKey,
        animSpeedFactor: 4,
        color: config.baseColor,
        showChildOpacityTransition: false,
        backgroundColor: Colors.grey.shade400,
        onRefresh: () => getData(),
        child: (list.isEmpty)
            ? Container(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade600,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              )
            : NotificationListener(
                child: ListView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    SizedBox(
                      width: 1,
                    ),
                    for (var item in list)
                      if (list.isNotEmpty)
                        FocusedMenuHolder(
                          blurSize: 5,
                          animateMenuItems: true,
                          blurBackgroundColor: Colors.black54,
                          duration: Duration(milliseconds: 100),
                          menuWidth: MediaQuery.of(context).size.width * 0.30,
                          menuItemExtent: 45,
                          menuBoxDecoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(7.0),
                            ),
                          ),
                          menuOffset:
                              10.0, // Offset value to show menuItem from the selected item
                          bottomOffsetHeight: 1.0,
                          menuItems: [
                            FocusedMenuItem(
                              backgroundColor: config.cardColor,
                              title: Text(
                                "Open",
                                style: TextStyle(
                                    fontSize: 16.5, color: Colors.white),
                              ),
                              trailingIcon: Icon(
                                Icons.open_in_full,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                var r = await http.get(
                                    "https://api.nomics.com/v1/currencies?key=d623b626a574a877977e0b4dc5731ba1&ids=${item['id']}&attributes=website_url");
                                var response = json.decode(r.body);
                                String url = response[0]['website_url'] == ''
                                    ? 'www.google.com'
                                    : response[0]['website_url'];
                                await FlutterWebBrowser.openWebPage(
                                  url: url,
                                  customTabsOptions: CustomTabsOptions(
                                    colorScheme: CustomTabsColorScheme.dark,
                                    toolbarColor: config.baseColor,
                                    addDefaultShareMenuItem: true,
                                    instantAppsEnabled: true,
                                    showTitle: true,
                                    urlBarHidingEnabled: true,
                                  ),
                                  safariVCOptions: SafariViewControllerOptions(
                                    barCollapsingEnabled: true,
                                    entersReaderIfAvailable: true,
                                    preferredBarTintColor: Colors.green,
                                    preferredControlTintColor: Colors.amber,
                                    dismissButtonStyle:
                                        SafariViewControllerDismissButtonStyle
                                            .close,
                                    modalPresentationCapturesStatusBarAppearance:
                                        true,
                                  ),
                                );
                              },
                            ),
                          ],
                          onPressed: null,
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.all(3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Container(
                                color: config.cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: item['logo_url'] == ""
                                                    ? Container(
                                                        child: Icon(
                                                            Icons
                                                                .error_outlined,
                                                            size: 35,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : (item["logo_url"]
                                                            .contains("svg"))
                                                        ? SvgPicture.network(
                                                            item["logo_url"],
                                                            width: 35,
                                                            height: 35,
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: item[
                                                                "logo_url"],
                                                            width: 35,
                                                            height: 35,
                                                          ),
                                                width: 40,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                item["name"],
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "₹ ${(NumberFormat.currency(locale: 'HI').format(double.parse(double.parse(item['price']).toStringAsFixed(3)))).toString().replaceAll('INR', '')}",
                                                style: TextStyle(
                                                    fontSize: 16.5,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Status",
                                                style: TextStyle(
                                                    fontSize: 15.5,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.circle,
                                                color:
                                                    item['status'] != 'dead' &&
                                                            item['status'] ==
                                                                "inactive"
                                                        ? Colors.red
                                                        : Colors.green,
                                                size: 15,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item['change'] == null
                                                    ? ""
                                                    : item['change'] + " %",
                                                style: TextStyle(
                                                  color: item['change']
                                                          .toString()
                                                          .contains("-")
                                                      ? Colors.red.shade700
                                                      : Colors.green,
                                                  fontSize: 16.5,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                  ],
                ),
              ),
      ),
    );
  }
}
