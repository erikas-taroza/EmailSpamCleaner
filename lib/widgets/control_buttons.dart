import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gmail_api_helper.dart' as gmail;
import 'emails_list_view.dart';
import 'show_snackbar.dart';

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
                (value) {
                    ShowSnackBar.show("Login was successful! You can now find, unsubscribe from, and delete emails.", context, color: Colors.green);
                }
            );
            loggedIn.value = true;
        }
        else
        {
            gmail.logout();
            loggedIn.value = false;
        }
    }

    @override
    Widget build(BuildContext context) 
    {
        return Obx(
            () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    SizedBox(
                        child: ElevatedButton(
                            child: Text(!loggedIn.value ? "Login" : "Logout"),
                            onPressed: () async => await loginButtonClick(context)
                        ),
                        height: 35,
                        width: 150
                    ),
        
                    SizedBox(
                        child: ElevatedButton(
                            child: const Text("Find Emails"),
                            onPressed: !loggedIn.value ? null : () async => await EmailsListView.getEmailsAsEntries(),
                        ),
                        height: 35,
                        width: 150
                    ),
        
                    SizedBox(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text("Delete"),
                            onPressed: !loggedIn.value ? null : () async {
                                await gmail.deleteEmails();
                            },
                        ),
                        height: 35,
                        width: 150
                    ),
                ],
            ),
        );
    }
    
}