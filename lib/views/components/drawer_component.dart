// ignore_for_file: must_be_immutable
import 'package:chatterbox/utils/helpers/firebase_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerComponent extends StatefulWidget {
  User? user;
  DrawerComponent({super.key, required this.user});

  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: CircleAvatar(
              radius: 80,
              backgroundImage:
                  (widget.user!.isAnonymous)
                      ? NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBL5O2812E1xgm1aNDCDY8chU60hZg8KCrpA&s",
                      )
                      : (widget.user!.photoURL == null)
                      ? NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvzCHk4vxVX-5J0QrW4fmsT4AjslKpeLnx3A&s",
                      )
                      : NetworkImage("${widget.user!.photoURL}"),
            ),
          ),
          (widget.user!.isAnonymous)
              ? Text("Guest User")
              : (widget.user!.displayName == null)
              ? Container()
              : Text("Username: ${widget.user!.displayName}"),
          (widget.user!.isAnonymous)
              ? Container()
              : Text("Email: ${widget.user!.email}"),

          Spacer(),
          ListTile(
            tileColor: Colors.red,
            textColor: Colors.white,
            iconColor: Colors.white,
            title: Text("Log Out"),
            trailing: Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuthHelper.firebaseAuthHelper.signOutUser();
              Navigator.of(context).pushReplacementNamed('user_choice');
            },
          ),
        ],
      ),
    );
  }
}
