import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // TODO: check if the user is logged in
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_rounded),
                          iconSize: 80.0,
                          onPressed: () {},
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: const Text('Home'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: const Text('Subscriptions'),
                  trailing: const Text('0'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.feed_rounded),
                  title: const Text('Feed'),
                  trailing: const Text('0'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: const Text('Queue'),
                  trailing: const Text('0'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Downloads'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('History'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: const Text('Add podcast'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: const Text('Add podcast'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
