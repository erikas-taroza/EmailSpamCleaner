import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'models/blacklist_object.dart';

class Blacklist
{
    static final Blacklist instance = Blacklist._();
    Blacklist._();

    Future<File> get _file async
    {
        Directory dir = await getApplicationSupportDirectory();
        return File(dir.path + "/blacklist.json");
    }

    void add(BlacklistObject obj) async
    {
        File file = await _file;
        file.writeAsString(obj.toString() + "\n", mode: FileMode.append);
    }

    void addString(String value)
    {
        if(value.contains("@")) { add(BlacklistObject(value, "user")); }
        else if(value.contains(".")) { add(BlacklistObject(value, "domain")); }
    }

    void remove(int id) async
    {
        File file = await _file;
        List<String> lines = await file.readAsLines();
        lines.removeAt(id);
        file.writeAsString(lines.join("\n"));
    }

    Future<List<BlacklistObject>> getAll() async
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