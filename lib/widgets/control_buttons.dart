import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gmail_api_helper.dart' as gmail;
import 'emails_list_view.dart';
import 'multi_delete_button.dart';
import 'show_snackbar.dart';
import 'delete_dialog.dart';

class ControlButtons extends StatefulWidget
{
    const ControlButtons({Key? key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => ControlButtonsState();
}

class ControlButtonsState extends State<ControlButtons>
{
    RxBool loggedIn = false.obs;

    Future<void> loginButtonClick(BuildContext context) async
    {
        if(!loggedIn.value)
        {
            await gmail.login().then(
                (value) async {
                    ShowSnackBar.show(context, "Login was successful! You can now find, unsubscribe from, and delete emails.", color: Colors.green);
                    
                    EmailsListView.state.value = EmailViewState.loading;
                    await EmailsListView.getEmailsAsEntries();
                    EmailsListView.state.value = EmailViewState.found;
                }
            );
            loggedIn.value = true;
        }
        else
        {
            gmail.logout();
            EmailsListView.state.value = EmailViewState.none;
            EmailsListView.emails.clear();
            loggedIn.value = false;
        }
    }

    @override
    Widget build(BuildContext context) 
    {
        return Obx(
            () { 
                bool disableState = EmailsListView.state.value == EmailViewState.loading || EmailsListView.state.value == EmailViewState.pageChange || EmailsListView.state.value == EmailViewState.refresh;
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        SizedBox(
                            child: ElevatedButton(
                                child: Text(!loggedIn.value ? "Login" : "Logout"),
                                onPressed: EmailsListView.state.value == EmailViewState.loading || EmailsListView.state.value == EmailViewState.pageChange ?
                                    null :
                                    () async => await loginButtonClick(context)
                                ,
                            ),
                            height: 35,
                            width: 150
                        ),

                        SizedBox(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(primary: Colors.red),
                                child: const Text("Unsubscribe"),
                                onPressed: !loggedIn.value || disableState ?
                                    null : 
                                    () async {
                                        DeleteDialog.show(
                                            context, 
                                            "Doing this will unsubscribe you from all the blacklisted emails which may be irreversible.\n\nAre you sure?", 
                                            () async {
                                                await gmail.unsubscribeEmails();
                                                ShowSnackBar.show(context, "Successfully unsubscribed from blacklisted emails!", color: Colors.green);
                                            },
                                            deleteButtonText: "UNSUBSCRIBE",
                                        );
                                    }
                                ,
                            ),
                            height: 35,
                            width: 150
                        ),
                        MultiDeleteButton(!loggedIn.value || disableState)
                    ],
                );
            }
        );
    }
    
}