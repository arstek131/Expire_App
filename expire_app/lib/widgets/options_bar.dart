import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* style */
import '../app_styles.dart' as styles;

class OptionsBar extends StatefulWidget {
  const OptionsBar({Key? key}) : super(key: key);

  @override
  _OptionBarState createState() => _OptionBarState();
}

class _OptionBarState extends State<OptionsBar> {
  final List<Map<String, Object>> _choicesList = [
    {"title": "Meat", "icon": const FaIcon(FontAwesomeIcons.drumstickBite)},
    {"title": "Fish", "icon": const FaIcon(FontAwesomeIcons.fish)},
    {"title": "Vegetarian", "icon": const FaIcon(FontAwesomeIcons.leaf)},
    {"title": "Fruit", "icon": const FaIcon(FontAwesomeIcons.appleAlt)}
  ];
  List<int> _chosenIndexes = [];

  void _chipSelectionHandler(int index, selected) {
    if (!selected) {
      setState(() {
        _chosenIndexes.remove(index);
      });
    } else {
      setState(() {
        _chosenIndexes.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 40, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Products",
                      style: styles.title,
                    ),
                    FaIcon(
                      FontAwesomeIcons.search,
                      color: styles.ghostWhite,
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _choicesList.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: ChoiceChip(
                        elevation: 2,
                        selectedColor: Colors.amber,
                        backgroundColor: Colors.indigo,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          side: BorderSide(color: styles.ghostWhite),
                        ),
                        avatar: _chosenIndexes.contains(i) ? _choicesList[i]['icon'] as FaIcon : null,
                        labelPadding: EdgeInsets.symmetric(horizontal: 15),
                        label: Text(
                          _choicesList[i]['title'] as String,
                          style: const TextStyle(
                            fontFamily: 'SanFrancisco',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: styles.ghostWhite,
                          ),
                        ),
                        selected: _chosenIndexes.contains(i),
                        onSelected: (bool selected) => _chipSelectionHandler(i, selected),
                      ),
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.sort,
                    color: styles.ghostWhite,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Expiring soon",
                    style: styles.subheading,
                  )
                ],
              ),
              Icon(
                Icons.grid_view,
                color: styles.ghostWhite,
              ),
            ],
          ),
        )
      ],
    );
  }
}
