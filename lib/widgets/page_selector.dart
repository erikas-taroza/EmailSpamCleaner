import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../gmail_api_helper.dart' as gmail;
import 'emails_list_view.dart';

///Widget that allows the user to move between pages of emails.
class PageSelector extends StatefulWidget
{
    const PageSelector(this.onPageChanged, {Key? key}) : super(key: key);

    final Function(int, bool) onPageChanged;

    @override
    State<StatefulWidget> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector>
{
    int pageNumber = 0;
    int loadingPage = -1;
    bool isLoadingPage = false;
    
    bool get canGoNext { return !(pageNumber == loadingPage) || !isLoadingPage; }

    @override
    void initState()
    {
        super.initState();
        EmailsListView.state.listen((val) {
            if(val == EmailViewState.pageChange || val == EmailViewState.loading)
            {
                isLoadingPage = true;
                loadingPage = pageNumber;
            }
            else if(val == EmailViewState.found)
            {
                isLoadingPage = false;
                loadingPage = -1;
            }
        });
    }

    @override
    Widget build(BuildContext context) 
    {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                //Previous page button.
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: pageNumber != 0 ? () {
                        setState(() => pageNumber--);
                        widget.onPageChanged(pageNumber, canGoNext);
                    } : null,
                ),

                //Page number and loading ring.
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text((pageNumber + 1).toString()),
                        !canGoNext ? const Padding(
                            padding: EdgeInsets.only(left: 5, top: 3),
                            child: SpinKitRing(
                                color: Colors.blue,
                                lineWidth: 2,
                                size: 12,
                            ),
                        ) : Container()
                    ],
                ),

                //Next page button.
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: canGoNext && (gmail.lastPageNumber != pageNumber) ? () {
                        setState(() => pageNumber++);
                        widget.onPageChanged(pageNumber, canGoNext);
                    } : null,
                ),
            ],
        );
    }
}