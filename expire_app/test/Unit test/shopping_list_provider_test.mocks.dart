// Mocks generated by Mockito 5.0.17 from annotations
// in expire_app/test/Unit%20test/shopping_list_provider_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i7;
import 'dart:typed_data' as _i15;

import 'package:cloud_firestore/cloud_firestore.dart' as _i11;
import 'package:expire_app/enums/sign_in_method.dart' as _i6;
import 'package:expire_app/helpers/db_manager.dart' as _i14;
import 'package:expire_app/helpers/firebase_auth_helper.dart' as _i5;
import 'package:expire_app/helpers/firestore_helper.dart' as _i8;
import 'package:expire_app/helpers/user_info.dart' as _i13;
import 'package:expire_app/models/product.dart' as _i9;
import 'package:expire_app/models/shopping_list.dart' as _i10;
import 'package:expire_app/models/shopping_list_element.dart' as _i12;
import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as _i3;
import 'package:google_sign_in/google_sign_in.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeGoogleSignIn_0 extends _i1.Fake implements _i2.GoogleSignIn {}

class _FakeFacebookAuth_1 extends _i1.Fake implements _i3.FacebookAuth {}

class _FakeFirebaseAuth_2 extends _i1.Fake implements _i4.FirebaseAuth {}

/// A class which mocks [FirebaseAuthHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseAuthHelper extends _i1.Mock
    implements _i5.FirebaseAuthHelper {
  MockFirebaseAuthHelper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.GoogleSignIn get googleSignIn =>
      (super.noSuchMethod(Invocation.getter(#googleSignIn),
          returnValue: _FakeGoogleSignIn_0()) as _i2.GoogleSignIn);
  @override
  set googleSignIn(_i2.GoogleSignIn? _googleSignIn) =>
      super.noSuchMethod(Invocation.setter(#googleSignIn, _googleSignIn),
          returnValueForMissingStub: null);
  @override
  _i3.FacebookAuth get facebookAuth =>
      (super.noSuchMethod(Invocation.getter(#facebookAuth),
          returnValue: _FakeFacebookAuth_1()) as _i3.FacebookAuth);
  @override
  set facebookAuth(_i3.FacebookAuth? _facebookAuth) =>
      super.noSuchMethod(Invocation.setter(#facebookAuth, _facebookAuth),
          returnValueForMissingStub: null);
  @override
  _i4.FirebaseAuth get auth => (super.noSuchMethod(Invocation.getter(#auth),
      returnValue: _FakeFirebaseAuth_2()) as _i4.FirebaseAuth);
  @override
  bool get isAuth =>
      (super.noSuchMethod(Invocation.getter(#isAuth), returnValue: false)
          as bool);
  @override
  bool get isDisplayNameSet =>
      (super.noSuchMethod(Invocation.getter(#isDisplayNameSet),
          returnValue: false) as bool);
  @override
  _i6.SignInMethod get signInMethod =>
      (super.noSuchMethod(Invocation.getter(#signInMethod),
          returnValue: _i6.SignInMethod.None) as _i6.SignInMethod);
  @override
  _i7.Future<void>? setDisplayName(String? displayName) => (super.noSuchMethod(
      Invocation.method(#setDisplayName, [displayName]),
      returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>?);
  @override
  _i7.Future<void> signInWithEmail({String? email, String? password}) =>
      (super.noSuchMethod(
          Invocation.method(
              #signInWithEmail, [], {#email: email, #password: password}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> signUpWithEmail(
          {String? email, String? password, String? familyId}) =>
      (super.noSuchMethod(
          Invocation.method(#signUpWithEmail, [],
              {#email: email, #password: password, #familyId: familyId}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> googleLogIn() =>
      (super.noSuchMethod(Invocation.method(#googleLogIn, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> facebookLogIn() =>
      (super.noSuchMethod(Invocation.method(#facebookLogIn, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> logOut() =>
      (super.noSuchMethod(Invocation.method(#logOut, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
}

/// A class which mocks [FirestoreHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirestoreHelper extends _i1.Mock implements _i8.FirestoreHelper {
  MockFirestoreHelper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set firestore(dynamic _firestore) =>
      super.noSuchMethod(Invocation.setter(#firestore, _firestore),
          returnValueForMissingStub: null);
  @override
  set userInfo(dynamic _userInfo) =>
      super.noSuchMethod(Invocation.setter(#userInfo, _userInfo),
          returnValueForMissingStub: null);
  @override
  set firebaseStorage(dynamic _firebaseStorage) =>
      super.noSuchMethod(Invocation.setter(#firebaseStorage, _firebaseStorage),
          returnValueForMissingStub: null);
  @override
  _i7.Future<bool> familyExists({String? familyId}) => (super.noSuchMethod(
      Invocation.method(#familyExists, [], {#familyId: familyId}),
      returnValue: Future<bool>.value(false)) as _i7.Future<bool>);
  @override
  _i7.Future<List<String>> getUsersFromFamilyId({String? familyId}) => (super
      .noSuchMethod(
          Invocation.method(#getUsersFromFamilyId, [], {#familyId: familyId}),
          returnValue: Future<List<String>>.value(<String>[])) as _i7
      .Future<List<String>>);
  @override
  _i7.Future<String?> getFamilyIdFromUserId({String? userId}) =>
      (super.noSuchMethod(
          Invocation.method(#getFamilyIdFromUserId, [], {#userId: userId}),
          returnValue: Future<String?>.value()) as _i7.Future<String?>);
  @override
  _i7.Future<String?> getDisplayNameFromUserId({String? userId}) =>
      (super.noSuchMethod(
          Invocation.method(#getDisplayNameFromUserId, [], {#userId: userId}),
          returnValue: Future<String?>.value()) as _i7.Future<String?>);
  @override
  _i7.Future<String?> getImageUrlFromProductId({String? productId}) =>
      (super.noSuchMethod(
          Invocation.method(
              #getImageUrlFromProductId, [], {#productId: productId}),
          returnValue: Future<String?>.value()) as _i7.Future<String?>);
  @override
  _i7.Future<List<_i9.Product>> getProductsFromFamilyId(String? familyId) =>
      (super.noSuchMethod(
              Invocation.method(#getProductsFromFamilyId, [familyId]),
              returnValue: Future<List<_i9.Product>>.value(<_i9.Product>[]))
          as _i7.Future<List<_i9.Product>>);
  @override
  _i7.Future<List<_i10.ShoppingList>> getShoppingListsFromFamilyId(
          String? familyId) =>
      (super.noSuchMethod(
              Invocation.method(#getShoppingListsFromFamilyId, [familyId]),
              returnValue:
                  Future<List<_i10.ShoppingList>>.value(<_i10.ShoppingList>[]))
          as _i7.Future<List<_i10.ShoppingList>>);
  @override
  _i7.Stream<_i11.QuerySnapshot<Object?>> getFamilyProductsStream(
          {String? familyId}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getFamilyProductsStream, [], {#familyId: familyId}),
              returnValue: Stream<_i11.QuerySnapshot<Object?>>.empty())
          as _i7.Stream<_i11.QuerySnapshot<Object?>>);
  @override
  _i7.Future<void> setDisplayName({String? userId, String? displayName}) =>
      (super.noSuchMethod(
          Invocation.method(#setDisplayName, [],
              {#userId: userId, #displayName: displayName}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> addUser({String? userId, String? familyId}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addUser, [], {#userId: userId, #familyId: familyId}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> leaveFamily() =>
      (super.noSuchMethod(Invocation.method(#leaveFamily, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> mergeFamilies(
          {String? familyId,
          bool? mergeProducts = false,
          bool? singleMember = false}) =>
      (super.noSuchMethod(
          Invocation.method(#mergeFamilies, [], {
            #familyId: familyId,
            #mergeProducts: mergeProducts,
            #singleMember: singleMember
          }),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<String?> addProduct({_i9.Product? product, dynamic image}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addProduct, [], {#product: product, #image: image}),
          returnValue: Future<String?>.value()) as _i7.Future<String?>);
  @override
  _i7.Future<void> addShoppingList({_i10.ShoppingList? list}) => (super
      .noSuchMethod(Invocation.method(#addShoppingList, [], {#list: list}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> deleteProduct(String? productId) =>
      (super.noSuchMethod(Invocation.method(#deleteProduct, [productId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> deleteShoppingList(String? id) =>
      (super.noSuchMethod(Invocation.method(#deleteShoppingList, [id]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> deleteShoppingListElement(
          String? shoppingListid, String? elementId) =>
      (super.noSuchMethod(
          Invocation.method(
              #deleteShoppingListElement, [shoppingListid, elementId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> updateCompleted({String? listId, bool? completed}) =>
      (super.noSuchMethod(
          Invocation.method(
              #updateCompleted, [], {#listId: listId, #completed: completed}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> updateQuantity(
          {String? listId, String? elementId, int? quantity}) =>
      (super.noSuchMethod(
          Invocation.method(#updateQuantity, [],
              {#listId: listId, #elementId: elementId, #quantity: quantity}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> updateChecked(
          {String? listId, String? elementId, bool? checked}) =>
      (super.noSuchMethod(
          Invocation.method(#updateChecked, [],
              {#listId: listId, #elementId: elementId, #checked: checked}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> addElementToShoppingList(
          {String? listId, _i12.ShoppingListElement? shoppingListElement}) =>
      (super.noSuchMethod(
          Invocation.method(#addElementToShoppingList, [],
              {#listId: listId, #shoppingListElement: shoppingListElement}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
}

/// A class which mocks [UserInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserInfo extends _i1.Mock implements _i13.UserInfo {
  MockUserInfo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set userId(dynamic userId) =>
      super.noSuchMethod(Invocation.setter(#userId, userId),
          returnValueForMissingStub: null);
  @override
  set familyId(dynamic familyId) =>
      super.noSuchMethod(Invocation.setter(#familyId, familyId),
          returnValueForMissingStub: null);
  @override
  set displayName(dynamic displayName) =>
      super.noSuchMethod(Invocation.setter(#displayName, displayName),
          returnValueForMissingStub: null);
  @override
  set email(dynamic email) =>
      super.noSuchMethod(Invocation.setter(#email, email),
          returnValueForMissingStub: null);
  @override
  _i7.Future<void> initUserInfoProvider() =>
      (super.noSuchMethod(Invocation.method(#initUserInfoProvider, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
}

/// A class which mocks [DBManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockDBManager extends _i1.Mock implements _i14.DBManager {
  MockDBManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<void> init() => (super.noSuchMethod(Invocation.method(#init, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  void checkInit() => super.noSuchMethod(Invocation.method(#checkInit, []),
      returnValueForMissingStub: null);
  @override
  _i7.Future<List<_i9.Product>> getProducts() =>
      (super.noSuchMethod(Invocation.method(#getProducts, []),
              returnValue: Future<List<_i9.Product>>.value(<_i9.Product>[]))
          as _i7.Future<List<_i9.Product>>);
  @override
  _i7.Future<void> addProduct(
          {_i9.Product? product, _i15.Uint8List? imageRaw}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addProduct, [], {#product: product, #imageRaw: imageRaw}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> deleteProduct({String? productId}) => (super.noSuchMethod(
      Invocation.method(#deleteProduct, [], {#productId: productId}),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<List<_i10.ShoppingList>> getShoppingLists() =>
      (super.noSuchMethod(Invocation.method(#getShoppingLists, []),
              returnValue:
                  Future<List<_i10.ShoppingList>>.value(<_i10.ShoppingList>[]))
          as _i7.Future<List<_i10.ShoppingList>>);
  @override
  _i7.Future<void> addShoppingList({_i10.ShoppingList? list}) => (super
      .noSuchMethod(Invocation.method(#addShoppingList, [], {#list: list}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> deleteShoppingList(String? id) =>
      (super.noSuchMethod(Invocation.method(#deleteShoppingList, [id]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> updateCompletedShoppingList(
          {String? listId, bool? completed}) =>
      (super.noSuchMethod(
          Invocation.method(#updateCompletedShoppingList, [],
              {#listId: listId, #completed: completed}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> addElementToShoppingList(
          {String? listId, _i12.ShoppingListElement? shoppingListElement}) =>
      (super.noSuchMethod(
          Invocation.method(#addElementToShoppingList, [],
              {#listId: listId, #shoppingListElement: shoppingListElement}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> updateCheckedElementList(
          {String? elementId, bool? checked}) =>
      (super.noSuchMethod(
          Invocation.method(#updateCheckedElementList, [],
              {#elementId: elementId, #checked: checked}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> updateQuantity({String? elementId, int? quantity}) =>
      (super.noSuchMethod(
          Invocation.method(#updateQuantity, [],
              {#elementId: elementId, #quantity: quantity}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> deleteShoppingListElement(String? elementId) => (super
      .noSuchMethod(Invocation.method(#deleteShoppingListElement, [elementId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
}
