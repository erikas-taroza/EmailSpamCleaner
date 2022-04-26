import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../blacklist_helper.dart';

class BlacklistView extends StatelessWidget
{
    const BlacklistView({Key? key}) : super(key: key);

    //Shows the dialog for adding a blacklist value manually.
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
                        onPressed: () async {
                            await Blacklist.instance.addString(value);
                            Navigator.of(c).pop();
                        },
                    )
                ],
            )
        );
    }

    @override
    Widget build(BuildContext context)
    {
        ScrollController sc = ScrollController();

        return Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Text("Blacklisted Senders", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Obx(() {
                            var blacklist = Blacklist.instance.blacklist;
                            
                            return ListView.builder(
                                controller: sc,
                                itemCount: blacklist.length,
                                itemBuilder: (context, index) {
                                    return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Text(
                                                blacklist[index].value + " (${blacklist[index].type})",
                                                style: const TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () async => await Blacklist.instance.remove(index),
                                            )
                                        ],
                                    );
                                }
                            );
                        })
                    ),
                    SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            child: const Text("Add to Blacklist"),
                            onPressed: () => _showAddBlacklistDialog(context),
                        ),
                    )
                ],
            ),
        );
    }
}