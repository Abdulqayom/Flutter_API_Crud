import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class PostAPI extends StatefulWidget {
  Map? item;
  PostAPI({super.key, this.item});

  @override
  State<PostAPI> createState() => _PostAPIState();
}

class _PostAPIState extends State<PostAPI> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isloading = true;
  bool isEdit = false;
  Future<void> submit() async {
    setState(() {
      isloading = false;
    });
    var title = titleController.text;
    var description = descriptionController.text;
    final url = 'https://api.nstack.in/v1/todos';
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 201) {
      showSuccessBinar(context, "Data has been successfully Addid");
      setState(() {
        isloading = true;
      });
      descriptionController.text = "";
      titleController.text = "";
    } else {
      setState(() {
        isloading = true;
      });
      showSuccessBinar(
          context, "There are some Error Whire you Adding the Data");
    }
  }

  Future<void> update() async {
    setState(() {
      isloading = false;
    });
    final items = widget.item;
    if (items == null) {
      print("you can't add something while you don't have some items");
      return;
    }
    final id = items['_id'];
    final isCompleted = items['is_completed'];
    var title = titleController.text;
    var description = descriptionController.text;
    final url = 'https://api.nstack.in/v1/todos/$id';
    final body = {
      "title": title,
      "description": description,
      "is_completed": isCompleted
    };
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      showSuccessBinar(context, "Data has been successfully Updated");
      setState(() {
        isloading = true;
      });
      Navigator.of(context).pop();
    } else {
      setState(() {
        isloading = true;
      });
      showSuccessBinar(
          context, "There are some Error Whire you Updating the Data");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final items = widget.item;
    if (items != null) {
      isEdit = true;
      final titles = items['title'];
      final descriptions = items['description'];
      titleController.text = titles;
      descriptionController.text = descriptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Page' : "Add Page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: "Title"),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(hintText: "Description"),
            maxLength: 100,
            maxLines: 5,
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () async {
                isEdit ? update() : submit();
              },
              child: isloading
                  ? SizedBox(
                      height: 20,
                      width: 50,
                      child: Text(isEdit ? "Update" : "Submit"))
                  : SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        heightFactor: 20,
                        widthFactor: 20,
                        child: CircularProgressIndicator(),
                      ),
                    )),
        ],
      ),
    );
  }

  void showSuccessBinar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorBinar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
