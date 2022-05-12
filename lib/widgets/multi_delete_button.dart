import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gmail_api_helper.dart' as gmail;
import 'emails_list_view.dart';
import 'show_snackbar.dart';
import 'hold_progress_button.dart';

///Widget with a delete button for deleting blacklisted emails and a dropdown for deleting emails in the useless categories.
class MultiDeleteButton extends StatefulWidget
{
    const MultiDeleteButton(this.disabled, {Key? key}) : super(key: key);

    final bool disabled;

    @override
    State<StatefulWidget> createState() => _MultiDeleteButtonState();
}

class _MultiDeleteButtonState extends State<MultiDeleteButton> with TickerProviderStateMixin
{
    static const Duration animDuration = Duration(milliseconds: 200);

    late final AnimationController animController = AnimationController(
        vsync: this,
        duration: animDuration,
    );
    late final Animation<double> sizeAnim = CurvedAnimation(
        parent: animController,
        curve: Curves.fastOutSlowIn
    );

    OverlayEntry? overlayEntry;
    final List<bool> dropdownStates = [false, false, false];

    //Deletes the useless emails based on the category ID.
    Future<void> deleteUselessEmails(String labelId) async
    {
        await gmail.deleteUselessEmails(labelId);
        EmailsListView.state.value = EmailViewState.refresh;
        ShowSnackBar.show(context, "Successfully deleted ${labelId.split("_")[1].toLowerCase()} emails!", color: Colors.green);
    }

    //Creates the dropdown of buttons. The dropdown is animated.
    OverlayEntry createOverlay()
    {
        RenderBox o = context.findRenderObject()! as RenderBox;
        Offset offset = o.localToGlobal(Offset.zero);
        Size size = o.size;

        return OverlayEntry(
            builder: (_) => Positioned(
                left: offset.dx,
                top: offset.dy + size.height - 2,
                child: SizeTransition(
                    sizeFactor: sizeAnim,
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
                                //Delete social button.
                                ObxValue(
                                    (RxBool pressed) => HoldProgressButton(
                                        text: Text(
                                            pressed.value ? "Deleting..." : "Delete Social Emails", 
                                            style: const TextStyle(color: Colors.white)
                                        ),
                                        buttonType: "text", color: Colors.red, 
                                        height: 35, width: 172,
                                        disabled: pressed.value,
                                        holdTime: 3,
                                        onComplete: !pressed.value ? () async {
                                            pressed.value = dropdownStates[0] = true;
                                            await deleteUselessEmails("CATEGORY_SOCIAL");
                                            pressed.value = dropdownStates[0] = false;
                                        } : () {},
                                    ),
                                    dropdownStates[0].obs
                                ),

                                //Delete updates button.
                                ObxValue(
                                    (RxBool pressed) => HoldProgressButton(
                                        text: Text(
                                            pressed.value ? "Deleting..." : "Delete Update Emails", 
                                            style: const TextStyle(color: Colors.white)
                                        ),
                                        buttonType: "text", color: Colors.red, 
                                        height: 35, width: 172,
                                        disabled: pressed.value,
                                        holdTime: 3,
                                        onComplete: !pressed.value ? () async {
                                            pressed.value = dropdownStates[1] = true;
                                            await deleteUselessEmails("CATEGORY_UPDATES");
                                            pressed.value = dropdownStates[1] = false;
                                        } : () {},
                                    ),
                                    dropdownStates[1].obs
                                ),
                                
                                //Delete promotion button.
                                ObxValue(
                                    (RxBool pressed) => HoldProgressButton(
                                        text: Text(
                                            pressed.value ? "Deleting..." : "Delete Promotion Emails", 
                                            style: const TextStyle(color: Colors.white)
                                        ),
                                        buttonType: "text", color: Colors.red, 
                                        height: 35, width: 172,
                                        border: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                                        disabled: pressed.value,
                                        holdTime: 3,
                                        onComplete: !pressed.value ? () async {
                                            pressed.value = dropdownStates[2] = true;
                                            await deleteUselessEmails("CATEGORY_PROMOTIONS");
                                            pressed.value = dropdownStates[2] = false;
                                        } : () {},
                                    ),
                                    dropdownStates[2].obs
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
        if(widget.disabled && overlayEntry != null) 
        { 
             overlayEntry!.remove(); 
             overlayEntry = null;
        }

        return SizedBox(
            height: 35,
            width: 172,
            child: Row(
                children: [
                    //Delete blacklisted emails button.
                    SizedBox(
                        width: 150,
                        height: 35,
                        child: ObxValue(
                            (RxBool pressed) => HoldProgressButton(
                                disabled: widget.disabled, buttonType: "elevated", color: Colors.red,
                                height: 35, width: 150,
                                border: BorderRadius.circular(5),
                                text: Text(pressed.value ? "Deleting..." : "Delete"),
                                onComplete: !pressed.value ? () async {
                                    pressed.value = true;
                                    await gmail.deleteBlacklistedEmails();
                                    EmailsListView.state.value = EmailViewState.refresh;
                                    ShowSnackBar.show(context, "Successfully deleted blacklisted emails!", color: Colors.green);
                                    pressed.value = false;
                                } : () {},
                            ),
                            false.obs
                        ),
                    ),
                    const SizedBox(width: 2),

                    //Dropdown button.
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
                                                    animController.reverse();
                                                    await Future.delayed(animDuration);
                                                    overlayEntry!.remove();
                                                    overlayEntry = null;
                                                }
                                                else 
                                                { 
                                                    overlayEntry = createOverlay();
                                                    Overlay.of(context)!.insert(overlayEntry!);
                                                    animController.forward();
                                                }
                                            }
                                            //Throws error when dropdown button is spammed. Just ignore.
                                            // ignore: empty_catches
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