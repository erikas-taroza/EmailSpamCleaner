import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_size/window_size.dart';
import 'package:googleapis/gmail/v1.dart';
import 'gmail_api_helper.dart' as gmail;

import 'widgets/email_entry.dart';
import 'widgets/blacklist_view.dart';
import 'widgets/emails_list_view.dart';
import 'blacklist_helper.dart';

void main() async
{
    WidgetsFlutterBinding.ensureInitialized();
    setWindowMinSize(const Size(900, 600));
    setWindowMaxSize(const Size(900, 600));

    Blacklist b = Blacklist.instance;
    await b.retrieve();

    runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
    const MyApp({Key? key}) : super(key: key);

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

    //Gets the emails from the api helper as creates widgets used for display.
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

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(title: const Center(child: Text("Email Spam Cleaner")),),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    children: [
                        //Login, Find, Delete buttons.
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
                                        child: const Text("Find Emails"),
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
                                        style: ElevatedButton.styleFrom(primary: Colors.red),
                                        child: const Text("Delete"),
                                        onPressed: () async {
                                            await gmail.deleteEmails();
                                        },
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
                                    EmailsListView(_emails),
                                    Container(width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 5, right: 5),),
                                    const BlacklistView(),
                                ],
                            ),
                        ),
                    ]
                )    
            )
        );
    }
}