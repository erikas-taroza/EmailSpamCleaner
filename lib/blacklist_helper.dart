import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'models/blacklist_object.dart';

class Blacklist
{
    static final Blacklist instance = Blacklist._();
    Blacklist._();

    List<BlacklistObject> blacklist = [];

    Future<File> get _file async
    {
        Directory dir = await getApplicationSupportDirectory();
        return File(dir.path + "/blacklist.json");
    }

    Future<void> add(BlacklistObject obj) async
    {
        File file = await _file;
        file.writeAsString(obj.toString() + "\n", mode: FileMode.append);

        blacklist.insert(0, obj);
    }

    Future<void> addString(String value) async
    {
        if(value.contains("@")) { await add(BlacklistObject(value, "user")); }
        else if(value.contains(".")) { await add(BlacklistObject(value, "domain")); }
    }

    Future<void> remove(int id) async
    {
        File file = await _file;
        List<String> lines = await file.readAsLines();
        lines.removeAt(lines.length - 1 - id == -1 ? 0 : lines.length - 1 - id);
        file.writeAsString(lines.join("\n"));

        blacklist.removeAt(id);
    }

    Future<List<BlacklistObject>> retrieve() async
    {
        try
        {
            File file = await _file;
            List<String> lines = await file.readAsLines();
            List<BlacklistObject> objs = [];
            
            if(lines.isEmpty) return [];

            for (String data in lines) 
            {
                objs.add(BlacklistObject.fromJson(jsonDecode(data)));
            }

            return objs.reversed.toList();
        }
        catch (e) { return []; }
    }
}