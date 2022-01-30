/* testing */
import 'dart:math';

import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

/* models */
import 'package:expire_app/models/shopping_list.dart';
import 'package:expire_app/models/shopping_list_element.dart';

/* dependencies */
import 'package:expire_app/providers/shopping_list_provider.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/user_info.dart';
import 'package:expire_app/helpers/db_manager.dart';

/* mocks */
import './shopping_list_provider_test.mocks.dart';

/* enums */

@GenerateMocks([FirebaseAuthHelper, FirestoreHelper, UserInfo, DBManager])
void main() {
  // MOCKS
  MockFirebaseAuthHelper mockFirebaseAuthHelper = MockFirebaseAuthHelper();
  MockFirestoreHelper mockFirestoreHelper = MockFirestoreHelper();
  MockUserInfo mockUserInfo = MockUserInfo();
  MockDBManager mockDBManager = MockDBManager();

  // STATIC STUBS
  when(mockUserInfo.userId).thenReturn("userId");
  when(mockUserInfo.displayName).thenReturn("displayName");
  when(mockUserInfo.familyId).thenReturn("familyId");

  /***
   * Note: Resetting stubs every time is necessary because call count are not resetted between each tests
   * making it impossible to test callcount() or verifyNever().
   * By calling the reset function, also stubs are deleted and needs therefore to be re-defined.
   */

  /* Shopping list */
  group('[Add shopping list]', () {
    // SETUP

    test('Local insertion', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      // RUN
      await shoppingListProvider.addNewShoppingList(title: 'test');

      // VERIFY
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists.first.products.length, 0);
      expect(shoppingListProvider.shoppingLists.first.title, 'test');
      expect(shoppingListProvider.shoppingLists.first.completed, false);
    });

    test('Auth, Firebase access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      // RUN
      await shoppingListProvider.addNewShoppingList(title: 'test');

      // VERIFY
      verify(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).called(1);
      verifyNever(mockDBManager.addShoppingList(list: anyNamed('list')));
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists.first.products.length, 0);
      expect(shoppingListProvider.shoppingLists.first.title, 'test');
      expect(shoppingListProvider.shoppingLists.first.completed, false);
    });
    test('No Auth, DB access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      // RUN
      await shoppingListProvider.addNewShoppingList(title: 'test');

      // VERIFY
      verifyNever(mockFirestoreHelper.addShoppingList(list: anyNamed('list')));
      verify(mockDBManager.addShoppingList(list: anyNamed('list'))).called(1);
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists.first.products.length, 0);
      expect(shoppingListProvider.shoppingLists.first.title, 'test');
      expect(shoppingListProvider.shoppingLists.first.completed, false);
    });
  });

  group('[Delete shopping list]', () {
    // SETUP

    test('Local deletion', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'test');
      expect(shoppingListProvider.shoppingLists.length, 1);

      // RUN
      shoppingListProvider.deleteShoppingList(listId!);

      // VERIFY
      expect(shoppingListProvider.shoppingLists.length, 0);
    });

    test('Auth, Firebase access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'test');
      expect(shoppingListProvider.shoppingLists.length, 1);

      // RUN
      shoppingListProvider.deleteShoppingList(listId!);

      // VERIFY
      verify(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).called(1);
      verifyNever(mockDBManager.addShoppingList(list: anyNamed('list')));
      expect(shoppingListProvider.shoppingLists.length, 0);
    });
    test('No Auth, DB access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'test');
      expect(shoppingListProvider.shoppingLists.length, 1);

      // RUN
      shoppingListProvider.deleteShoppingList(listId!);

      // VERIFY
      verifyNever(mockFirestoreHelper.addShoppingList(list: anyNamed('list')));
      verify(mockDBManager.addShoppingList(list: anyNamed('list'))).called(1);
      expect(shoppingListProvider.shoppingLists.length, 0);
    });
  });

  group('[Update completed shopping list]', () {
    // SETUP

    test('Local update', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'test');
      expect(shoppingListProvider.shoppingLists.length, 1);

      // RUN
      shoppingListProvider.updateCompletedShoppingList(listId!, true);

      // VERIFY
      expect(shoppingListProvider.shoppingLists.first.completed, true);
    });

    test('Auth, Firebase access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'test');
      expect(shoppingListProvider.shoppingLists.length, 1);

      // RUN
      shoppingListProvider.updateCompletedShoppingList(listId!, true);

      // VERIFY
      verify(mockFirestoreHelper.updateCompleted(listId: anyNamed('listId'), completed: anyNamed('completed'))).called(1);
      verifyNever(mockDBManager.updateCompletedShoppingList(listId: anyNamed('listId'), completed: anyNamed('completed')));
      expect(shoppingListProvider.shoppingLists.first.completed, true);
    });
    test('No Auth, DB access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockFirestoreHelper.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'test');
      expect(shoppingListProvider.shoppingLists.length, 1);

      // RUN
      shoppingListProvider.updateCompletedShoppingList(listId!, true);

      // VERIFY
      verifyNever(mockFirestoreHelper.updateCompleted(listId: anyNamed('listId'), completed: anyNamed('completed')));
      verify(mockDBManager.updateCompletedShoppingList(listId: anyNamed('listId'), completed: anyNamed('completed'))).called(1);
      expect(shoppingListProvider.shoppingLists.first.completed, true);
    });
  });

  group('[Fetch shopping lists]', () {
    // SETUP
    List<ShoppingListElement> elements1 = [
      ShoppingListElement(id: 'id1', title: 'title1'),
      ShoppingListElement(id: 'id2', title: 'title2'),
      ShoppingListElement(id: 'id3', title: 'title3'),
    ];
    List<ShoppingListElement> elements2 = [
      ShoppingListElement(id: 'id4', title: 'title4'),
      ShoppingListElement(id: 'id5', title: 'title5'),
      ShoppingListElement(id: 'id6', title: 'title6'),
    ];

    List<ShoppingList> storedShoppingLists = [
      ShoppingList(id: 'id1', title: 'title1', products: [...elements1])..completed = true,
      ShoppingList(id: 'id2', title: 'title2', products: [...elements2]),
    ];

    test('No Auth, fetch from DB', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.getShoppingLists()).thenAnswer((_) async => storedShoppingLists);

      // RUN
      await shoppingListProvider.fetchShoppingLists();

      // VERIFY
      expect(shoppingListProvider.shoppingLists.length, 2);
      expect(shoppingListProvider.shoppingLists[0], storedShoppingLists[0]);
      expect(shoppingListProvider.shoppingLists[0].completed, true);
      expect(shoppingListProvider.shoppingLists[1], storedShoppingLists[1]);
      expect(shoppingListProvider.shoppingLists[1].completed, false);
      verifyNever(mockFirestoreHelper.getShoppingListsFromFamilyId(any));
      verify(mockDBManager.getShoppingLists()).called(1);
    });

    test('Auth, fetch from Firebase', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.getShoppingListsFromFamilyId(any)).thenAnswer((_) async => storedShoppingLists);

      // RUN
      await shoppingListProvider.fetchShoppingLists();

      // VERIFY
      expect(shoppingListProvider.shoppingLists.length, 2);
      expect(shoppingListProvider.shoppingLists[0], storedShoppingLists[0]);
      expect(shoppingListProvider.shoppingLists[0].completed, true);
      expect(shoppingListProvider.shoppingLists[1], storedShoppingLists[1]);
      expect(shoppingListProvider.shoppingLists[1].completed, false);
      verify(mockFirestoreHelper.getShoppingListsFromFamilyId(any)).called(1);
      verifyNever(mockDBManager.getShoppingLists());
    });
  });

  group('[Modify shopping lists]', () {
    // SETUP
    List<ShoppingListElement> elements1 = [
      ShoppingListElement(id: 'id1', title: 'title1'),
      ShoppingListElement(id: 'id2', title: 'title2'),
      ShoppingListElement(id: 'id3', title: 'title3'),
    ];
    List<ShoppingListElement> elements2 = [
      ShoppingListElement(id: 'id4', title: 'title4'),
      ShoppingListElement(id: 'id5', title: 'title5'),
      ShoppingListElement(id: 'id6', title: 'title6'),
    ];

    test('Existing shopping list', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'title1', products: elements1);
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);

      ShoppingList list = ShoppingList(id: listId!, title: 'title2', products: elements2)..completed = true;

      // RUN
      shoppingListProvider.modifyShoppingList(list);

      // VERIFY
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[0], list);
    });

    test('Non-existing shopping list', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId = await shoppingListProvider.addNewShoppingList(title: 'title1', products: elements1);
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);

      ShoppingList list = ShoppingList(id: 'id', title: 'title2', products: elements2)..completed = true;

      // RUN
      shoppingListProvider.modifyShoppingList(list);

      // VERIFY
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[0].id, listId);
      expect(shoppingListProvider.shoppingLists[0].products, elements1);
    });
  });
  /* End of Shopping list */

  /* Shopping List Element */
  group('[Get products]', () {
    // SETUP
    List<ShoppingListElement> elements1 = [
      ShoppingListElement(id: 'id1', title: 'title1'),
      ShoppingListElement(id: 'id2', title: 'title2'),
      ShoppingListElement(id: 'id3', title: 'title3'),
    ];
    List<ShoppingListElement> elements2 = [
      ShoppingListElement(id: 'id4', title: 'title4'),
      ShoppingListElement(id: 'id5', title: 'title5'),
      ShoppingListElement(id: 'id6', title: 'title6'),
    ];

    test('Existing shopping list', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId1 = await shoppingListProvider.addNewShoppingList(title: 'title1', products: elements1);
      await shoppingListProvider.addNewShoppingList(title: 'title2', products: elements2);
      expect(shoppingListProvider.shoppingLists.length, 2);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[1].products.length, 3);

      // RUN
      List<ShoppingListElement> retrievedProducts = shoppingListProvider.getProductsFromListId(listId: listId1!);

      // VERIFY
      expect(retrievedProducts, elements1);
    });

    test('Non-existing shopping list', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      await shoppingListProvider.addNewShoppingList(title: 'title1', products: elements1);
      await shoppingListProvider.addNewShoppingList(title: 'title2', products: elements2);
      expect(shoppingListProvider.shoppingLists.length, 2);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[1].products.length, 3);

      // RUN
      List<ShoppingListElement> retrievedProducts = shoppingListProvider.getProductsFromListId(listId: 'id2');

      // VERIFY
      expect(retrievedProducts, []);
    });
  });

  group('[Add shopping list element]', () {
    // SETUP
    test('Local insertion, new element', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      List<ShoppingListElement> elements1 = [
        ShoppingListElement(id: 'id1', title: 'title1'),
        ShoppingListElement(id: 'id2', title: 'title2'),
        ShoppingListElement(id: 'id3', title: 'title3'),
      ];

      ShoppingListProvider shoppingListProvider = ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId1 = await shoppingListProvider.addNewShoppingList(title: 'title1', products: [...elements1]); //
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);

      when(mockDBManager.addElementToShoppingList(
              listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')))
          .thenAnswer((_) async => null);

      // RUN
      shoppingListProvider.addElementToShoppingList(listId: listId1!, shoppingListElementTitle: 'title4', quantity: 1);

      // VERIFY
      expect(shoppingListProvider.shoppingLists[0].products.length, 4);
      expect(shoppingListProvider.shoppingLists[0].products[3].quantity, 1);
    });

    test('Local insertion, existing element', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      List<ShoppingListElement> elements1 = [
        ShoppingListElement(id: 'id1', title: 'title1'),
        ShoppingListElement(id: 'id2', title: 'title2'),
        ShoppingListElement(id: 'id3', title: 'title3'),
      ];

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId1 = await shoppingListProvider.addNewShoppingList(title: 'title1', products: [...elements1]);
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);

      when(mockDBManager.addElementToShoppingList(
              listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')))
          .thenAnswer((_) async => null);

      // RUN
      shoppingListProvider.addElementToShoppingList(listId: listId1!, shoppingListElementTitle: 'title3', quantity: 5);

      // VERIFY
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[0].products[2].quantity, 6);
    });

    test('Auth, add to firebase', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      List<ShoppingListElement> elements1 = [
        ShoppingListElement(id: 'id1', title: 'title1'),
        ShoppingListElement(id: 'id2', title: 'title2'),
        ShoppingListElement(id: 'id3', title: 'title3'),
      ];

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId1 = await shoppingListProvider.addNewShoppingList(title: 'title1', products: [...elements1]);
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);

      when(mockFirestoreHelper.addElementToShoppingList(
              listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')))
          .thenAnswer((_) async => null);

      // RUN
      shoppingListProvider.addElementToShoppingList(listId: listId1!, shoppingListElementTitle: 'title3', quantity: 5);

      // VERIFY
      verify(mockFirestoreHelper.addElementToShoppingList(
              listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')))
          .called(1);
      verifyNever(mockDBManager.addElementToShoppingList(
          listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')));
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[0].products[2].quantity, 6);
    });

    test('No Auth, add to DB', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      List<ShoppingListElement> elements1 = [
        ShoppingListElement(id: 'id1', title: 'title1'),
        ShoppingListElement(id: 'id2', title: 'title2'),
        ShoppingListElement(id: 'id3', title: 'title3'),
      ];

      ShoppingListProvider shoppingListProvider = new ShoppingListProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addShoppingList(list: anyNamed('list'))).thenAnswer((_) async => null);

      String? listId1 = await shoppingListProvider.addNewShoppingList(title: 'title1', products: [...elements1]);
      expect(shoppingListProvider.shoppingLists.length, 1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);

      when(mockFirestoreHelper.addElementToShoppingList(
              listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')))
          .thenAnswer((_) async => null);

      // RUN
      shoppingListProvider.addElementToShoppingList(listId: listId1!, shoppingListElementTitle: 'title3', quantity: 5);

      // VERIFY
      verifyNever(mockFirestoreHelper.addElementToShoppingList(
          listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')));
      verify(mockDBManager.addElementToShoppingList(
              listId: anyNamed('listId'), shoppingListElement: anyNamed('shoppingListElement')))
          .called(1);
      expect(shoppingListProvider.shoppingLists[0].products.length, 3);
      expect(shoppingListProvider.shoppingLists[0].products[2].quantity, 6);
    });
  });
  /* End of Shopping List Element */
}
