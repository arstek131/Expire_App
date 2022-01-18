import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* style */
import '../app_styles.dart' as styles;

/* providers */
import '../providers/filters_provider.dart';
import 'package:provider/provider.dart';

/* models */
import '../models/categories.dart' as categories;

class OptionsBar extends StatefulWidget {
  OptionsBar();

  @override
  _OptionBarState createState() => _OptionBarState();
}

class _OptionBarState extends State<OptionsBar> {
  final List<Map<String, Object>> _choicesList = categories.categories;
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
    final filtersData = Provider.of<FiltersProvider>(context, listen: false);

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
                      size: 23,
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
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        elevation: 2,
                        selectedColor: styles.deepGreen.withOpacity(0.85),
                        backgroundColor: Colors.indigo,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: styles.ghostWhite),
                        ),
                        avatar: _chosenIndexes.contains(i) ? _choicesList[i]['icon'] as FaIcon : null,
                        label: Text(
                          _choicesList[i]['title'] as String,
                          style: const TextStyle(
                            fontFamily: styles.currentFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: styles.ghostWhite,
                          ),
                        ),
                        selected: _chosenIndexes.contains(i),
                        onSelected: (bool selected) {
                          _chipSelectionHandler(i, selected);

                          switch (_choicesList[i]['title']) {
                            case "Meat":
                              filtersData.setSingleFilter(isMeat: selected);
                              break;
                            case "Fish":
                              filtersData.setSingleFilter(isFish: selected);
                              break;
                            case "Vegetarian":
                              filtersData.setSingleFilter(isVegetarian: selected);
                              break;
                            case "Vegan":
                              filtersData.setSingleFilter(isVegan: selected);
                              break;
                            case "Palm-oil free":
                              filtersData.setSingleFilter(isPalmOilFree: selected);
                              break;
                            default:
                              print("No category found!");
                              break;
                          }
                        },
                      ),
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
