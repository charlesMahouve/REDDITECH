import 'request/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_profile.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyProfile();
  }
}

class _MyProfile extends State<MyProfile> {
  late Future<User> futureUser;
  bool selected = true;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FutureBuilder<User>(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 150,
                          color: Colors.grey,
                          child: ((snapshot.data!.bannerImg != null &&
                                  snapshot.data!.bannerImg != '')
                              ? Image.network(
                                  snapshot.data!.bannerImg,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  height: 150,
                                )
                              : Container(
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                )),
                        ),
                        Positioned(
                            top: 150 - 60,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: NetworkImage(
                                    snapshot.data!.avatarUrl,
                                  )),
                            ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: buildName(snapshot.data!.displayName),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: buildKarmaCoin(
                          snapshot.data!.karma.toString(),
                          snapshot.data!.coins.toString(),
                          snapshot.data!.numberFriend.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              primary: Colors.black,
                              textStyle: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsProfile()));
                            },
                            child: const Text('Edit profile'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 25),
                      child: Text(
                        "\"${snapshot.data!.description}\"",
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal,
                            fontSize: 15),
                      ),
                    ),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selected = !selected;
                                    });
                                  },
                                  icon: Icon(!selected
                                      ? Icons.add_comment
                                      : Icons.add_comment_outlined)),
                              Container(
                                color: !selected
                                    ? Colors.black
                                    : Colors.transparent,
                                height: 2,
                                width: 55,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selected = !selected;
                                    });
                                  },
                                  icon: Icon(!selected
                                      ? Icons.add_to_photos_outlined
                                      : Icons.add_to_photos)),
                              Container(
                                color: !selected
                                    ? Colors.transparent
                                    : Colors.black,
                                height: 2,
                                width: 55,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Widget buildImage(imagePath) {
  final image = NetworkImage(imagePath);

  return ClipOval(
    child: Material(
      color: Colors.transparent,
      child: Ink.image(
        image: image,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        child: const InkWell(),
      ),
    ),
  );
}

Widget buildCircle({
  required Widget child,
  required double all,
  required Color color,
}) =>
    ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );

Widget buildName(name) => Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ],
    );

Widget buildKarmaCoin(karma, coins, friends) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Column(children: [
              Text(
                karma,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Karma",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                ),
              ),
            ]),
          ),
          Expanded(
            child: Column(children: [
              Text(
                friends,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Friends",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                ),
              ),
            ]),
          ),
          Expanded(
            child: Column(children: [
              Text(
                coins,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Coins",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
