import 'package:flutter/material.dart';

///Widget that allows easy showing of the snackbar.
class ShowSnackBar
{ 
    ShowSnackBar(String message, BuildContext context, { Color color = Colors.transparent });

    ShowSnackBar.show(String message, BuildContext context, { Color color = Colors.transparent })
    {
        showSnackBar(message, color, context);
    }

    void showSnackBar(String message, Color color, BuildContext context)
    {
        SnackBar snackBar = SnackBar(
            content: Text(message),
            backgroundColor: color == Colors.transparent ? ThemeData.light().snackBarTheme.backgroundColor : color,
        );

        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
}