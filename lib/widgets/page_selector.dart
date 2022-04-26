import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../gmail_api_helper.dart' as gmail;
import 'emails_list_view.dart';

class PageSelector extends StatefulWidget
{
    const PageSelector(this.onPageChanged, {Key? key}) : super(key: key);

    final Function(int, bool) onPageChanged;

    @override
    State<StatefulWidget> createState() => PageSelectorState();
}

class PageSelectorState extends State<PageSelector>
{
    int _pageNumber = 0;
    int _loadingPage = -1;
    bool _isLoadingPage = false;
    
    bool get canGoNext { return !(_pageNumber == _loadingPage) || !_isLoadingPage; }

    @override
    void initState()
    {
        super.initState();
        EmailsListView.state.listen((val) {
            if(val == EmailViewState.pageChange || val == EmailViewState.loading)
            {
                _isLoadingPage = true;
                _loadingPage = _pageNumber;
            }
            else if(val == EmailViewState.found)
            {
                _isLoadingPage = false;
                _loadingPage = -1;
            }
        });
    }

    @override
    Widget build(BuildContext context) 
    {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _pageNumber != 0 ? () {
                        setState(() => _pageNumber--);
                        widget.onPageChanged(_pageNumber, canGoNext);
                    } : null,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text((_pageNumber + 1).toString()),
                        !canGoNext ? const Padding(
                            padding: EdgeInsets.only(left: 5, top: 3),
                            child: SpinKitRing(
                                color: Colors.black,
                                lineWidth: 2,
                                size: 12,
                            ),
                        ) : Container()
                    ],
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: canGoNext && !gmail.isLastPage ? () {
                        setState(() => _pageNumber++);
                        widget.onPageChanged(_pageNumber, canGoNext);
                    } : null,
                ),
            ],
        );
    }
}