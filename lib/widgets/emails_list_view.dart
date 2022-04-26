import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/gmail/v1.dart';

import '../gmail_api_helper.dart' as gmail;
import 'email_entry.dart';

class EmailsListView extends StatelessWidget
{
    const EmailsListView({Key? key}) : super(key: key);

    static final RxList<EmailEntry> _emails = <EmailEntry>[].obs;

    ///Gets the emails from the api helper and creates widgets used for display.
    static Future<void> getEmailsAsEntries() async
    {
        List<Message> newEmails = await gmail.readEmails();

        for (Message email in newEmails) 
        {
            _emails.add(
                EmailEntry(
                    email.payload!.headers!.where((element) => element.name == "From").first.value!, 
                    email.payload!.headers!.where((element) => element.name == "Subject").first.value!,
                    email.snippet!
                )
            );
        }
    }

    @override
    Widget build(BuildContext context) 
    {
        ScrollController sc = ScrollController();

        return Expanded(
            child: Column(
                children: [
                    const Text("Emails Found", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Obx(
                            () => ListView.separated(
                                controller: sc,
                                itemCount: _emails.length,
                                itemBuilder: (context, index) {
                                    if(_emails.isEmpty) return Container();
                            
                                    return _emails[index];
                                },
                                separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                            ),
                        ),
                    )
                ],
            ),
        );
    }

}