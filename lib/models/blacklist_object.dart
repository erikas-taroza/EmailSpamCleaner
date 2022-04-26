import 'package:json_annotation/json_annotation.dart';

part 'blacklist_object.g.dart';

@JsonSerializable()
class BlacklistObject
{
    String value;
    String type;

    ///[value] The user or domain to blacklist.
    ///
    ///[type] The type of value. Either "user" or "domain".
    BlacklistObject(this.value, this.type);

    factory BlacklistObject.fromJson(Map<String, dynamic> json) => _$BlacklistObjectFromJson(json);
    Map<String, dynamic> toJson() => _$BlacklistObjectToJson(this);

    @override
    String toString()
    {
        Map<String, dynamic> json = toJson();
        return "{\"value\": \"${json["value"]}\", \"type\": \"${json["type"]}\"}";
    }

    @override
    bool operator ==(other) => other is BlacklistObject && value == other.value && type == other.type;

    @override
    int get hashCode => Object.hash(value, type);
}