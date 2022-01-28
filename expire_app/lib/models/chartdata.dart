class ChartData {

  ChartData(this.sugar, this.fat, this.saturatedfat, this.salt);

  final List<Sugar> sugar;
  final List<Fat> fat;
  final List<SaturatedFat> saturatedfat;
  final List<Salt> salt;
}


class Sugar {
  Sugar(this.type, this.value);

   String type;
   int value;
}

class Fat {
  Fat(this.type, this.value);

   String type;
   int value;
}

class SaturatedFat {
  SaturatedFat(this.type, this.value);

   String type;
   int value;
}

class Salt {
  Salt(this.type, this.value);

   String type;
   int value;
}