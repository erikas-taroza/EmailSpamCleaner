import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gmail_api_helper.dart' as gmail;
import 'delete_dialog.dart';
import 'emails_list_view.dart';
import 'show_snackbar.dart';

class MultiDeleteButton extends StatefulWidget
{
    const MultiDeleteButton(this.disabled, {Key? key}) : super(key: key);

    final bool disabled;

    @override
    State<StatefulWidget> createState() => MultiDeleteButtonState();
}

class MultiDeleteButtonState extends State<MultiDeleteButton> with TickerProviderStateMixin
{
    static const Duration _animDuration = Duration(milliseconds: 200);

    late OverlayEntry _overlayEntry;
    late final AnimationController _animController = AnimationController(
        vsync: this,
        duration: _animDuration,
    );
    late final Animation<double> _scaleAnim = CurvedAnimation(
        parent: _animController,
        curve: Curves.fastOutSlowIn
    );

    OverlayEntry _createOverlay()
    {
        RenderBox o = context.findRenderObject()! as RenderBox;
        Offset offset = o.localToGlobal(Offset.zero);
        Size size = o.size;

        return OverlayEntry(
            builder: (_) => Positioned(
                left: offset.dx,
                top: offset.dy + size.height - 2,
                child: SizeTransition(
                    sizeFactor: _scaleAnim,
                    axis: Axis.vertical,
                    child: Container(
                        height: 35 * 3,
                        width: 172,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                            color: Colors.red
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                Expanded(
                                    child: TextButton(
                                        style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.red),
                                        child: const Text("Delete 1"),
                                        onPressed: () {},
                                    ),
                                ),
                                Expanded(
                                    child: TextButton(
                                        style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.red),
                                        child: const Text("Delete 2"),
                                        onPressed: () {},
                                    ),
                                ),
                                Expanded(
                                    child: TextButton(
                                        style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.red),
                                        child: const Text("Delete 3"),
                                        onPressed: () {},
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) 
    {
        return SizedBox(
            height: 35,
            width: 172,
            child: Row(
                children: [
                    SizedBox(
                        height: 35,
                        width: 150,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text("Delete"),
                            onPressed: widget.disabled ? 
                                null : 
                                () async {
                                    DeleteDialog.show(
                                        context, 
                                        "Doing this will permanently delete all the blacklisted emails which is irreversible.\n\nAre you sure?", 
                                        () async {
                                            await gmail.deleteEmails();
                                            EmailsListView.state.value = EmailViewState.refresh;
                                            ShowSnackBar.show(context, "Successfully deleted blacklisted emails!", color: Colors.green);
                                        },
                                    );
                                }
                            ,
                        ),
                    ),
                    const SizedBox(width: 2),
                    Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                            height: 35,
                            width: 20,
                            child: ObxValue(
                                (RxBool show) => ElevatedButton(
                                    style: ElevatedButton.styleFrom(primary: Colors.red, padding: const EdgeInsets.only(left: 1)),
                                    child: Text(!show.value ? "▼" : "▲", style: const TextStyle(fontSize: 10)),
                                    onPressed: widget.disabled ? 
                                        null 
                                        : () async {
                                            show.value = !show.value;
                                            try
                                            {
                                                if(show.value == false)
                                                {
                                                    _animController.reverse();
                                                    await Future.delayed(_animDuration);
                                                    _overlayEntry.remove();
                                                }
                                                else 
                                                { 
                                                    _overlayEntry = _createOverlay();
                                                    Overlay.of(context)!.insert(_overlayEntry);
                                                    _animController.forward();
                                                }
                                            }
                                            catch(e) { }
                                        }
                                    ,
                                ),
                                false.obs
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}