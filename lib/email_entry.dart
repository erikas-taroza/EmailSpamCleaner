import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EmailEntry extends StatelessWidget
{
    EmailEntry(this.sender, this.subject, this.snippet, {Key? key}) : super(key: key);

    String sender = "Sender";
    String subject = "Subject";
    String snippet = "Snippet";

    @override
    Widget build(BuildContext context) 
    {
        print(subject);

        return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10, top: 10),
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
                        icon: const Icon(Icons.add),
                        onPressed: (){},
                    ),
                ],
            ),
        );
    }
}