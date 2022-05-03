import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../blacklist_helper.dart';
import '../models/blacklist_object.dart';

///Widget that displays the blacklist.
class BlacklistView extends StatefulWidget
{
    const BlacklistView({Key? key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => _BlacklistViewState();
}

class _BlacklistViewState extends State<BlacklistView>
{
    String searchInput = "";
    RxList<BlacklistObject> blacklist = Blacklist.instance.blacklist;
    List<int> searchIndicies = [];
    List<BlacklistObject> searchObjects = [];

    //Shows the dialog for adding a blacklist value manually.
    void showAddBlacklistDialog(BuildContext context)
    {
        String value = "";

        showDialog(
            context: context,
            builder: (c) => AlertDialog(
                title: const Text("Add to Blacklist"),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text("Input should be in either format:\n"),
                        const Text("user@domain.com"),
                        const Text("domain.com\n"),
                        TextField(
                            decoration: const InputDecoration(hintText: "Value"),
                            onChanged: (text) => value = text,
                        ),
                    ],
                ),
                actions: [
                    TextButton(
                        child: const Text("CANCEL"),
                        onPressed: () => Navigator.of(c).pop(),
                    ),
                    TextButton(
                        child: const Text("ADD"),
                        onPressed: () async {
                            await Blacklist.instance.addString(value);
                            Navigator.of(c).pop();
                        },
                    )
                ],
            )
        );
    }

    bool search()
    {
        if(searchInput != "")
        {
            searchIndicies.clear();
            searchObjects.clear();
            
            for(int i = 0; i < blacklist.length; i++)
            {
                BlacklistObject obj = blacklist[i];

                //Explicit search with !
                if(searchInput[0] == "!" && obj.value == searchInput.substring(1)) 
                { 
                    searchIndicies.add(i);
                    searchObjects.add(obj);
                }
                else if(!obj.value.contains(searchInput)) { continue; }
                else 
                { 
                    searchIndicies.add(i);
                    searchObjects.add(obj); 
                }
            }

            return true;
        }

        return false;
    }

    @override
    Widget build(BuildContext context)
    {
        ScrollController sc = ScrollController();

        return Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        _Header((text) => setState(() => searchInput = text)),
                        const SizedBox(height: 10),
                        Expanded(
                            child: Obx(() { //Observe the blacklist list.
                                bool searched = search();

                                return ListView.builder(
                                    controller: sc,
                                    itemCount: searched ? searchIndicies.length : blacklist.length,
                                    itemBuilder: (context, index) {
                                        String value = searched ? searchObjects[index].value : blacklist[index].value;
                                        String type = searched ? searchObjects[index].type : blacklist[index].type;

                                        //Build the list item for the blacklist item.
                                        return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    //The domain / user.
                                                    Expanded(
                                                        child: Tooltip(
                                                            message: value + " ($type)",
                                                            waitDuration: const Duration(milliseconds: 500),
                                                            child: Text(
                                                                value,
                                                                style: const TextStyle(fontSize: 16),
                                                                overflow: TextOverflow.ellipsis,
                                                            ),
                                                        ),
                                                    ),
                                                    Row(
                                                        children: [
                                                            Text(
                                                                " ($type)",
                                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                            ),

                                                            //Remove from blacklist button.
                                                            IconButton(
                                                                icon: const Icon(Icons.person_remove),
                                                                onPressed: () async {
                                                                    if(!searched) { await Blacklist.instance.remove(index); }
                                                                    else { await Blacklist.instance.remove(searchIndicies[index]); }
                                                                },
                                                            ),
                                                        ]
                                                    ),
                                                ],
                                            ),
                                        );
                                    }
                                );
                            })
                        ),
                        SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                                child: const Text("Add to Blacklist"),
                                onPressed: () => showAddBlacklistDialog(context),
                            ),
                        )
                    ],
                ),
            ),
        );
    }
}

///Widget that displays the header for the blacklist view and a searchbar.
class _Header extends StatefulWidget
{
    const _Header(this.onSearchSubmitted);

    final void Function(String) onSearchSubmitted;

    @override
    State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with SingleTickerProviderStateMixin
{
    late final AnimationController iconController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animationDuration.inMilliseconds + 300)
    );
    
    late final Animation<double> iconAnimation = CurvedAnimation(
        curve: Curves.easeInOut, parent: iconController
    );

    final Duration animationDuration = const Duration(milliseconds: 200);
    final TextEditingController textFieldController = TextEditingController();

    final double maxSize = 430 - 56; //Approximate width of the blacklist view.
    bool showTextField = false;

    @override
    Widget build(BuildContext context) 
    {
        return SizedBox(
            height: 25,
            child: Stack(
                alignment: Alignment.center,
                children: [
                    //Title
                    const Text("Blacklisted Senders", style: TextStyle(fontSize: 18)),
                    //Search text input field.
                    Padding(
                        padding: const EdgeInsets.only(right: 56),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedContainer(
                                duration: animationDuration,
                                curve: Curves.linear,
                                color: Theme.of(context).canvasColor,
                                width: showTextField ? maxSize : 0,
                                child: TextField(
                                    controller: textFieldController,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 16)
                                    ),
                                    onSubmitted: (text) => widget.onSearchSubmitted(text),
                                ),
                            ),
                        ),
                    ),
                    //Button to toggle search bar.
                    Align(
                        alignment: Alignment.centerRight,
                        child: RotationTransition(
                            turns: iconAnimation,
                            child: IconButton(
                                icon: AnimatedSwitcher(
                                    duration: animationDuration,
                                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                    child: showTextField ? 
                                        const Icon(Icons.close, key: ValueKey("1")) 
                                        : const Icon(Icons.search, key: ValueKey("2")),
                                ),
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                    setState(() => showTextField = !showTextField);
                                    textFieldController.clear();
                                    widget.onSearchSubmitted("");
                                    showTextField ? iconController.forward() : iconController.reverse();
                                },
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}