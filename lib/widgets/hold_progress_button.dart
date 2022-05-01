import 'package:flutter/material.dart';

class HoldProgressButton extends StatefulWidget
{
    ///Only "text" or "elevated" buttons are allowed.
    const HoldProgressButton(
    {
        required this.text, 
        required this.onComplete,
        required this.buttonType,
        required this.height,
        required this.width,
        this.disabled = false,
        this.border = BorderRadius.zero,
        this.color = Colors.blue,

        Key? key
    }) : super(key: key);

    final double height;
    final double width;
    final bool disabled;
    final String buttonType;
    final Color color;
    final Text text;
    final BorderRadius border;
    final void Function() onComplete;

    @override
    State<StatefulWidget> createState() => _HoldProgressButtonState();
}

class _HoldProgressButtonState extends State<HoldProgressButton>
{
    int animDuration = 0;
    bool holding = false;

    ButtonStyleButton buildButton()
    {
        if(widget.buttonType == "text")
        {
            return TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: widget.color,
                    shape: RoundedRectangleBorder(borderRadius: widget.border),
                    splashFactory: NoSplash.splashFactory
                ),
                child: widget.text,
                onPressed: widget.disabled ? null : (){},
            );
        }
        else if(widget.buttonType == "elevated")
        {
            return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: widget.color,
                    shape: RoundedRectangleBorder(borderRadius: widget.border),
                    splashFactory: NoSplash.splashFactory
                ),
                child: widget.text,
                onPressed: widget.disabled ? null : (){},
            );
        }
        else
        {
            throw const FormatException("The given button type was invalid!");
        }
    }

    @override
    Widget build(BuildContext context) 
    {  
        return GestureDetector(
            onLongPressStart: (_) {
                if(widget.disabled) return;
                setState(() {
                    animDuration = 1000;
                    holding = true;
                });
            },
            onLongPressEnd: (_) {
                if(widget.disabled) return;
                setState(() {
                    animDuration = 200;
                    holding = false;
                });
            },
            child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                    SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: buildButton()
                    ),
                    AnimatedContainer(
                        duration: Duration(milliseconds: animDuration),
                        alignment: Alignment.centerLeft,
                        curve: Curves.linear,
                        width: holding ? widget.width : 0,
                        height: widget.height,
                        onEnd: () { 
                            if(holding)
                            {
                                setState(() {
                                    animDuration = 200;
                                    holding = false;
                                });
                                widget.onComplete(); 
                            }
                        },
                        decoration: BoxDecoration(
                            color: Theme.of(context).splashColor,
                            borderRadius: widget.border,
                        ),
                    ),
                ],
            )
        );
    }
}