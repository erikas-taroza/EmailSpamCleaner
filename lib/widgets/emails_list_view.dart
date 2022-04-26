import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:googleapis/gmail/v1.dart';

import '../gmail_api_helper.dart' as gmail;
import 'email_entry.dart';

class EmailsListView extends StatelessWidget
{
    const EmailsListView({Key? key}) : super(key: key);

    static final RxString state = "".obs;
    static final List<EmailEntry> _emails = <EmailEntry>[].obs;

    ///Gets the emails from the api helper and creates widgets used for display.
    static Future<void> getEmailsAsEntries() async
    {
        List<Message> newEmails = await gmail.readEmails();
        _emails.clear();

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
                    Obx(
                        () => state.value == "" ? const SizedBox(height: 10) : Container()
                    ),
                    Obx(
                        () {
                            if(state.value == "loading")
                            {
                                return const Expanded(child: Center(child: SpinKitRing(color: Colors.black, lineWidth: 5)));
                            }
                            else if(state.value == "refresh")
                            {
                                return Expanded(
                                    child: Center(
                                        child: ElevatedButton(
                                            child: const Text("REFRESH", style: TextStyle(color: Colors.blue)),
                                            onPressed: () async {
                                                state.value = "loading";
                                                await EmailsListView.getEmailsAsEntries();
                                                state.value = "";
                                            },
                                            style: ElevatedButton.styleFrom(primary: Colors.white),
                                        ),
                                    ),
                                );
                            }
                            else
                            {
                                return Expanded(
                                    child: ListView.separated(
                                        controller: sc,
                                        itemCount: _emails.length,
                                        itemBuilder: (context, index) {
                                            if(_emails.isEmpty) return Container();
                                    
                                            return _emails[index];
                                        },
                                        separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                                    ),
                                );
                            }
                        }
                    ),
                ],
            ),
        );
    }

}