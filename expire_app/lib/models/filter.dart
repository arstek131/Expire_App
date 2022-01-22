class Filter {
  Filter({
    this.isFish = false,
    this.isMeat = false,
    this.isPalmOilFree = false,
    this.isVegan = false,
    this.isVegetarian = false,
    this.hideExpired = false,
  });

  bool isPalmOilFree;
  bool isMeat;
  bool isFish;
  bool isVegan;
  bool isVegetarian;
  bool hideExpired;
  List<String> searchKeywords = [];

  bool isFilterSet() {
    return this.isFish ||
        this.isMeat ||
        this.isPalmOilFree ||
        this.isVegan ||
        this.isVegetarian ||
        searchKeywords.isNotEmpty ||
        this.hideExpired;
  }

  bool areCategoriesSet() {
    return this.isFish || this.isMeat || this.isPalmOilFree || this.isVegan || this.isVegetarian;
  }

  bool areSearchKeywordsSet() {
    return searchKeywords.isNotEmpty;
  }

  void clear() {
    this.isFish = false;
    this.isMeat = false;
    this.isPalmOilFree = false;
    this.isVegan = false;
    this.isVegetarian = false;
    this.searchKeywords = [];
    this.hideExpired = false;
  }
}
