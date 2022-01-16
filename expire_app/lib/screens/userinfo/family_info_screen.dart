import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../app_styles.dart';
import 'user_info_screen.dart';

class FamilyInfoScreen extends StatefulWidget {
  final List<String> famusers;
  final String familyid;

  const FamilyInfoScreen({Key? key, required this.famusers, required this.familyid}) : super(key: key);

  static Future<dynamic> getFamilyList() async {
    String? familyid = await FirestoreHelper.instance.getFamilyIdFromUserId(userId: FirebaseAuthHelper.instance.userId!);
    List<dynamic>? familyUsers = await FirestoreHelper.instance.getUsersFromFamilyId(familyId: familyid!);
    if (familyUsers.length >= 2) {
      return {'users': List<String>.from(familyUsers, growable: true), 'familyid': familyid as String};
    } else {
      return false;
    }
  }

  @override
  _FamilyInfoScreenState createState() => _FamilyInfoScreenState();
}

class _FamilyInfoScreenState extends State<FamilyInfoScreen> {
  RefreshController controller = RefreshController(initialRefresh: false);
  List<String> savedUsersid = [];
  List<String> savedUsersDisplayName = [];

  @override
  void initState() {
    savedUsersid = widget.famusers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Family users"),
          centerTitle: true,
        ),
        body: SmartRefresher(
          controller: controller,
          onRefresh: onRefresh,
          child: FutureBuilder<List<String>>(
            future: getUsersDisplayName(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: savedUsersDisplayName.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {},
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      title: Text(savedUsersDisplayName[index]),
                      leading: Container(
                        color: Colors.white,
                        width: 60,
                        height: 60,
                        child: const FlutterLogo(),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 13,
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('could not fetch data'));
              } else {
                return CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  backgroundColor: Colors.white,
                );
              }
            },
          ),
        ));
  }

  Future<List<String>> getUsersDisplayName() async {
    List<String> displayNames = [];

    for (int i = 0; i < savedUsersid.length; ++i) {
      String? tmp = await FirestoreHelper.instance.getDisplayNameFromUserId(userId: savedUsersid[i]);
      if (tmp != null) {
        displayNames.add(tmp);
      }
    }
    savedUsersDisplayName = displayNames;
    return displayNames;
  }

  Future<void> onRefresh() async {
    dynamic resultant = await FamilyInfoScreen.getFamilyList();

    if (resultant is bool) {
      UserInfoScreen.showErrorDialog(
        context,
        'your family ti ha abbandonato piezz e merd',
        'attention',
        shouldLeave: true,
      );
      controller.refreshFailed();
    } else {
      Map<String, dynamic> res = resultant as Map<String, dynamic>;
      savedUsersid = res['users'] as List<String>;
    }
    getUsersDisplayName();
    controller.refreshCompleted();
  }
}
