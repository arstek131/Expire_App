class ShoppingListElement {
  ShoppingListElement({required this.id, required this.title, this.quantity = 1, this.checked = false});

  String id;
  String title;
  int quantity;
  bool checked;

  void incrementQuantity() {
    ++quantity;
  }

  void decrementQuantity() {
    --quantity;
  }

  factory ShoppingListElement.fromJSON(Map<String, dynamic> encoded) {
    return ShoppingListElement(
      id: encoded['id'],
      title: encoded['title'],
      quantity: encoded['quantity'],
      checked: encoded['checked'],
    );
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': this.id,
      'title': this.title,
      'quantity': this.quantity,
      'checked': this.checked,
    };
  }
}
