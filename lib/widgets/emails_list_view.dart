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
    static final Map<int, List<EmailEntry>> _emails = <int, List<EmailEntry>>{}.obs;
    static final RxInt _pageNumber = 0.obs;

    ///Gets the emails from the api helper and creates widgets used for display.
    static Future<void> getEmailsAsEntries({int page = 0}) async
    {
        List<Message> newEmails = [];
        if(page == 0)
        {
            newEmails = await gmail.readEmails("");
        }
        else
        {
            newEmails = await gmail.readEmails(gmail.messages.keys.elementAt(page - 1)); 
        }

        if(_emails[page] == null)
        {
            _emails[page] = [];
            for (Message email in newEmails) 
            {
                _emails[page]!.add(
                    EmailEntry(
                        email.payload!.headers!.where((element) => element.name == "From").first.value!, 
                        email.payload!.headers!.where((element) => element.name == "Subject").first.value!,
                        email.snippet!
                    )
                );
            }
        }
    }

    Future<void> onPageChanged(int value) async
    {
        if(_emails[value] == null)
        {
            state.value == EmailViewState.pageChange;
            await getEmailsAsEntries(page: value);
            state.value == EmailViewState.found;
        }

        _pageNumber.value = value;
    }

    @override
    Widget build(BuildContext context) 
    {
        ScrollController sc = ScrollController();

        return Expanded(
            child: Column(
                children: [
                    const Text("Emails Found", style: TextStyle(fontSize: 18)),
                    Obx(() => state.value == EmailViewState.found ? const SizedBox(height: 10) : Container()),
                    Obx(
                        () {
                            if(state.value == EmailViewState.loading || state.value == EmailViewState.pageChange)
                            {
                                return const Expanded(child: Center(child: SpinKitRing(color: Colors.black, lineWidth: 5)));
                            }
                            else if(state.value == EmailViewState.refresh)
                            {
                                return Expanded(
                                    child: Center(
                                        child: ElevatedButton(
                                            child: const Text("REFRESH", style: TextStyle(color: Colors.blue)),
                                            onPressed: () async {
                                                state.value = EmailViewState.loading;
                                                await getEmailsAsEntries();
                                                state.value = EmailViewState.found;
                                            },
                                            style: ElevatedButton.styleFrom(primary: Colors.white),
                                        ),
                                    ),
                                );
                            }
                            else if(state.value == EmailViewState.found)
                            {
                                if(_emails.isEmpty) return Container();

                                List<EmailEntry> entries = _emails[_pageNumber.value]!;

                                return Expanded(
                                    child: ListView.separated(
                                        controller: sc,
                                        itemCount: entries.length,
                                        itemBuilder: (context, index) {
                                            return entries[index];
                                        },
                                        separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                                    ),
                                );
                            }
                            else { return Container(); }
                        }
                    ),
                    Obx(
                        () {
                            if(state.value == EmailViewState.found || state.value == EmailViewState.pageChange)
                            {
                                return PageSelector((value) async => await onPageChanged(value));
                            }
                            else { return Container(); }
                        }
                    )
                ],
            ),
        );
    }
}

enum EmailViewState
{
    none,
    found,
    loading,
    refresh,
    pageChange
}