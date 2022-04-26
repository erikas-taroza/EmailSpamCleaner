import 'package:flutter/material.dart';

import 'email_entry.dart';

class EmailsListView extends StatelessWidget
{
    const EmailsListView(this._emails, {Key? key}) : super(key: key);

    final List<EmailEntry> _emails;

    @override
    Widget build(BuildContext context) 
    {
        ScrollController sc = ScrollController();

        return Expanded(
            child: Column(
                children: [
                    const Text("Emails Found", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Expanded(
                        child: ListView.separated(
                            controller: sc,
                            itemCount: _emails.length,
                            itemBuilder: (context, index) {
                                if(_emails.isEmpty) return Container();
    
                                return _emails[index];
                            },
                            separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey)
                        ),
                    )
                ],
            ),
        );
    }

}