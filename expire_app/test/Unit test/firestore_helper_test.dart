/* testing */
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

/* models */
import 'package:expire_app/models/product.dart';
import 'package:expire_app/models/shopping_list.dart';
import 'package:expire_app/models/shopping_list_element.dart';

/* dependencies */
import 'package:expire_app/helpers/user_info.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:openfoodfacts/model/Nutriments.dart';

/* mocks */
import './firestore_helper_test.mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/* enums */

@GenerateMocks([UserInfo])
void main() {
  // MOCKS
  MockUserInfo mockUserInfo = MockUserInfo();
  FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();
  MockFirebaseStorage mockFirebaseStorage = MockFirebaseStorage();

  FirestoreHelper firestoreHelper = FirestoreHelper(
    mockFirestore: fakeFirebaseFirestore,
    mockUserInfo: mockUserInfo,
    mockFirebaseStorage: mockFirebaseStorage,
  );

  /* STATIC STUBS */
  when(mockUserInfo.userId).thenReturn("userId");
  when(mockUserInfo.displayName).thenReturn("displayName");
  when(mockUserInfo.familyId).thenReturn("familyId");

  /* HELPER FUNCTIONS */
  Future<void> clearFirestoreData(FakeFirebaseFirestore fakeFirebaseFirestore) async {
    var batch = fakeFirebaseFirestore.batch();

    final familyDocs = (await fakeFirebaseFirestore.collection('families').get()).docs;
    for (var familyDoc in familyDocs) {
      final productDocs =
          (await fakeFirebaseFirestore.collection('families').doc(familyDoc.id).collection('products').get()).docs;
      for (var product in productDocs) {
        batch.delete(fakeFirebaseFirestore.collection('families').doc(familyDoc.id).collection('products').doc(product.id));
      }
      final shoppingListDocs =
          (await fakeFirebaseFirestore.collection('families').doc(familyDoc.id).collection('shopping_lists').get()).docs;
      for (var shoppingList in shoppingListDocs) {
        batch.delete(
            fakeFirebaseFirestore.collection('families').doc(familyDoc.id).collection('shopping_lists').doc(shoppingList.id));
      }
      batch.delete(fakeFirebaseFirestore.collection('families').doc(familyDoc.id));
    }

    final userDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
    for (var user in userDocs) {
      batch.delete(fakeFirebaseFirestore.collection('users').doc(user.id));
    }

    await batch.commit();

    var listDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;
    for (final list in listDocs) {
      await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').doc(list.id).delete();
    }

    for (var x in (await fakeFirebaseFirestore.collection('families').get()).docs) {
      await fakeFirebaseFirestore.collection('families').doc(x.id).delete();
    }
  }
  /***
   * Note: Resetting stubs every time is necessary because call count are not resetted between each tests
   * making it impossible to test callcount() or verifyNever().
   * By calling the reset function, also stubs are deleted and needs therefore to be re-defined.
   */

  group('[Add user]', () {
    test('Non-existing family', () async {
      // SETUP

      // RUN
      await firestoreHelper.addUser(userId: 'userId');

      // VERIFY
      final usersDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
      final userRef = usersDocs[0];
      String userId = userRef.id;
      String familyId = userRef['familyId'];

      expect(userId, 'userId');

      final familyRef = await fakeFirebaseFirestore.collection('families').doc(familyId).get();
      expect(familyRef['_users'][0], 'userId');

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Existing family', () async {
      // SETUP
      await firestoreHelper.addUser(userId: 'userId');
      var usersDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
      String userId = usersDocs[0].id;
      String familyId = usersDocs[0]['familyId'];

      // RUN
      await firestoreHelper.addUser(userId: 'userId2', familyId: familyId);

      // VERIFY
      usersDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
      String userId2 = usersDocs[1].id;
      String familyId2 = usersDocs[1]['familyId'];

      expect(userId2, 'userId2');
      expect(familyId2, familyId);

      final familyRef = await fakeFirebaseFirestore.collection('families').doc(familyId).get();
      expect(familyRef['_users'].length, 2);
      expect(familyRef['_users'][0], 'userId');
      expect(familyRef['_users'][1], 'userId2');

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Misc]', () {
    test('Set display name', () async {
      // SETUP
      await firestoreHelper.addUser(userId: 'userId');
      var usersDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
      String userId = usersDocs[0].id;
      String familyId = usersDocs[0]['familyId'];

      // RUN
      await firestoreHelper.setDisplayName(userId: 'userId', displayName: 'displayName');

      // VERIFY
      usersDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
      final userRef = usersDocs[0];
      String userId2 = userRef.id;
      String familyId2 = userRef['familyId'];
      String displayName = userRef['displayName'];

      expect(userId2, 'userId');
      expect(familyId, familyId2);
      expect(displayName, 'displayName');

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Family exists', () async {
      // SETUP
      await firestoreHelper.addUser(userId: 'userId');
      var usersDocs = (await fakeFirebaseFirestore.collection('users').get()).docs;
      String userId = usersDocs[0].id;
      String familyId = usersDocs[0]['familyId'];

      // RUN
      bool result = await firestoreHelper.familyExists(familyId: familyId);
      bool result2 = await firestoreHelper.familyExists(familyId: 'none');

      // VERIFY
      expect(result, true);
      expect(result2, false);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Add product]', () {
    test('No image', () async {
      final date = DateTime.now();

      // SETUP
      Product product = Product(
        id: 'id',
        title: 'title',
        expiration: date,
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: date,
      );

      // RUN
      await firestoreHelper.addProduct(product: product);

      // VERIFY
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 1);
      expect(productsDocs[0].id, 'id');
      expect(productsDocs[0]['title'], 'title');
      expect(DateTime.parse(productsDocs[0]['expiration']).millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      expect(productsDocs[0]['creatorId'], 'userId');
      expect(DateTime.parse(productsDocs[0]['expiration']).millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      expect(productsDocs[0]['imageUrl'], null);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('URL image', () async {
      final date = DateTime.now();

      // SETUP
      Product product = Product(
        id: 'id',
        title: 'title',
        expiration: date,
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: date,
        image: 'https://firebasestore/image.com',
      );

      // RUN
      await firestoreHelper.addProduct(product: product);

      // VERIFY
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 1);
      expect(productsDocs[0].id, 'id');
      expect(productsDocs[0]['title'], 'title');
      expect(DateTime.parse(productsDocs[0]['expiration']).millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      expect(productsDocs[0]['creatorId'], 'userId');
      expect(DateTime.parse(productsDocs[0]['expiration']).millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      expect(productsDocs[0]['imageUrl'], 'https://firebasestore/image.com');

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    /*
    import 'dart:async';
    import 'dart:io';
    import 'dart:typed_data';

    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:firebase_storage_mocks/src/mock_storage_reference.dart';
    import 'package:mockito/mockito.dart';

    class CustomMockReference implements MockReference {
      final Map<String, File> storedFilesMap = {};
      final Map<String, Uint8List> storedDataMap = {};

      @override
      Reference ref([String? path]) {
        path ??= '/';
        return MockReference(this, path);
      }

      @override
      String get bucket => 'some-bucket';
    }

    class MockUploadTask extends Mock implements UploadTask {
      final Future<TaskSnapshot> delegate;
      final TaskSnapshot _snapshot;

      MockUploadTask(reference)
          : delegate = Future.value(MockTaskSnapshot(reference)),
            _snapshot = MockTaskSnapshot(reference);

      @override
      Future<S> then<S>(FutureOr<S> Function(TaskSnapshot) onValue, {Function? onError}) => delegate.then(onValue, onError: onError);

      @override
      Stream<TaskSnapshot> asStream() {
        return delegate.asStream();
      }

      @override
      Future<TaskSnapshot> whenComplete(Function action) {
        return delegate;
      }

      @override
      Future<TaskSnapshot> timeout(Duration timeLimit, {FutureOr<TaskSnapshot> Function()? onTimeout}) {
        return delegate.timeout(timeLimit, onTimeout: onTimeout);
      }

      @override
      Future<TaskSnapshot> catchError(Function onError, {bool Function(Object error)? test}) {
        return delegate.catchError(onError, test: test);
      }

      @override
      Future<bool> cancel() {
        return Future.value(true);
      }

      @override
      Future<bool> resume() {
        return Future.value(true);
      }

      @override
      Future<bool> pause() {
        return Future.value(true);
      }

      @override
      TaskSnapshot get snapshot {
        return _snapshot;
      }
    }

    class MockTaskSnapshot extends Mock implements TaskSnapshot {
      final Reference reference;

      MockTaskSnapshot(this.reference);

      @override
      Reference get ref => reference;
      /*CustomMockReference(_storage, [_path = '']) : super(_storage, _path);

      @override
      Future<String> getDownloadURL() {
        return Future.value("");
      }

      @override
      Reference child(String path) {
        if (!children.containsKey(path)) {
          children[path] = MockReference(super._storage, '$_path$path');
        }
        return children[path]!;
      }*/
    }

    class CustomMockFirebaseStorage extends MockFirebaseStorage {
      @override
      Reference ref([String? path]) {
        path ??= '/';
        return CustomMockReference(this, path);
      }
    }*/

    /*test('File image', () async {
      final date = DateTime.now();

      // SETUP
      Product product = Product(
        id: 'id',
        title: 'title',
        expiration: date,
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: date,
      );

      // RUN
      await firestoreHelper.addProduct(
        product: product,
        image: File('/fake_path'),
      );

      // VERIFY
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 1);
      expect(productsDocs[0].id, 'id');
      expect(productsDocs[0]['title'], 'title');
      expect(DateTime.parse(productsDocs[0]['expiration']).millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      expect(productsDocs[0]['creatorId'], 'userId');
      expect(DateTime.parse(productsDocs[0]['expiration']).millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      print(productsDocs[0]['imageUrl']);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });*/
  });

  group('[Delete product]', () {
    test('No image', () async {
      // SETUP
      final date = DateTime.now();
      Product product = Product(
        id: 'id',
        title: 'title',
        expiration: date,
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: date,
      );

      // RUN
      await firestoreHelper.addProduct(product: product);
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 1);
      expect(productsDocs[0]['imageUrl'], null);

      // RUN
      await firestoreHelper.deleteProduct(product.id!);

      // VERIFY
      productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 0);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    /*test('File image', () async {
      // SETUP
      final date = DateTime.now();
      Product product = Product(
        id: 'id',
        title: 'title',
        expiration: date,
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: date,
      );

      // RUN
      await firestoreHelper.addProduct(product: product, image: File('/fake/path.jpg'));
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 1);
      expect(productsDocs[0]['imageUrl'], null);

      // RUN
      await firestoreHelper.deleteProduct(product.id!);

      // VERIFY
      productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 0);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });*/
  });

  group('[Get products]', () {
    test('[Existing list]', () async {
      // SETUP
      final date = DateTime.now();
      final products = [
        Product(
          id: 'id',
          title: 'title',
          expiration: date,
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: date,
          allergens: ['Cacao', 'eggs'],
          brandName: 'brandName',
          ecoscore: 'A',
          image: null,
          ingredientLevels: {'fat': 'LOW'},
          ingredientsText: "Ingredients long text",
          isPalmOilFree: "PALM_OIL_FREE",
          isVegan: "IS_VEGAN",
          isVegetarian: "IS_VEGETARIAN",
          nutriments: Nutriments(energyKcal: 200, fat: 8.6),
          nutriscore: 'A',
          packaging: 'Glass, Cardboard',
          quantity: "2",
        ),
        Product(
          id: 'id2',
          title: 'title2',
          expiration: date,
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: date,
          allergens: ['Cacao', 'eggs'],
          brandName: 'brandName2',
          ecoscore: 'A',
          image: null,
          ingredientLevels: {'fat': 'LOW'},
          ingredientsText: "Ingredients long text2",
          isPalmOilFree: "NON PALM OIL FREE",
          isVegan: "UNKNOWN",
          isVegetarian: "IS_VEGETARIAN",
          nutriments: Nutriments(energyKcal: 200, fat: 8.6),
          nutriscore: 'A',
          packaging: 'Glass, Cardboard',
          quantity: "10",
        ),
      ];

      await firestoreHelper.addUser(userId: 'userId', familyId: 'familyId');
      await firestoreHelper.setDisplayName(userId: 'userId', displayName: 'displayName');

      await firestoreHelper.addProduct(product: products[0]);
      await firestoreHelper.addProduct(product: products[1]);
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 2);

      // RUN
      List<Product> retirevedProducts = await firestoreHelper.getProductsFromFamilyId('familyId');

      // VERIFY
      expect(retirevedProducts[0] == products[0], true);
      expect(retirevedProducts[1] == products[1], true);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('[No list]', () async {
      // SETUP

      // RUN
      var productsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('products').get()).docs;
      expect(productsDocs.length, 0);

      // RUN
      List<Product> retirevedProducts = await firestoreHelper.getProductsFromFamilyId('familyId');

      // VERIFY
      expect(retirevedProducts.isEmpty, true);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Add shopping list]', () {
    test('No products', () async {
      // SETUP
      ShoppingList shoppingList = ShoppingList(id: 'id', title: 'title', products: []);

      // RUN
      await firestoreHelper.addShoppingList(list: shoppingList);

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;
      String id = listsDocs[0].id;
      String title = listsDocs[0]['title'];

      List<ShoppingListElement> elements = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 1);
      expect(id, 'id');
      expect(title, 'title');
      expect(elements.length, 0);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('With products', () async {
      // SETUP
      ShoppingList shoppingList = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      // RUN
      await firestoreHelper.addShoppingList(list: shoppingList);

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;
      String id = listsDocs[0].id;
      String title = listsDocs[0]['title'];

      List<ShoppingListElement> elements = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 1);
      expect(id, 'id');
      expect(title, 'title');
      expect(elements.length, 2);
      expect(listEquals(shoppingList.products, elements), true);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  test('[Delete shopping list]', () async {
    // SETUP
    ShoppingList shoppingList = ShoppingList(
      id: 'id',
      title: 'title',
      products: [
        ShoppingListElement(id: 'id1', title: 'title1'),
        ShoppingListElement(id: 'id2', title: 'title2'),
      ],
    );

    await firestoreHelper.addShoppingList(list: shoppingList);
    var listsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;
    expect(listsDocs.length, 1);

    // RUN
    await firestoreHelper.deleteShoppingList('id');

    // VERIFY
    listsDocs = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

    expect(listsDocs.length, 0);

    // RESET
    await clearFirestoreData(fakeFirebaseFirestore);
  });

  group('[Get shopping lists]', () {
    test('No lists', () async {
      // SETUP

      // RUN
      List<ShoppingList> lists = await firestoreHelper.getShoppingListsFromFamilyId('familyId');

      // VERIFY
      expect(lists.isEmpty, true);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Without products', () async {
      // SETUP
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id',
        title: 'title',
        products: [],
      );
      ShoppingList shoppingList2 = ShoppingList(
        id: 'id2',
        title: 'title2',
        products: [],
      );

      await firestoreHelper.addShoppingList(list: shoppingList1);
      await firestoreHelper.addShoppingList(list: shoppingList2);

      // RUN
      List<ShoppingList> lists = await firestoreHelper.getShoppingListsFromFamilyId('familyId');

      // VERIFY
      expect(lists.length, 2);
      expect(shoppingList1 == lists[0], true);
      expect(shoppingList2 == lists[1], true);
      expect(lists[0].products.length, 0);
      expect(lists[1].products.length, 0);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('With products', () async {
      // SETUP
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );
      ShoppingList shoppingList2 = ShoppingList(
        id: 'id2',
        title: 'title2',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      await firestoreHelper.addShoppingList(list: shoppingList1);
      await firestoreHelper.addShoppingList(list: shoppingList2);

      // RUN
      List<ShoppingList> lists = await firestoreHelper.getShoppingListsFromFamilyId('familyId');

      // VERIFY
      expect(lists.length, 2);
      expect(shoppingList1 == lists[0], true);
      expect(shoppingList2 == lists[1], true);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Add shopping list element]', () {
    test('New element', () async {
      var x = (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

      for (var doc in x) {
        print(doc.id);
      }

      ShoppingList shoppingList = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id1',
        title: 'title1',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      await firestoreHelper.addShoppingList(list: shoppingList);
      await firestoreHelper.addShoppingList(list: shoppingList1);

      ShoppingListElement toBeInserted = ShoppingListElement(id: 'id3', title: 'title3');

      // RUN
      await firestoreHelper.addElementToShoppingList(listId: 'id', shoppingListElement: toBeInserted);

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

      List<ShoppingListElement> elements = [];
      List<ShoppingListElement> elements2 = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      for (final productJSON in listsDocs[1]['products']) {
        elements2.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 2);

      expect(elements.length, 3);
      for (var element in elements) {
        expect(element.quantity, 1);
      }

      expect(elements2.length, 2);
      for (var element in elements2) {
        expect(element.quantity, 1);
      }

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Existing element', () async {
      ShoppingList shoppingList = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id1',
        title: 'title1',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      await firestoreHelper.addShoppingList(list: shoppingList);
      await firestoreHelper.addShoppingList(list: shoppingList1);

      ShoppingListElement toBeInserted = ShoppingListElement(id: 'id1', title: 'title3', quantity: 5);

      // RUN
      await firestoreHelper.addElementToShoppingList(listId: 'id', shoppingListElement: toBeInserted);

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

      List<ShoppingListElement> elements = [];
      List<ShoppingListElement> elements2 = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      for (final productJSON in listsDocs[1]['products']) {
        elements2.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 2);

      expect(elements.length, 2);
      expect(elements[0].quantity, 6);
      for (var i = 1; i < elements.length; i++) {
        expect(elements[i].quantity, 1);
      }

      expect(elements2.length, 2);
      for (var element in elements2) {
        expect(element.quantity, 1);
      }

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Non existing shopping list', () async {
      ShoppingList shoppingList = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id1',
        title: 'title1',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      await firestoreHelper.addShoppingList(list: shoppingList);
      await firestoreHelper.addShoppingList(list: shoppingList1);

      ShoppingListElement toBeInserted = ShoppingListElement(id: 'id1', title: 'title3', quantity: 5);

      // RUN
      await firestoreHelper.addElementToShoppingList(listId: 'id3', shoppingListElement: toBeInserted);

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

      List<ShoppingListElement> elements = [];
      List<ShoppingListElement> elements2 = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      for (final productJSON in listsDocs[1]['products']) {
        elements2.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 2);

      expect(elements.length, 2);
      for (var i = 1; i < elements.length; i++) {
        expect(elements[i].quantity, 1);
      }

      expect(elements2.length, 2);
      for (var element in elements2) {
        expect(element.quantity, 1);
      }

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Delete shopping list element]', () {
    test('Existing list', () async {
      // SETUP
      ShoppingList shoppingList = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id1',
        title: 'title1',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      await firestoreHelper.addShoppingList(list: shoppingList);
      await firestoreHelper.addShoppingList(list: shoppingList1);

      // RUN
      await firestoreHelper.deleteShoppingListElement('id', 'id1');

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

      List<ShoppingListElement> elements = [];
      List<ShoppingListElement> elements2 = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      for (final productJSON in listsDocs[1]['products']) {
        elements2.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 2);
      expect(elements.length, 1);
      expect(elements[0].id, 'id2');
      expect(elements2.length, 2);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Non-existing list', () async {
      // SETUP
      ShoppingList shoppingList = ShoppingList(
        id: 'id',
        title: 'title',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );
      ShoppingList shoppingList1 = ShoppingList(
        id: 'id1',
        title: 'title1',
        products: [
          ShoppingListElement(id: 'id1', title: 'title1'),
          ShoppingListElement(id: 'id2', title: 'title2'),
        ],
      );

      await firestoreHelper.addShoppingList(list: shoppingList);
      await firestoreHelper.addShoppingList(list: shoppingList1);

      // RUN
      await firestoreHelper.deleteShoppingListElement('id3', 'id1');

      // VERIFY
      var listsDocs =
          (await fakeFirebaseFirestore.collection('families').doc('familyId').collection('shopping_lists').get()).docs;

      List<ShoppingListElement> elements = [];
      List<ShoppingListElement> elements2 = [];

      for (final productJSON in listsDocs[0]['products']) {
        elements.add(ShoppingListElement.fromJSON(productJSON));
      }

      for (final productJSON in listsDocs[1]['products']) {
        elements2.add(ShoppingListElement.fromJSON(productJSON));
      }

      expect(listsDocs.length, 2);
      expect(elements.length, 2);

      expect(listEquals(elements, shoppingList.products), true);
      expect(elements2.length, 2);
      expect(listEquals(elements2, shoppingList1.products), true);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Leave family]', () {
    test('exisiting family', () async {
      // SETUP
      await firestoreHelper.addUser(userId: 'userId', familyId: 'familyId');
      await firestoreHelper.addUser(userId: 'userId2', familyId: 'familyId');

      var familyRef = await fakeFirebaseFirestore.collection('families').doc('familyId').get();

      expect((await fakeFirebaseFirestore.collection('families').get()).docs.length, 1);
      expect(familyRef['_users'].length, 2);
      expect(familyRef['_users'][0], 'userId');
      expect(familyRef['_users'][1], 'userId2');

      // RUN
      await firestoreHelper.leaveFamily();

      // VERIFY
      familyRef = await fakeFirebaseFirestore.collection('families').doc('familyId').get();
      var familyRef2 = await fakeFirebaseFirestore
          .collection('families')
          .doc(await firestoreHelper.getFamilyIdFromUserId(userId: 'userId'))
          .get();

      expect((await fakeFirebaseFirestore.collection('families').get()).docs.length, 2);
      expect(familyRef['_users'].length, 1);
      expect(familyRef['_users'][0], 'userId2');
      expect(familyRef2['_users'].length, 1);
      expect(familyRef2['_users'][0], 'userId');

      var usersRef = fakeFirebaseFirestore.collection('users');
      var user1 = await usersRef.doc('userId').get();
      expect(user1['familyId'] != 'familyId', true);
      var user2 = await usersRef.doc('userId2').get();
      expect(user2['familyId'], 'familyId');

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });

  group('[Merge families]', () {
    test('No merge products', () async {
      // SETUP
      await firestoreHelper.addUser(userId: 'userId', familyId: 'familyId');
      String? familyId = await firestoreHelper.getFamilyIdFromUserId(userId: 'userId');
      await firestoreHelper.addUser(userId: 'userId2');
      String? familyId2 = await firestoreHelper.getFamilyIdFromUserId(userId: 'userId2');

      final date = DateTime.now();
      await firestoreHelper.addProduct(
        product: Product(
          id: 'id',
          title: 'title',
          expiration: date,
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: date,
        ),
      );
      await firestoreHelper.addProduct(
        product: Product(
          id: 'id2',
          title: 'title2',
          expiration: date,
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: date,
        ),
      );

      // RUN
      await firestoreHelper.mergeFamilies(
        familyId: familyId2!,
        mergeProducts: false,
        singleMember: true,
      );

      // VERIFY
      expect(await firestoreHelper.getFamilyIdFromUserId(userId: 'userId'), familyId2);
      expect((await firestoreHelper.getUsersFromFamilyId(familyId: familyId2)).length, 2);
      var ref = await fakeFirebaseFirestore.collection('families').doc(familyId).get();
      expect(ref.exists, false);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });

    test('Merge products', () async {
      // SETUP
      await firestoreHelper.addUser(userId: 'userId', familyId: 'familyId');
      String? familyId = await firestoreHelper.getFamilyIdFromUserId(userId: 'userId');
      await firestoreHelper.addUser(userId: 'userId2');
      String? familyId2 = await firestoreHelper.getFamilyIdFromUserId(userId: 'userId2');

      final date = DateTime.now();
      await firestoreHelper.addProduct(
        product: Product(
          id: 'id',
          title: 'title',
          expiration: date,
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: date,
        ),
      );
      await firestoreHelper.addProduct(
        product: Product(
          id: 'id2',
          title: 'title2',
          expiration: date,
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: date,
        ),
      );

      var products = await firestoreHelper.getProductsFromFamilyId(familyId!);
      var products2 = await firestoreHelper.getProductsFromFamilyId(familyId2!);
      expect(products.length, 2);
      expect(products2.isEmpty, true);

      // RUN
      await firestoreHelper.mergeFamilies(
        familyId: familyId2,
        mergeProducts: true,
        singleMember: true,
      );

      // VERIFY
      products = await firestoreHelper.getProductsFromFamilyId(familyId);
      products2 = await firestoreHelper.getProductsFromFamilyId(familyId2);
      expect(products2.length, 2);
      expect(products.isEmpty, true);
      expect(await firestoreHelper.getFamilyIdFromUserId(userId: 'userId'), familyId2);
      expect((await firestoreHelper.getUsersFromFamilyId(familyId: familyId2)).length, 2);
      var ref = await fakeFirebaseFirestore.collection('families').doc(familyId).get();
      expect(ref.exists, false);

      // RESET
      await clearFirestoreData(fakeFirebaseFirestore);
    });
  });
}
