import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gmail_api_helper.dart' as gmail;
import 'emails_list_view.dart';
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
    RxBool foundEmails = false.obs;

    Future<void> loginButtonClick(BuildContext context) async
    {
        if(!loggedIn.value)
        {
            await gmail.login().then(
                (value) {
                    ShowSnackBar.show(context, "Login was successful! You can now find, unsubscribe from, and delete emails.", color: Colors.green);
                }
            );
            loggedIn.value = true;
        }
        else
        {
            gmail.logout();
            loggedIn.value = false;
            foundEmails.value = false;
        }
    }

    @override
    Widget build(BuildContext context) 
    {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Obx(
                    () => SizedBox(
                        child: ElevatedButton(
                            child: Text(!loggedIn.value ? "Login" : "Logout"),
                            onPressed: () async => await loginButtonClick(context)
                        ),
                        height: 35,
                        width: 150
                    ),
                ),
    
                Obx(
                    () => SizedBox(
                        child: ElevatedButton(
                            child: const Text("Find Emails"),
                            onPressed: !loggedIn.value ? null : () async {
                                EmailsListView.state.value = EmailViewState.loading;
                                await EmailsListView.getEmailsAsEntries();
                                EmailsListView.state.value = EmailViewState.found;
                                foundEmails.value = true;
                            },
                        ),
                        height: 35,
                        width: 150
                    ),
                ),

                Obx(
                    () => SizedBox(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text("Unsubscribe"),
                            onPressed: !foundEmails.value ? null : () async {
                                DeleteDialog.show(
                                    context, 
                                    "Doing this will unsubscribe you from all the blacklisted emails which may be irreversible.\n\nAre you sure?", 
                                    () async {
                                        await gmail.unsubscribeEmails();
                                        ShowSnackBar.show(context, "Successfully unsubscribed from blacklisted emails!", color: Colors.green);
                                    },
                                    deleteButtonText: "UNSUBSCRIBE",
                                );
                            },
                        ),
                        height: 35,
                        width: 150
                    ),
                ),
    
                Obx(
                    () => SizedBox(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text("Delete"),
                            onPressed: !foundEmails.value ? null : () async {
                                DeleteDialog.show(
                                    context, 
                                    "Doing this will permanently delete all the blacklisted emails which is irreversible.\n\nAre you sure?", 
                                    () async {
                                        await gmail.deleteEmails();
                                        EmailsListView.state.value = EmailViewState.refresh;
                                        ShowSnackBar.show(context, "Successfully deleted blacklisted emails!", color: Colors.green);
                                    },
                                );
                            },
                        ),
                        height: 35,
                        width: 150
                    ),
                ),
            ],
        );
    }
    
}