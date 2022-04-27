import 'package:flutter/material.dart';

import '../blacklist_helper.dart';
import '../models/blacklist_object.dart';

class EmailEntry extends StatelessWidget
{
    const EmailEntry(this.sender, this.subject, this.snippet, {Key? key}) : super(key: key);

    final String sender;
    final String subject;
    final String snippet;

    @override
    Widget build(BuildContext context) 
    {
        return Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(sender, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                RichText(text: TextSpan(
                                    text: subject + " - ",
                                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                                    children: [
                                        TextSpan(text: snippet, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.normal))
                                    ]
                                ))
                            ],
                        ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.unsubscribe_outlined),
                        onPressed: () async {
                            String senderEmail = sender.split("<")[1].split(">")[0];
                            await Blacklist.instance.add(BlacklistObject(senderEmail, "user"));
                            await Blacklist.instance.add(BlacklistObject(senderEmail.split("@")[1], "domain"));
                        },
                    ),
                ],
            ),
        );
    }
}