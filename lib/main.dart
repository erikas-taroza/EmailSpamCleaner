import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:googleapis/gmail/v1.dart';
import 'gmail_api_helper.dart' as gmail;

import 'email_entry.dart';
import 'blacklist_helper.dart';
import 'models/blacklist_object.dart';

void main() 
{
    WidgetsFlutterBinding.ensureInitialized();
    setWindowMinSize(const Size(900, 600));
    setWindowMaxSize(const Size(900, 600));

    Blacklist _ = Blacklist.instance;
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
    List<EmailEntry> _emails = [];

    Future<List<EmailEntry>> _getEmailsAsEntries() async
    {
        List<Message> newEmails = await gmail.readEmails();

        List<EmailEntry> entries = [];
        for (Message email in newEmails) 
        {
            entries.add(
                EmailEntry(
                    email.payload!.headers!.where((element) => element.name == "From").first.value!, 
                    email.payload!.headers!.where((element) => element.name == "Subject").first.value!,
                    email.snippet!
                )
            );
        }

        return entries;
    }

    void _showAddBlacklistDialog(BuildContext context)
    {
        String value = "";

        showDialog(
            context: context,
            builder: (c) => AlertDialog(
                title: const Text("Add to Blacklist"),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text("Input should be in either format:\n"),
                        const Text("user@domain.com"),
                        const Text("domain.com\n"),
                        TextField(
                            decoration: const InputDecoration(hintText: "Value"),
                            onChanged: (text) => value = text,
                        ),
                    ],
                ),
                actions: [
                    TextButton(
                        child: const Text("CANCEL"),
                        onPressed: () => Navigator.of(c).pop(),
                    ),
                    TextButton(
                        child: const Text("ADD"),
                        onPressed: () {
                            Blacklist.instance.addString(value);
                            Navigator.of(c).pop();
                        },
                    )
                ],
            )
        );
    }

    //TODO: Refresh page when blacklist item is edited.
    @override
    Widget build(BuildContext context)
    {
        ScrollController c1 = ScrollController();
        ScrollController c2 = ScrollController();

        return Scaffold(
            appBar: AppBar(title: const Center(child: Text("Email Spam Cleaner")),),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                SizedBox(
                                    child: ElevatedButton(
                                        child: const Text("Login"),
                                        onPressed: () async => await gmail.login()
                                    ),
                                    height: 35,
                                    width: 150
                                ),
                                SizedBox(
                                    child: ElevatedButton(
                                        child: const Text("Find"),
                                        onPressed: () async {
                                            List<EmailEntry> entries = await _getEmailsAsEntries();
                                            setState(() => _emails = entries);
                                        },
                                    ),
                                    height: 35,
                                    width: 150
                                ),
                                SizedBox(
                                    child: ElevatedButton(
                                        child: const Text("Delete"),
                                        onPressed: () {},
                                    ),
                                    height: 35,
                                    width: 150
                                ),
                            ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Expanded(
                                        child: Column(
                                            children: [
                                                const Text("Emails Found", style: TextStyle(fontSize: 18)),
                                                const SizedBox(height: 10),
                                                //replace with listview
                                                Expanded(
                                                    child: ListView.separated(
                                                        controller: c1,
                                                            itemCount: _emails.length,
                                                            itemBuilder: (context, index) {
                                                                if(_emails.isEmpty) return Container();
                                    
                                                                return _emails[index];
                                                            },
                                                            separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                                                    ),
                                                )
                                            ],
                                        ),
                                    ),
                                    Container(width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 5, right: 5),),
                                    Expanded(
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                const Text("Blacklisted Senders", style: TextStyle(fontSize: 18)),
                                                const SizedBox(height: 10),
                                                Expanded(
                                                    child: FutureBuilder(
                                                        future: Blacklist.instance.getAll(),
                                                        builder: (_, snapshot) {
                                                            if(snapshot.hasData)
                                                            {
                                                                List<BlacklistObject> data = snapshot.data as List<BlacklistObject>;

                                                                return ListView.builder(
                                                                    controller: c2,
                                                                    itemCount: data.length,
                                                                    itemBuilder: (context, index) {
                                                                        return Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                                Text(
                                                                                    data[index].value + " (${data[index].type})",
                                                                                    style: const TextStyle(fontSize: 16),
                                                                                ),
                                                                                IconButton(
                                                                                    icon: const Icon(Icons.close),
                                                                                    onPressed: () => Blacklist.instance.remove(index),
                                                                                )
                                                                            ],
                                                                        );
                                                                    }
                                                                );
                                                            }
                                                            else { return Container(); }
                                                        }
                                                    )
                                                ),
                                                ElevatedButton(
                                                    child: const Text("Add to Blacklist"),
                                                    onPressed: () => _showAddBlacklistDialog(context),
                                                )
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ]
                )    
            )
        );
    }
}