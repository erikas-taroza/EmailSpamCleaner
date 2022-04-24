import 'package:flutter/material.dart';

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

class HomePage extends StatelessWidget
{
    const HomePage({Key? key}) : super(key: key);

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
                                            onPressed: () {},
                                        ),
                                        height: 40,
                                        width: 150
                                    ),
                                    SizedBox(
                                        child: ElevatedButton(
                                            child: const Text("Find"),
                                            onPressed: () {},
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
                                    Column(
                                        children: [
                                            ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                            ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                            ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                            ElevatedButton(onPressed: () {}, child: const Text("Button")),
                                            ElevatedButton(onPressed: () {}, child: const Text("Button"))
                                        ],
                                    )
                                ],
                            ),
                        ),
                        Container(width: 1, color: Colors.grey),
                        Expanded(
                            child: Column(
                                children: [
                                    const Text("Whitelist", style: TextStyle(fontSize: 18)),
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
                                        child: const Text("Add to Whitelist"),
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