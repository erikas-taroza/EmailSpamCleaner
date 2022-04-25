import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart';
import 'gmail_api_helper.dart' as gmail;

import 'email_entry.dart';

void main() 
{
    runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
    const MyApp({Key? key}) : super(key: key);

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) 
    {
        return const MaterialApp(
            home: HomePage(),
        );
    }
}

class HomePage extends StatefulWidget
{
    const HomePage({Key? key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
{
    List<Message> _emails = [];

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(title: const Center(child: Text("Email Spam Cleaner")),),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                    SizedBox(
                                        child: ElevatedButton(
                                            child: const Text("Login"),
                                            onPressed: () async => await gmail.login()
                                        ),
                                        height: 40,
                                        width: 150
                                    ),
                                    SizedBox(
                                        child: ElevatedButton(
                                            child: const Text("Find"),
                                            onPressed: () async {
                                                List<Message> newEmails = await gmail.readEmails();
                                                setState(() {
                                                    _emails = newEmails;
                                                });
                                            },
                                        ),
                                        height: 40,
                                        width: 150
                                    ),
                                    SizedBox(
                                        child: ElevatedButton(
                                            child: const Text("Delete"),
                                            onPressed: () {},
                                        ),
                                        height: 40,
                                        width: 150
                                    ),
                                ],
                            ),
                        ),
                        Container(width: 1, color: Colors.grey),
                        Expanded(
                            child: Column(
                                children: [
                                    const Text("Queued to Delete", style: TextStyle(fontSize: 18)),
                                    const SizedBox(height: 10),
                                    //replace with listview
                                    Expanded(
                                      child: ListView.separated(
                                            itemCount: _emails.length,
                                            itemBuilder: (context, index) {
                                                if(_emails.isEmpty) return Container();

                                                Message email = _emails[index];
                                                return EmailEntry(
                                                    email.payload!.headers!.where((element) => element.name == "From").first.value!, 
                                                    email.payload!.headers!.where((element) => element.name == "Subject").first.value!,
                                                    email.snippet!
                                                );
                                            },
                                            separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                                      ),
                                    )
                                ],
                            ),
                        ),
                        Container(width: 1, color: Colors.grey),
                        Expanded(
                            child: Column(
                                children: [
                                    const Text("Blacklist", style: TextStyle(fontSize: 18)),
                                    const SizedBox(height: 10),
                                    //replace with listview
                                    Expanded(
                                        child: Column(
                                            children: [
                                                ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                                ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                                ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                                ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                                ElevatedButton(onPressed: () {}, child: const Text("Button"))
                                            ],
                                        ),
                                    ),
                                    ElevatedButton(
                                        child: const Text("Add to Blacklist"),
                                        onPressed: (){},
                                    )
                                ],
                            ),
                        ),
                    ],
                )    
            )
        );
    }
}