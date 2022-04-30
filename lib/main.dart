import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'widgets/blacklist_view.dart';
import 'widgets/emails_list_view.dart';
import 'widgets/control_buttons.dart';
import 'blacklist_helper.dart';
//TODO: Delete emails under useless categories
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
    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(title: const Center(child: Text("Email Spam Cleaner")),),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    children: [
                        const ControlButtons(),
                        const SizedBox(height: 8),
                        Expanded(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    const EmailsListView(),
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