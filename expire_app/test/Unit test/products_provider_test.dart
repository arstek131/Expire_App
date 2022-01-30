/* testing */
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

/* models */
import 'package:expire_app/models/product.dart';
import 'package:expire_app/models/filter.dart';

/* dependencies */
import 'package:expire_app/providers/products_provider.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/user_info.dart';
import 'package:expire_app/helpers/db_manager.dart';
import 'package:openfoodfacts/model/Nutriments.dart';

/* mocks */
import './products_provider_test.mocks.dart';

/* enums */
import 'package:expire_app/enums/ordering.dart';

@GenerateMocks([FirebaseAuthHelper, FirestoreHelper, UserInfo, DBManager])
void main() {
  // MOCKS
  MockFirebaseAuthHelper mockFirebaseAuthHelper = MockFirebaseAuthHelper();
  MockFirestoreHelper mockFirestoreHelper = MockFirestoreHelper();
  MockUserInfo mockUserInfo = MockUserInfo();
  MockDBManager mockDBManager = MockDBManager();

  /* STATIC STUBS */
  when(mockUserInfo.userId).thenReturn("userId");
  when(mockUserInfo.displayName).thenReturn("displayName");
  when(mockUserInfo.familyId).thenReturn("familyId");

  /***
   * Note: Resetting stubs every time is necessary because call count are not resetted between each tests
   * making it impossible to test callcount() or verifyNever().
   * By calling the reset function, also stubs are deleted and needs therefore to be re-defined.
   */

  group('[Add product]', () {
    // SETUP
    Product? product = Product(
      id: 'id',
      title: 'title',
      expiration: DateTime.parse("19970510 00:00:00"),
      creatorId: 'userId',
      creatorName: 'displayName',
      dateAdded: DateTime.parse("19970510 00:00:00"),
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
    );

    test('Local insertion', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      // RUN
      await productsProvider.addProduct(product);

      // VERIFY
      expect(productsProvider.items.length, 1);
      identical(productsProvider.items[0], product);
    });
    test('No Auth, DB access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.addProduct(product: anyNamed('product'), imageRaw: anyNamed('imageRaw')))
          .thenAnswer((_) async => null); // indifferent

      // RUN
      await productsProvider.addProduct(product);

      // VERIFY
      verifyNever(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image')));
      verify(mockDBManager.addProduct(product: anyNamed('product'), imageRaw: anyNamed('imageRaw'))).called(1);
      expect(productsProvider.items.length, 1);
      identical(productsProvider.items[0], product);
    });
    test('Auth, Firebase access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      // RUN
      await productsProvider.addProduct(product);

      // VERIFY
      verify(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).called(1);
      verifyNever(mockDBManager.addProduct(product: anyNamed('product'), imageRaw: anyNamed('imageRaw')));
      expect(productsProvider.items.length, 1);
      identical(productsProvider.items[0], product);
    });
  });

  /* DELETING A PRODUCT */
  group('[Delete product]', () {
    // SETUP
    ProductsProvider productsProvider = new ProductsProvider(
      mockFirebaseAuthHelper: mockFirebaseAuthHelper,
      mockFirestoreHelper: mockFirestoreHelper,
      mockUserInfo: mockUserInfo,
      mockDBManager: mockDBManager,
    );

    Product? product = Product(
      id: 'id',
      title: 'title',
      expiration: DateTime.parse("19970510 00:00:00"),
      creatorId: 'userId',
      creatorName: 'displayName',
      dateAdded: DateTime.parse("19970510 00:00:00"),
    );

    test('Local deletion', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      // RUN
      String? productid = await productsProvider.addProduct(product);
      expect(productsProvider.items.length, 1);

      when(mockFirestoreHelper.deleteProduct(any)).thenAnswer((_) async => null);

      // RUN
      productsProvider.deleteProduct(productid);

      // VERIFY
      expect(productsProvider.items.length, 0);
    });
    test('No Auth, DB access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid = await productsProvider.addProduct(product);
      expect(productsProvider.items.length, 1);

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockFirestoreHelper.deleteProduct(any)).thenAnswer((_) async => null);
      when(mockDBManager.deleteProduct(productId: anyNamed('productId'))).thenAnswer((_) async => null); // indifferent

      // RUN
      productsProvider.deleteProduct(productid);

      // VERIFY
      verifyNever(mockFirestoreHelper.deleteProduct(any));
      verify(mockDBManager.deleteProduct(productId: anyNamed('productId'))).called(1);
      expect(productsProvider.items.length, 0);
    });
    test('Auth, Firebase access', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid = await productsProvider.addProduct(product);
      expect(productsProvider.items.length, 1);

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.deleteProduct(any)).thenAnswer((_) async => null);
      when(mockDBManager.deleteProduct(productId: anyNamed('productId'))).thenAnswer((_) async => null); // indifferent

      // RUN
      productsProvider.deleteProduct(productid);

      // VERIFY
      verify(mockFirestoreHelper.deleteProduct(any)).called(1);
      verifyNever(mockDBManager.deleteProduct(productId: anyNamed('productId')));
      expect(productsProvider.items.length, 0);
    });
  });

  /* SORTING PRODUCTS */
  group('[Sort products]', () {
    // SETUP

    Product? product1 = Product(
      id: 'id1',
      title: 'title1',
      expiration: DateTime.parse("19970505 00:00:00"),
      creatorId: 'userId',
      creatorName: 'displayName',
      dateAdded: DateTime.parse("19970510 00:00:00"),
    );

    Product? product2 = Product(
      id: 'id2',
      title: 'title2',
      expiration: DateTime.parse("19970510 00:00:00"),
      creatorId: 'userId',
      creatorName: 'displayName',
      dateAdded: DateTime.parse("19970510 00:00:00"),
    );

    Product? product3 = Product(
      id: 'id3',
      title: 'title3',
      expiration: DateTime.parse("19970515 00:00:00"),
      creatorId: 'userId',
      creatorName: 'displayName',
      dateAdded: DateTime.parse("19970510 00:00:00"),
    );

    test('Expiring soon sorting', () async {
      // SETUP
      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid1 = await productsProvider.addProduct(product1);
      String? productid2 = await productsProvider.addProduct(product2);
      String? productid3 = await productsProvider.addProduct(product3);
      expect(productsProvider.items.length, 3);

      // RUN
      productsProvider.sortProducts(Ordering.ExpiringLast);

      // VERIFY
      expect(productsProvider.items[0].id, productid3);
      expect(productsProvider.items[1].id, productid2);
      expect(productsProvider.items[2].id, productid1);
    });

    test('Expiring last sorting', () async {
      // SETUP
      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );
      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid1 = await productsProvider.addProduct(product1);
      String? productid2 = await productsProvider.addProduct(product2);
      String? productid3 = await productsProvider.addProduct(product3);
      expect(productsProvider.items.length, 3);

      // RUN
      productsProvider.sortProducts(Ordering.ExpiringSoon);

      // VERIFY
      expect(productsProvider.items[0].id, productid1);
      expect(productsProvider.items[1].id, productid2);
      expect(productsProvider.items[2].id, productid3);
      //identical(productsProvider.items[0], product);
    });
  });

  group('[Modify product]', () {
    // SETUP

    Product? product1 = Product(
      id: '',
      title: 'title1',
      expiration: DateTime.parse("19970505 00:00:00"),
      creatorId: 'userId',
      creatorName: 'displayName',
      dateAdded: DateTime.parse("19970510 00:00:00"),
    );

    test('Modify existing product', () async {
      // SETUP
      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productId = await productsProvider.addProduct(product1);
      expect(productsProvider.items.length, 1);

      Product? product2 = Product(
        id: productId,
        title: 'title2',
        expiration: DateTime.parse("19970505 00:00:00"),
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: DateTime.parse("19970510 00:00:00"),
      );

      // RUN
      productsProvider.modifyProduct(product2);

      // VERIFY
      expect(productsProvider.items.first.id, productId);
      expect(productsProvider.items.first.title, product2.title);
      expect(productsProvider.items.first.creatorId, product2.creatorId);
      expect(productsProvider.items.first.creatorName, product2.creatorName);
    });

    test('Modify non-existing product', () async {
      // SETUP
      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productId = await productsProvider.addProduct(product1);
      expect(productsProvider.items.length, 1);

      Product? product2 = Product(
        id: 'randomID',
        title: 'title2',
        expiration: DateTime.parse("19970505 00:00:00"),
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: DateTime.parse("19970510 00:00:00"),
      );

      // RUN
      productsProvider.modifyProduct(product2);

      // VERIFY
      expect(productsProvider.items.first.id, productId);
      expect(productsProvider.items.first.title, product1.title);
      expect(productsProvider.items.first.creatorId, product1.creatorId);
      expect(productsProvider.items.first.creatorName, product1.creatorName);
    });
  });

  group('[Fetch products]', () {
    // SETUP
    List<Product> storedProducts = [
      Product(
        id: 'id1',
        title: 'title1',
        expiration: DateTime.parse("19970505 00:00:00"),
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: DateTime.parse("19970510 00:00:00"),
      ),
      Product(
        id: 'id2',
        title: 'title2',
        expiration: DateTime.parse("19970510 00:00:00"),
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: DateTime.parse("19970510 00:00:00"),
      ),
      Product(
        id: 'id3',
        title: 'title3',
        expiration: DateTime.parse("19970515 00:00:00"),
        creatorId: 'userId',
        creatorName: 'displayName',
        dateAdded: DateTime.parse("19970510 00:00:00"),
      )
    ];
    test('No Auth, fetch from DB', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(false); // indifferent
      when(mockDBManager.getProducts()).thenAnswer((_) async => storedProducts);

      // RUN
      await productsProvider.fetchProducts();

      // VERIFY
      verifyNever(mockFirestoreHelper.getProductsFromFamilyId(any));
      verify(mockDBManager.getProducts()).called(1);
      expect(productsProvider.items.length, 3);
      expect(productsProvider.items[0], storedProducts[0]);
      expect(productsProvider.items[1], storedProducts[1]);
      expect(productsProvider.items[2], storedProducts[2]);
    });

    test('Auth, fetch from Firebase', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );

      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.getProductsFromFamilyId(any)).thenAnswer((_) async => storedProducts);

      // RUN
      await productsProvider.fetchProducts();

      // VERIFY
      verifyNever(mockDBManager.getProducts());
      verify(mockFirestoreHelper.getProductsFromFamilyId(any)).called(1);
      expect(productsProvider.items.length, 3);
      expect(productsProvider.items[0], storedProducts[0]);
      expect(productsProvider.items[1], storedProducts[1]);
      expect(productsProvider.items[2], storedProducts[2]);
    });
  });

  group('[Get products]', () {
    // SETUP
    List<Product> storedProducts = [
      Product(
          id: 'id1',
          title: 'OREALIS BISCUITS',
          expiration: DateTime.parse("19970505 00:00:00"),
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: DateTime.parse("19970510 00:00:00"),
          isVegan: 'VEGAN',
          isVegetarian: "VEGETARIAN",
          isPalmOilFree: 'UNKNOWN'),
      Product(
          id: 'id2',
          title: 'OREO',
          expiration: DateTime.parse("19970510 00:00:00"),
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: DateTime.parse("19970510 00:00:00"),
          isVegan: 'VEGAN',
          isVegetarian: "NON VEGETARIAN",
          isPalmOilFree: 'PALM OIL FREE'),
      Product(
          id: 'id3',
          title: 'OREO XXL',
          expiration: DateTime.parse("19970515 00:00:00"),
          creatorId: 'userId',
          creatorName: 'displayName',
          dateAdded: DateTime.parse("19970510 00:00:00"),
          isVegan: 'NON VEGAN',
          isVegetarian: "NON VEGETARIAN",
          isPalmOilFree: 'PALM OIL FREE')
    ];
    test('Without filter', () async {
      // SETUP
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );
      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid1 = await productsProvider.addProduct(storedProducts[0]);
      String? productid2 = await productsProvider.addProduct(storedProducts[1]);
      String? productid3 = await productsProvider.addProduct(storedProducts[2]);
      expect(productsProvider.items.length, 3);

      storedProducts[0].id = productid1;
      storedProducts[1].id = productid2;
      storedProducts[2].id = productid3;

      // RUN
      List<Product> products = productsProvider.getItems();

      // VERIFY
      expect(products.length, 3);
      expect(products[0], storedProducts[0]);
      expect(products[1], storedProducts[1]);
      expect(products[2], storedProducts[2]);
    });

    test('With category filter', () async {
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );
      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid1 = await productsProvider.addProduct(storedProducts[0]);
      String? productid2 = await productsProvider.addProduct(storedProducts[1]);
      String? productid3 = await productsProvider.addProduct(storedProducts[2]);
      expect(productsProvider.items.length, 3);

      storedProducts[0].id = productid1;
      storedProducts[1].id = productid2;
      storedProducts[2].id = productid3;

      // RUN
      List<Product> products = productsProvider.getItems(filter: Filter(isVegan: true, isVegetarian: true));

      // VERIFY
      expect(products.length, 2);
      expect(products[0], storedProducts[0]);
      expect(products[1], storedProducts[1]);
    });

    test('With keywords filter', () async {
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );
      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid1 = await productsProvider.addProduct(storedProducts[0]);
      String? productid2 = await productsProvider.addProduct(storedProducts[1]);
      String? productid3 = await productsProvider.addProduct(storedProducts[2]);
      expect(productsProvider.items.length, 3);

      storedProducts[0].id = productid1;
      storedProducts[1].id = productid2;
      storedProducts[2].id = productid3;

      Filter filter = new Filter();
      filter.searchKeywords = ["OREO"];

      // RUN
      List<Product> products = productsProvider.getItems(filter: filter);

      // VERIFY
      expect(products.length, 2);
      expect(products[0], storedProducts[1]);
      expect(products[1], storedProducts[2]);
    });

    test('With keywords and category filters', () async {
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      reset(mockDBManager);

      ProductsProvider productsProvider = new ProductsProvider(
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
        mockFirestoreHelper: mockFirestoreHelper,
        mockUserInfo: mockUserInfo,
        mockDBManager: mockDBManager,
      );
      when(mockFirebaseAuthHelper.isAuth).thenReturn(true); // indifferent
      when(mockFirestoreHelper.addProduct(product: anyNamed('product'), image: anyNamed('image'))).thenAnswer((_) async => null);

      String? productid1 = await productsProvider.addProduct(storedProducts[0]);
      String? productid2 = await productsProvider.addProduct(storedProducts[1]);
      String? productid3 = await productsProvider.addProduct(storedProducts[2]);
      expect(productsProvider.items.length, 3);

      storedProducts[0].id = productid1;
      storedProducts[1].id = productid2;
      storedProducts[2].id = productid3;

      Filter filter = new Filter(isVegan: true);
      filter.searchKeywords = ["OREO"];

      // RUN
      List<Product> products = productsProvider.getItems(filter: filter);

      // VERIFY
      expect(products.length, 1);
      expect(products[0], storedProducts[1]);
    });
  });
}
