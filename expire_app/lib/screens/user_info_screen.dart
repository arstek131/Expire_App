/* dart */
import 'package:expire_app/helpers/sign_in_method.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';


/* providers */
import '../providers/auth_provider.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        HeaderArea(size: size),
        TitleWithBtn()
      ]),
    );
  }
}

class TitleWithBtn extends StatelessWidget {
  const TitleWithBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          TitleWithUnderline(text: "Family"),
          Spacer(),
          ElevatedButton(
            child: Text("LOGOUT"),
            onPressed: () async {
              Navigator.of(context).pushReplacementNamed('/');
              final auth = Provider.of<AuthProvider>(context, listen: false);
              print(auth.signInMethod);
              switch (auth.signInMethod) {
                case SignInMethod.EmailAndPassword:
                  await auth.logout();
                  break;
                case SignInMethod.Google:
                  auth.googleLogout();
                  break;
                case SignInMethod.Facebook:
                  auth.facebookLogout();
                  break;
                default:
                  print(auth.signInMethod);
                  throw Exception("Something went wrong during log-out");
              }
            },
          )
        ],
      ),
    );
  }
}

class TitleWithUnderline extends StatelessWidget {
  const TitleWithUnderline({
    Key? key, required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderArea extends StatelessWidget {
  const HeaderArea({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.2,
      child: Stack(children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16 + 20,
          ),
          height: size.height * 0.2 - 27,
          decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              )),
          child: Row(
            children: <Widget>[
              Text(
                "Hi, Ale!",
                style: Theme.of(context).textTheme.headline5?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              SizedBox(
                height: 70,
                width: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          ExactAssetImage("assets/images/sorre.png"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
