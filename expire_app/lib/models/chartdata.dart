class ChartData {

  ChartData({this.sugar, this.fat, this.saturatedfat, this.salt});

  late List<Sugar>? sugar;
  late List<Fat>? fat;
  late List<SaturatedFat>? saturatedfat;
  late List<Salt>? salt;
}


class Sugar {
  Sugar(this.type, this.value);

   String type;
   int value;

   @override
  String toString() {
    return ('Sugar: '+'type: $type -> value: $value');
  }
}

class Fat {
  Fat(this.type, this.value);

   String type;
   int value;

  @override
  String toString() {
    return ('Fat: '+'type: $type -> value: $value');
  }
}

class SaturatedFat {
  SaturatedFat(this.type, this.value);

   String type;
   int value;

  @override
  String toString() {
    return ('Saturated-fat: '+'type: $type -> value: $value');
  }
}

class Salt {
  Salt(this.type, this.value);

   String type;
   int value;

  @override
  String toString() {
    return ('Salt: '+'type: $type -> value: $value');
  }
}