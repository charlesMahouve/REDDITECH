import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsProfile extends StatefulWidget {
  const SettingsProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsProfile();
  }
}

class _SettingsProfile extends State<SettingsProfile> {
  bool isLoading = false;
  bool acceptFollowers = false;
  bool showPresence = true;
  bool isSwitched_5 = true;
  bool autoplay = true;
  bool adultContent = true;
  bool beta = false;
  bool contentVisibility = true;
  bool emailRequest = true;
  bool emailComments = true;
  bool emailUpvotePost = true;
  bool emailPrivateMessage = true;
  bool emailUserMention = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future loadSettings() async {
    setState(() {
      isLoading = true;
    });
    final LocalStorage storage = LocalStorage('user');
    final response = await get(
        Uri.parse('https://oauth.reddit.com/api/v1/me/prefs'),
        headers: {'authorization': 'Bearer ${storage.getItem('token')}'});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        acceptFollowers = data['enable_followers'];
        showPresence = data['show_presence'];
        autoplay = data['video_autoplay'];
        adultContent = data['over_18'];
        beta = data['beta'];
        contentVisibility = data['profile_opt_out'];
        emailRequest = data['email_chat_request'];
        emailComments = data['email_comment_reply'];
        emailUpvotePost = data['email_upvote_post'];
        emailPrivateMessage = data['email_private_message'];
        emailUserMention = data['email_username_mention'];
      });
    } else {
      debugPrint('/api/v1/me: ${response.statusCode}');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future patchSettings() async {
      setState(() {
        isLoading = true;
      });
      final LocalStorage storage = LocalStorage('user');
      var body = jsonEncode({
        'enable_followers': acceptFollowers,
        'show_presence': showPresence,
        'video_autoplay': autoplay,
        'over_18': adultContent,
        'beta': beta,
        'profile_opt_out': contentVisibility,
        'email_chat_request': emailRequest,
        'email_comment_reply': emailComments,
        'email_upvote_post': emailUpvotePost,
        'email_private_message': emailPrivateMessage,
        'email_username_mention': emailUserMention,
      });
      print(body);
      //return;
      final response = await patch(
          Uri.parse('https://oauth.reddit.com/api/v1/me/prefs'),
          body: body,
          headers: {'authorization': 'Bearer ${storage.getItem('token')}'});

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('error');
      }
      setState(() {
        isLoading = false;
      });
    }

    if (isLoading) {
      return Scaffold(
          appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black, //change your color here
              ),
              elevation: 0,
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white),
          body: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Advanced'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Allow people to follow you'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.userShield),
                  enabled: acceptFollowers,
                  onToggle: (value) {
                    setState(() {
                      acceptFollowers = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Content visibility'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.userShield),
                  enabled: contentVisibility,
                  onToggle: (value) {
                    setState(() {
                      contentVisibility = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Active in communities visibility'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.universalAccess),
                  enabled: showPresence,
                  onToggle: (value) {
                    setState(() {
                      showPresence = value;
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Content preferences'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Autoplay media'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.playCircle),
                  enabled: autoplay,
                  onToggle: (value) {
                    setState(() {
                      autoplay = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Adult content'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.male),
                  enabled: adultContent,
                  onToggle: (value) {
                    setState(() {
                      adultContent = value;
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Beta Tests'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Opt into beta tests'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.playCircle),
                  enabled: beta,
                  onToggle: (value) {
                    setState(() {
                      beta = value;
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Email Notifications'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Discussion requests'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.discourse),
                  enabled: emailRequest,
                  onToggle: (value) {
                    setState(() {
                      emailRequest = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Answers to your comments'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.discourse),
                  enabled: emailComments,
                  onToggle: (value) {
                    setState(() {
                      emailComments = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Upvote Post'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.discourse),
                  enabled: emailUpvotePost,
                  onToggle: (value) {
                    setState(() {
                      emailUpvotePost = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Mentions of your username'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.discourse),
                  enabled: emailUserMention,
                  onToggle: (value) {
                    setState(() {
                      emailUserMention = value;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  title: const Text('Inbox messages'),
                  activeSwitchColor: Colors.indigo,
                  leading: const FaIcon(FontAwesomeIcons.discourse),
                  enabled: emailPrivateMessage,
                  onToggle: (value) {
                    setState(() {
                      emailPrivateMessage = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 35, left: 25, right: 25, top: 5),
        child: ElevatedButton(
          onPressed: () {
            patchSettings();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(60))),
          ),
          child: const Text('Validate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }
}
