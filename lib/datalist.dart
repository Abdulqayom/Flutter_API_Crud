import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api_crud/addapi.dart';

class DataList extends StatefulWidget {
  const DataList({super.key});

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  List items = [];
  bool isloading = true;
  bool isDeleted = true;
  Future<void> showdata() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
        isloading = false;
      });
    } else {
      print("some thing worng");
    }
  }

  Future<void> deleteById(String id) async {
    showDialog(
        context: context,
        builder: ((BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Are you Sure Want to Delete This Item?"),
            actions: [
              IconButton(
                  onPressed: () async {
                    setState(() {
                      isDeleted = false;
                    });
                    final url = 'https://api.nstack.in/v1/todos/$id';
                    final uri = Uri.parse(url);

                    final response = await http.delete(uri);
                    if (response.statusCode == 200) {
                      final filteredData = items
                          .where((element) => element['_id'] != id)
                          .toList();
                      setState(() {
                        items = filteredData;
                        isloading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              "The Item Has Been Successfully Deleted!!! ")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              "There was Some Error While \n you Delete The Item Please Try Again")));
                    }
                    // setState(() {
                    //   isDeleted = true;
                    // });
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                      isDeleted ? Icons.delete : Icons.check_circle_outlined)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.cancel)),
            ],
          );
        }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("API CRUD"),
      ),
      body: Visibility(
        visible: isloading,
        child: Center(
          child: Visibility(
              visible: items.isEmpty,
              child: Text("No Data Available"),
              replacement: CircularProgressIndicator()),
        ),
        replacement: RefreshIndicator(
          onRefresh: showdata,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;

                return ListTile(
                  trailing: PopupMenuButton(onSelected: (value) {
                    if (value == 'edit') {
                      NavigatorToEditPage(item);
                    } else if (value == 'delete') {
                      setState(() {
                        deleteById(id);
                      });
                    }
                  }, itemBuilder: (BuildContext) {
                    return [
                      PopupMenuItem(
                        child: Text("Edit"),
                        value: "edit",
                      ),
                      PopupMenuItem(
                        child: Text("Delete"),
                        value: "delete",
                      ),
                    ];
                  }),
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            NavigatorToAddPage();
            // final rout = Navigator.of(context)
            //     .push(MaterialPageRoute(builder: (context) {
            //   return PostAPI();
            // }));
            // await Navigator.push(context, rout);
            // setState(() {
            //   isloading = true;
            // });
            // showdata();
          },
          label: Text("Add")),
    );
  }

  Future<void> NavigatorToAddPage() async {
    final rout = MaterialPageRoute(builder: (context) => PostAPI());
    await Navigator.push(context, rout);
    setState(() {
      isloading = true;
    });
    showdata();
  }

  Future<void> NavigatorToEditPage(Map item) async {
    final rout = MaterialPageRoute(
        builder: (context) => PostAPI(
              item: item,
            ));
    await Navigator.push(context, rout);
    setState(() {
      isloading = true;
    });
    showdata();
  }
}
