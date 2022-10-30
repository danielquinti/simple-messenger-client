import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Message> createMessage(String title) async {
  final response = await http.post(
    Uri.parse('https://django.danielquinti.repl.co/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'text': title,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Message.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create Message.');
  }
}

class Message {
  final String text;

  const Message({required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  Future<Message>? _futureMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino Morse Messenger Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Arduino Morse Messenger Client'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureMessage == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          autovalidateMode: AutovalidateMode.always,
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Type a message...'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            RegExp regex = RegExp(r"""[a-zA-Z0-9,?:-\\"()=.;/'\_+@*]+""");
            if (!regex.hasMatch(value)){return 'Text contains forbidden characters';}
            else {return null;}
          },
    ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureMessage = createMessage(_controller.text);
            });
          },
          child: const Text('Send message'),
        ),
      ],
    );
  }

  FutureBuilder<Message> buildFutureBuilder() {
    return FutureBuilder<Message>(
      future: _futureMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.text);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}