class Filter {
  Filter({
    this.isFish = false,
    this.isMeat = false,
    this.isPalmOilFree = false,
    this.isVegan = false,
    this.isVegetarian = false,
  });

  bool isPalmOilFree;
  bool isMeat;
  bool isFish;
  bool isVegan;
  bool isVegetarian;

  bool isFilterSet() {
    return this.isFish || this.isMeat || this.isPalmOilFree || this.isVegan || this.isVegetarian;
  }
}
