import 'package:flutter/material.dart';

class PageSelector extends StatefulWidget
{
    const PageSelector(this.onPageChanged, {Key? key}) : super(key: key);

    final Function(int) onPageChanged;

    @override
    State<StatefulWidget> createState() => PageSelectorState();
}

class PageSelectorState extends State<PageSelector>
{
    int _pageNumber = 0;

    @override
    Widget build(BuildContext context) 
    {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                        if(_pageNumber == 0) return;
                        setState(() => _pageNumber--);
                        widget.onPageChanged(_pageNumber);
                    },
                ),
                Text((_pageNumber + 1).toString()),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                        setState(() => _pageNumber++);
                        widget.onPageChanged(_pageNumber);
                    },
                ),
            ],
        );
    }
}