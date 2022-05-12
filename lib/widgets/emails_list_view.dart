import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:googleapis/gmail/v1.dart';

import '../gmail_api_helper.dart' as gmail;
import 'email_entry.dart';
import 'page_selector.dart';

class EmailsListView extends StatelessWidget
{
    const EmailsListView({Key? key}) : super(key: key);

    static final Rx<EmailViewState> state = EmailViewState.none.obs;
    static final Map<int, List<EmailEntry>> emails = <int, List<EmailEntry>>{}.obs;
    static final RxInt _pageNumber = 0.obs;
    static final RxBool _canGoNext = true.obs;

    ///Gets the emails from the api helper and creates widgets used for display.
    static Future<void> getEmailsAsEntries({int page = 0}) async
    {
        List<Message> newEmails = [];
        if(page == 0) { newEmails = await gmail.readInboxEmails(""); } //Leave the next page token blank on page 0.
        else { newEmails = await gmail.readInboxEmails(gmail.messages.keys.elementAt(page - 1)); }

        if(emails[page] == null) emails[page] = [];

        if(emails[page]!.isNotEmpty) emails[page]!.clear();

        for (Message email in newEmails) 
        {
            String sender = "";
            String subject = "";
            String snippet = "";

            try { sender = email.payload!.headers!.where((element) => element.name == "From").first.value!; } catch(e) { sender = ""; }
            try { subject = email.payload!.headers!.where((element) => element.name == "Subject").first.value!; } catch(e) { subject = ""; }
            try { snippet = email.snippet!; } catch(e) { snippet = ""; }

            emails[page]!.add(
                EmailEntry(
                    sender,
                    subject,
                    snippet
                )
            );
        }
    }

    Future<void> _onPageChanged(int value, bool canGoNext) async
    {
        //This code only runs when a new page is loaded.
        if(emails[value] == null)
        {
            _canGoNext.value = false;
            emails[value] = [];
            _setViewState(EmailViewState.pageChange);
            await getEmailsAsEntries(page: value);
            _setViewState(EmailViewState.found);
        }

        _canGoNext.value = canGoNext;
        _pageNumber.value = value;
    }

    //Triggers the listeners when setting the state.
    void _setViewState(EmailViewState state)
    {
        EmailsListView.state.value = state;
        EmailsListView.state.trigger(state);
    }

    @override
    Widget build(BuildContext context) 
    {
        ScrollController sc = ScrollController();

        return Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                    children: [
                        const Text("Emails Found", style: TextStyle(fontSize: 18)),
                        //Spacer
                        Obx(() => state.value == EmailViewState.found || state.value == EmailViewState.pageChange ? 
                            const SizedBox(height: 10) 
                            : Container()),
                        
                        //Body
                        Obx(
                            () {
                                //Display spinner if we are loading.
                                if(state.value == EmailViewState.loading)
                                {
                                    return const Expanded(child: Center(child: SpinKitRing(color: Colors.blue, lineWidth: 5)));
                                }
                                //Display refresh button if we need to refresh.
                                else if(state.value == EmailViewState.refresh)
                                {
                                    return Expanded(
                                        child: Center(
                                            child: ElevatedButton(
                                                child: const Text("REFRESH", style: TextStyle(color: Colors.blue)),
                                                onPressed: () async {
                                                    EmailsListView.emails.clear();

                                                    _setViewState(EmailViewState.loading);
                                                    await getEmailsAsEntries();
                                                    _setViewState(EmailViewState.found);
                                                },
                                                style: ElevatedButton.styleFrom(primary: Colors.white),
                                            ),
                                        ),
                                    );
                                }
                                //Display the emails in a list view.
                                else
                                {
                                    if((emails.isEmpty || emails[0]!.isEmpty) && state.value == EmailViewState.found) 
                                    { return const Expanded(child: Center(child: Text("No emails found."))); }
            
                                    if((state.value == EmailViewState.found || _canGoNext.value) && state.value != EmailViewState.none)
                                    {
                                        List<EmailEntry> entries = emails[_pageNumber.value]!;
                                        return Expanded(
                                            child: ListView.separated(
                                                controller: sc,
                                                itemCount: entries.length,
                                                itemBuilder: (context, index) => entries[index],
                                                separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                                            ),
                                        );
                                    }
                                    else { 
                                        return Expanded(
                                            child: SizedBox(
                                                width: 200,
                                                height: 200,
                                                child: Center(
                                                    child: Image.asset(
                                                        "assets/email_cleaner_logo_plain.png",
                                                        color: Colors.grey[300],
                                                    ),
                                                )
                                            )
                                        );
                                    }
                                }
                            }
                        ),

                        //Page selector.
                        Obx(
                            () {
                                if(state.value == EmailViewState.found || state.value == EmailViewState.pageChange)
                                {
                                    return PageSelector((value, canGoNext) async => await _onPageChanged(value, canGoNext));
                                }
                                else { return Container(); }
                            }
                        ),
                    ],
                ),
            ),
        );
    }
}

///Possible states for the email list view.
enum EmailViewState
{
    none,
    found,
    loading,
    refresh,
    pageChange
}