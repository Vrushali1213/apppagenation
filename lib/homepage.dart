import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List CFGList = [];
  var currentBookingData;

  ScrollController _scrollController = ScrollController();
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  var page = 1;
  bool _isdataavailable = true;

  Future<void> getUsersData() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    var response = await http.get(
      Uri.parse("https://reqres.in/api/users?page=1"),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      List<dynamic> data = map["data"];

      var total_pages = map['total_pages'];
      var current_pages = map['page'];
      if (!mounted) return;
      print("total_pages............$total_pages");
      if (total_pages != current_pages) {
        setState(() {
          _isdataavailable = true;
        });
      }

      setState(() {
        CFGList = data;
        print(CFGList);
      });
    } else {
      print(' Error Api');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  bool _hasNextPage = true;
  void _loadMore() async {
    var jsonResponse;
    var response;
    if (_isdataavailable == true) {
      if (_hasNextPage == true &&
          _isFirstLoadRunning == false &&
          _isLoadMoreRunning == false &&
          _scrollController.position.extentAfter < 300) {
        setState(() {
          _isLoadMoreRunning = true;
        });
        page += 1;
        try {
          response = await http.get(
            Uri.parse("https://reqres.in/api/users?page=$page"),
          );

          if (response.statusCode == 200) {
            jsonResponse = json.decode(response.body);
            Map<String, dynamic> map = json.decode(response.body);
            List<dynamic> data = map["data"];
            print("next page data..... $data");

            var total_pages = map['total_pages'];
            var current_pages = map['page'];
            if (!mounted) return;
            print("total_pages............$total_pages");
            if (total_pages != current_pages) {
              setState(() {
                _isdataavailable = true;
              });
            } else {
              setState(() {
                _isdataavailable = false;
                _hasNextPage = false;
              });
            }
            setState(() {
              CFGList.addAll(data);
              print("CFGList .. next page $CFGList");
            });
          } else {}
        } catch (err) {
          print('Something went wrong!');
        }
        setState(() {
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsersData();
    _scrollController.addListener(_loadMore);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("CFG Pagination"),
          toolbarHeight: 70,
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                child: Column(children: [
                  Expanded(
                      child: CFGList.length != null
                          ? ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              itemCount: CFGList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    height: screenHeight * 0.17,
                                    width: screenWidth * 0.9,
                                    child: Row(children: [
                                      Container(
                                        width: screenWidth * 0.25,
                                        child: Image.network(
                                            CFGList[index]["avatar"]),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(CFGList[index]["first_name"],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  )),
                                              Text(CFGList[index]["last_name"],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  )),
                                              Text(CFGList[index]["email"],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  )),
                                            ],
                                          ))
                                    ]));
                              })
                          : Container()),
                  if (_isLoadMoreRunning == true)
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ]))));
  }
}
