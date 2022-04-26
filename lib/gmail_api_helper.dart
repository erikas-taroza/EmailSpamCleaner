import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' as convert;

import 'models/blacklist_object.dart';
import 'blacklist_helper.dart';

late UsersResource? _user;
List<Message> _messages = [];

///Login to the Gmail API.
Future<void> login() async
{
    void _prompt(String url) => launchUrlString(url);

    final client = await clientViaUserConsent(
        await _getClient(),  
        ["https://mail.google.com/"], 
        _prompt
    );

    GmailApi gmailApi = GmailApi(client);
    _user = gmailApi.users;
}

//Gets the client information from a json file.
Future<ClientId> _getClient() async
{
    String json = await rootBundle.loadString("assets/client.json");
    var data = convert.jsonDecode(json)["installed"];

    return ClientId(data["client_id"], data["client_secret"]);
}

void logout()
{
    _user = null;
    _messages.clear();
}

///Reads the user's emails and returns a list of emails containing message ID, labels, and headers.
Future<List<Message>> readEmails() async
{
    ListMessagesResponse emails = await _user!.messages.list("me", includeSpamTrash: false, maxResults: 10);
    List<Message> ids = emails.messages!;
    List<Message> messages = [];

    for(Message id in ids)
    {
        messages.add(await _user!.messages.get("me", id.id!, format: "metadata"));
    }

    _messages = messages;
    return messages;
}

///Batch deletes emails based on the blacklist values.
Future<void> deleteEmails() async 
{
    if(_messages.isEmpty) return;

    List<String> idsToDelete = [];

    for(Message message in _messages)
    {
        String sender = message.payload!.headers!.where((element) => element.name == "From").first.value!;
        
        for(BlacklistObject item in Blacklist.instance.blacklist)
        {
            if(!sender.contains(item.value)) continue;

            idsToDelete.add(message.id!);
        }
    }

    await _user!.messages.batchDelete(BatchDeleteMessagesRequest(ids: idsToDelete), "me");
}