import 'package:flutter/material.dart';

class MockRecipeModel {
  String title, writer, description;
  int cookingTime;
  int servings;
  List<String> ingredients = [];
  String imgPath;
  MockRecipeModel({
    required this.title,
    required this.writer,
    required this.description,
    required this.cookingTime,
    required this.servings,
    required this.imgPath,
    required this.ingredients,
  });
  static List<MockRecipeModel> demoRecipe = [
    MockRecipeModel(
      title: 'Pizza con crema tartufata dell\'Alto Adige',
      writer: "Mamma di lattari",
      description:
      'Ed ecco qua tutte le nostre limited edition, un’esplosione di colori e sapori!🍕',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/mock_img1.png',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
    MockRecipeModel(
      title: 'Classic Omelet and Greens ',
      writer: "Padre di Lattari",
      description:
      'Sneak some spinach into your morning meal for a boost of nutrients to start your day off right.',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/mock_img2.png',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
    MockRecipeModel(
      title: 'Sheet Pan Sausage and Egg Breakfast Bake ',
      writer: "Cugino di Lattari",
      description:
      'A hearty breakfast that easily feeds a family of four, all on one sheet pan? Yes, please.',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/mock_img3.png',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
    MockRecipeModel(
      title: 'Shakshuka',
      writer: "Fratello di Lattari",
      description:
      'Just wait til you break this one out at the breakfast table: sweet tomatoes, runny yolks, and plenty of toasted bread for dipping.',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/mock_img4.png',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
  ];
}