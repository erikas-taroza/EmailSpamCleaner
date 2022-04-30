import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../blacklist_helper.dart';
import '../models/blacklist_object.dart';

class EmailEntry extends StatelessWidget
{
    const EmailEntry(this.sender, this.subject, this.snippet, {Key? key}) : super(key: key);

    final String sender;
    final String subject;
    final String snippet;
    String get senderEmail 
    { 
        if(sender.contains(RegExp(r"(<|>)"))) { return sender.split("<")[1].split(">")[0]; }
        return sender;
    }

    bool _isBlackListed()
    {
        BlacklistObject user = BlacklistObject(senderEmail, "user");
        BlacklistObject domain = BlacklistObject(senderEmail.split("@")[1], "domain");

        if(Blacklist.instance.blacklist.contains(user) || Blacklist.instance.blacklist.contains(domain))
        { return true; }
        else { return false; }
    }

    @override
    Widget build(BuildContext context) 
    {
        Color canvas = Theme.of(context).canvasColor;

        return Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Obx(
                () => Container(
                    decoration: !_isBlackListed() ? null 
                    : BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: const Alignment(-0.9, -0.8),
                            stops: const [0.0, 0.5, 0.5, 1],
                            colors: [Colors.grey.shade300, Colors.grey.shade300, canvas, canvas],
                            tileMode: TileMode.repeated
                        )
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Expanded(
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
                                    await Blacklist.instance.add(BlacklistObject(senderEmail, "user"), auto: true);
                                    await Blacklist.instance.add(BlacklistObject(senderEmail.split("@")[1], "domain"), auto: true);
                                },
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}