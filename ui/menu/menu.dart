import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/ui/auth/login.dart';
import 'settings.dart';
import '../notes/notes.dart';

class Menu {
  late Drawer menu;
  late final SharedPreferences sp;


  Menu(BuildContext context, SharedPreferences preferences) {
    sp = preferences;
    menu = Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        children: [ Column( children: [ const Padding(padding: EdgeInsets.only(top: 75)),
          Image.asset('assets/logo.png', height: 150),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Text(sp.get("username").toString(),
          style: const TextStyle(fontSize: 40),),
          const Padding(padding: EdgeInsets.only(top: 20)),
           const Divider(thickness: 2,)]),
          ListTile( contentPadding: const EdgeInsets.only(top: 30, left: 30),
             leading: const Icon(Icons.sticky_note_2_outlined, size: 45),
            title: Transform.translate( offset: const Offset(-35, 0),
            child:  menuText('Notes')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotesPage(sp: sp),
                ));}),
          ListTile( contentPadding: const EdgeInsets.only(top: 15, left: 30),
              leading: const Icon(Icons.settings, size: 45,),
            title: Transform.translate( offset: const Offset(-15, 0),
              child:  menuText('Settings')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(sp: sp),
                ));}),
          // ListTile(  title: menuText('Tutorial'),
          //   onTap: () {
          //   },),

          ListTile( contentPadding: const EdgeInsets.only(top: 15, left: 35),
            leading: const Icon(Icons.logout, size: 42,color: Colors.redAccent,),
            title: Transform.translate( offset: const Offset(-25, 0),
                child: menuText('Logout')),
            onTap: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text('Are you sure you want to logout?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        removePreferences();
                        Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false);
                    },
                      child: const Text('Log out', semanticsLabel: "Log out",
                      style: TextStyle(fontSize: 18),),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel', semanticsLabel: "Cancel",
                      style: TextStyle(fontSize: 18),),
                    )]
                ),);
            },
          ),
        ],
      ),
    );


  }
  get menuDrawer => menu;

  Text menuText(String text) {
    return Text(text,
       textAlign: TextAlign.center,
       semanticsLabel: text,
        style: const TextStyle( fontSize: 40,
        ),
    );
  }


  removePreferences() async {
    sp.remove("email");
    sp.remove("username");
    sp.remove("phone");
    sp.remove("refreshToken");
    sp.remove("accessToken");
    sp.remove("tokenExpiration");
  }
}