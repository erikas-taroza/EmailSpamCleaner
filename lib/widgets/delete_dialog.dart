import 'package:flutter/material.dart';

/// Widget that displays a dialog that has a predefined title and button options. 
class DeleteDialog
{
    bool deleted = false;

    DeleteDialog.show(BuildContext context, String message, void Function() onDelete, {String deleteButtonText = "DELETE"})
    {
        showDeleteDialog(context, message, onDelete, deleteButtonText: deleteButtonText);
    }

    bool showDeleteDialog(BuildContext context, String message, void Function() onDelete, {String deleteButtonText = "DELETE"})
    {
        showDialog(
            context: context, 
            builder: (c) => AlertDialog(
                title: const Text("Warning"),
                content: SizedBox(child: Text(message), width: 100),
                actions: [
                    ElevatedButton(
                        onPressed: () {
                            onDelete();
                            Navigator.of(c).pop();
                            deleted = true;
                        }, 
                        child: Text(deleteButtonText),
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                    ),
                    
                    TextButton(
                        onPressed: () {
                            Navigator.of(c).pop();
                            deleted = false;
                        }, 
                        child: const Text("CANCEL"),
                    ),
                ],
            ),
        );

        return deleted;
    }
}