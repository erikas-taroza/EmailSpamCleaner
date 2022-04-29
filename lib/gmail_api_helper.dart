import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'models/blacklist_object.dart';
import 'blacklist_helper.dart';

int get lastPageId
{ 
    if(messages.isEmpty) return -1;

    //If we reached the last page or if the first page is the last page.
    if(messages.keys.last == "last" || messages.keys.last == "")
    {
        return messages.keys.length - 1;
    }
    else { return -1; }
}

Map<String, List<Message>> messages = <String, List<Message>>{};

late UsersResource? _user;

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
    var data = jsonDecode(json)["installed"];

    return ClientId(data["client_id"], data["client_secret"]);
}

void logout()
{
    _user = null;
    messages.clear();
}

///Returns the IDs and data of blacklisted emails.
Map<String, Message> getBlacklistedEmails()
{
    Map<String, Message> emails = <String, Message>{};

    for(List<Message> page in messages.values)
    {
        for(Message message in page)
        {
            String sender = message.payload!.headers!.where((element) => element.name == "From").first.value!;
            
            for(BlacklistObject item in Blacklist.instance.blacklist)
            {
                if(!sender.contains(item.value)) continue;

                emails[message.id!] = message;
            }
        }
    }

    return emails;
}

///Reads the user's emails and returns a list of emails containing message ID, labels, and headers.
Future<List<Message>> readEmails(String pageToken) async
{
    ListMessagesResponse emails = await _user!.messages.list(
        "me", 
        includeSpamTrash: false, 
        maxResults: 300, 
        labelIds: ["INBOX"], 
        pageToken: pageToken
    );
    List<Message> ids = emails.messages!;
    List<Message> _messages = [];

    for(Message id in ids)
    {
        _messages.add(await _user!.messages.get("me", id.id!, format: "full"));
    }

    if(emails.nextPageToken == null) { messages["last"] = _messages; }
    else { messages[emails.nextPageToken!] = _messages; }
    
    return _messages;
}

///Batch deletes emails based on the blacklist values.
Future<void> deleteEmails() async 
{
    if(messages.isEmpty) return;

    List<String> ids = getBlacklistedEmails().keys.toList();
    if(ids.isEmpty) return;

    if(ids.length > 1000)
    {
        for(int i = 0; i < ids.length / 1000; i++)
        {
            int endIndex = 0;
            if(i == ids.length ~/ 1000) { endIndex = ids.length - 1; }
            else { endIndex = 1000 + (i * 1000) - 1; }
            
            await _user!.messages.batchDelete(BatchDeleteMessagesRequest(ids: ids.getRange(i *  1000, endIndex).toList()), "me");
        }
    }
    else
    {
        await _user!.messages.batchDelete(BatchDeleteMessagesRequest(ids: ids), "me");
    }   
}

///Unsubscribes from every blacklisted email if possible.
Future<void> unsubscribeEmails() async
{
    if(messages.isEmpty) return;

    List<String> usedSenders = [];
    Map<String, Message> emails = getBlacklistedEmails();
    
    for(String key in emails.keys)
    {
        Message email = emails[key]!;
        String url = "";
        String sender = email.payload!.headers!.where((element) => element.name == "From").first.value!;

        if(usedSenders.contains(sender)) continue;

        Iterable<MessagePartHeader> unsubHeader = email.payload!.headers!.where((element) => element.name == "List-Unsubscribe");
        if(unsubHeader.isNotEmpty && !unsubHeader.first.value!.contains("mailto"))
        {
            url = unsubHeader.first.value!.split("<")[1].split(">")[0];
        }
        else
        {
            MessagePart payload = email.payload!;
            String b64 = "";
            String plain = "";
            //If the payload doesn't have any parts, then that means all the information is in the body.
            if(payload.parts != null)
            {
                b64 = payload.parts!.where((element) => element.mimeType == "text/html").first.body!.data!;
                plain = utf8.decode(base64.decode(b64));
            }
            else
            {
                b64 = payload.body!.data!;
                plain = utf8.decode(base64.decode(b64));
            }

            //Parse the html code to find the unsubscribe url.
            List<String> split = plain.split("nsubscribe");
            //In case there is no unsubscribe link found.
            if(split.length == 1) continue;

            RegExp regex = RegExp(r"(href)", caseSensitive: false);
            String href = regex.allMatches(split[0]).last.group(0)!;
            String _url = split[0].split("$href=\"").last.split(" ")[0];

            //This means that the url was cutoff. 
            if(_url[_url.length - 1] != "\"")
            {
                _url += plain.split(_url)[1].split(" ")[0];
            }

            url = _url.substring(0, _url.length - 1);
        }

        if(url == "") return;
        
        usedSenders.add(sender);
        await launchUrlString(url);
    }
}