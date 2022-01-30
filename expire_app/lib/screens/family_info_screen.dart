/* dart */
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/* styles */
import '../app_styles.dart' as styles;
import '../helpers/device_info.dart' as deviceInfo;
/* helpers */
import '../helpers/firestore_helper.dart';
import '../helpers/user_info.dart' as userinfo;

class FamilyInfoScreen extends StatefulWidget {
  static const routeName = "/family_info";
  const FamilyInfoScreen();

  @override
  _FamilyInfoScreenState createState() => _FamilyInfoScreenState();
}

class _FamilyInfoScreenState extends State<FamilyInfoScreen> {
  userinfo.UserInfo _userInfo = userinfo.UserInfo.instance;
  deviceInfo.DeviceInfo _deviceInfo = deviceInfo.DeviceInfo.instance;

  var usersId = [];
  var displayNames = [];

  Future<void> fetchUsersData() async {
    usersId = await FirestoreHelper().getUsersFromFamilyId(familyId: _userInfo.familyId!);

    for (final userId in usersId) {
      displayNames.add(await FirestoreHelper().getDisplayNameFromUserId(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text("Family users"),
        centerTitle: true,
      ),
      backgroundColor: styles.primaryColor,
      body: FutureBuilder<void>(
        future: fetchUsersData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                backgroundColor: Colors.white,
              ),
            );
          } else {
            return _deviceInfo.isTablet
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: usersId.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: _deviceInfo.isPhone ? 10 : 50),
                          leading: CircleAvatar(
                            radius: 27,
                            backgroundColor: styles.deepAmber,
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage: AssetImage(
                                "assets/images/croc.png",
                              ),
                            ),
                          ),
                          title: AutoSizeText(
                            displayNames[index],
                            style: styles.subheading.copyWith(fontSize: 20),
                          ),
                          subtitle: AutoSizeText(
                            "Id: ${usersId[index]}",
                            style: styles.subheading.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: styles.ghostWhite,
                          ),
                          onTap: () {});
                    },
                  )
                : ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: usersId.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: _deviceInfo.isPhone ? 10 : 50),
                          leading: CircleAvatar(
                            radius: 27,
                            backgroundColor: styles.deepAmber,
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage: AssetImage(
                                "assets/images/croc.png",
                              ),
                            ),
                          ),
                          title: AutoSizeText(
                            displayNames[index],
                            style: styles.subheading.copyWith(fontSize: 20),
                          ),
                          subtitle: AutoSizeText(
                            "Id: ${usersId[index]}",
                            style: styles.subheading.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: styles.ghostWhite,
                          ),
                          onTap: () {});
                    },
                  );
          }
        },
      ),
    );
  }
}
