import 'package:expire_app/app_styles.dart';
import 'package:expire_app/helpers/device_info.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/providers/dependencies_provider.dart';
import 'package:expire_app/providers/recipe_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_styles.dart' as styles;
import 'recipe_details_screen.dart';

class RecipeScreen extends StatefulWidget {
  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late final _auth;

  DeviceInfo deviceInfo = DeviceInfo.instance;

  @override
  void initState() {
    _auth = Provider.of<DependenciesProvider>(context, listen: false).auth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RecipeProvider recipeManager = RecipeProvider.of(context);
    return Container(
      color: secondaryColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: deviceInfo.sizeDispatcher(
                  context: context,
                  phonePotrait: MediaQuery.of(context).size.height * 0.055,
                  phoneLandscape: 0,
                  tabletPotrait: 90,
                  tabletLandscape: 90,
                ),
                bottom: deviceInfo.sizeDispatcher(
                  context: context,
                  phonePotrait: 0,
                  phoneLandscape: 0,
                  tabletPotrait: 30,
                  tabletLandscape: 30,
                ),
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    styles.primaryColor,
                    styles.primaryColor.withOpacity(0.6),
                  ],
                  stops: [0.9, 1],
                ),
                shape: BoxShape.rectangle,
                color: Colors.pinkAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade700,
                    offset: const Offset(0, 10),
                    blurRadius: 5.0,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).orientation == Orientation.portrait ? 56 : 0,
                  left: 20,
                  right: 30,
                  bottom: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Recipes",
                      style: deviceInfo.isPhone ? styles.title : styles.title.copyWith(fontSize: 40),
                    ),
                  ],
                ),
              ),
            ),
            if (_auth.isAuth)
              Container(
                //color: secondaryColor,
                child: FutureBuilder<List<Recipe>>(
                  future: recipeManager.getRecipes(context),
                  builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
                    if (snapshot.hasData) {
                      List<Recipe> recipes = snapshot.data!;
                      if (recipes.length > 0) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 110),
                          child: deviceInfo.isPhonePotrait(context)
                              ? ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 8);
                                  },
                                  itemBuilder: (BuildContext context, int index) {
                                    return RecipeCard(
                                      r: snapshot.data![index],
                                    );
                                  },
                                )
                              : Expanded(
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: deviceInfo.isTabletLandscape(context) ? 5 : 3,
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return RecipeCard(
                                        r: snapshot.data![index],
                                      );
                                    },
                                  ),
                                ),
                        );
                      } else
                        return Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Text(
                            'No recipes available',
                            style: styles.subheading,
                          ),
                        );
                    } else if (snapshot.hasError) {
                      return Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Text(
                          'No recipes available',
                          style: styles.subheading,
                        ),
                      );
                    }
                    return Container(
                        alignment: Alignment.center, margin: EdgeInsets.only(top: 30), child: CircularProgressIndicator());
                  },
                ),
              )
            else
              Stack(
                children: [
                  /*Positioned.fill(
                    // replace with blurred image
                    top: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.red,
                    ),
                  ),*/
                  Container(
                    margin: EdgeInsets.only(top: deviceInfo.deviceHeight / 5),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      alignment: Alignment.center,
                      title: Text(
                        "Premium feature",
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        "This is a premium feature! Please register to fully unlock the functionalities of the app",
                        textAlign: TextAlign.center,
                      ),
                      titleTextStyle: TextStyle(
                        fontFamily: styles.currentFontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      contentTextStyle: TextStyle(
                        fontFamily: styles.currentFontFamily,
                        fontSize: 16,
                      ),
                      backgroundColor: styles.deepAmber,
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe r;

  const RecipeCard({Key? key, required this.r}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.zero,
      color: deepIndigo.withOpacity(0.745),
      elevation: 10,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsScreen(
              idOfRecipe: r.id.toString(),
            ),
          ),
        ),
        leading: SizedBox(
          height: 100,
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              r.image!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Container(
            height: 80,
            alignment: Alignment.centerLeft,
            child: Text(r.title!, style: robotoMedium16.copyWith(color: Colors.white))),
        trailing: Container(
          alignment: Alignment.centerRight,
          width: 20,
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
