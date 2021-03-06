import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import 'models/blacklist_object.dart';

class Blacklist
{
    static final Blacklist instance = Blacklist._();
    Blacklist._();

    //These domains should not be added automatically because they are from popular email services.
    static const serviceDomains = ["gmail.com", "outlook.com", "hotmail.com", "yahoo.com", "aol.com", "protonmail.com"];
    
    //Observed blacklist using Get package.
    RxList<BlacklistObject> blacklist = <BlacklistObject>[].obs;

    Future<File> get _file async
    {
        Directory dir = await getApplicationSupportDirectory();
        return File(dir.path + "/blacklist.json");
    }

    ///[obj] The [BlacklistObject] to add to the database.
    ///[auto] If the object was added automatically.
    Future<void> add(BlacklistObject obj, {bool auto = false}) async
    {
        if(obj.type == "domain" && serviceDomains.contains(obj.value) && auto) return;
        if(!blacklist.contains(obj))
        {
            File file = await _file;
            await file.writeAsString(obj.toString() + "\n", mode: FileMode.append);

            blacklist.insert(0, obj);
        }
    }

    ///Creates a [BlacklistObject] from the given value and adds it to the database.
    ///
    ///[value] The string to create a [BlacklistObject] from.
    Future<void> addString(String value) async
    {
        if(value.contains("@")) { await add(BlacklistObject(value, "user")); }
        else if(value.contains(".")) { await add(BlacklistObject(value, "domain")); }
    }

    ///[id] The id to remove a [BlacklistObject] from the database.
    Future<void> remove(int id) async
    {
        File file = await _file;
        List<String> lines = await file.readAsLines();
        lines.removeAt(lines.length - 1 - id == -1 ? 0 : lines.length - 1 - id);

        //For some reason, using lines.join("\n") doesn't work and messes up the json.
        String data = "";
        for(String str in lines)
        {
            data += str + "\n";
        }
        await file.writeAsString(data);

        blacklist.removeAt(id);
    }

    ///Gets the blacklist from the json database.
    /// 
    ///This should only be called once when creating the singleton.
    Future<List<BlacklistObject>> retrieve() async
    {
        try
        {
            File file = await _file;
            List<String> lines = await file.readAsLines();
            List<BlacklistObject> objs = [];
            
            if(lines.isEmpty) return [];

            for (String data in lines.reversed) 
            {
                BlacklistObject obj = BlacklistObject.fromJson(jsonDecode(data));
                objs.add(obj);
                blacklist.add(obj);
            }

            return objs;
        }
        catch (e) { return []; }
    }
}