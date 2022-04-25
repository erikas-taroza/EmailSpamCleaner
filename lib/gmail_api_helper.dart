import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' as convert;

late UsersResource _user;

Future<void> login() async
{
    void _prompt(String url) => launchUrlString(url);

    final client = await clientViaUserConsent(
        await _getClient(),  
        ["https://www.googleapis.com/auth/gmail.modify"], 
        _prompt
    );

    GmailApi gmailApi = GmailApi(client);
    _user = gmailApi.users;
}

Future<ClientId> _getClient() async
{
    String json = await rootBundle.loadString("assets/client.json");
    var data = convert.jsonDecode(json)["installed"];

    return ClientId(data["client_id"], data["client_secret"]);
}

Future<List<Message>> readEmails() async
{
    ListMessagesResponse emails = await _user.messages.list("me", includeSpamTrash: false, maxResults: 10);
    List<Message> ids = emails.messages!;
    List<Message> messages = [];

    for(Message id in ids)
    {
        messages.add(await _user.messages.get("me", id.id!, format: "metadata"));
    }

    return messages;
}