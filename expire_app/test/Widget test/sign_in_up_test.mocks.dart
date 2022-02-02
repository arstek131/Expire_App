// Mocks generated by Mockito 5.0.17 from annotations
// in expire_app/test/Widget%20test/sign_in_up_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i9;

import 'package:cloud_firestore/cloud_firestore.dart' as _i13;
import 'package:expire_app/enums/sign_in_method.dart' as _i8;
import 'package:expire_app/helpers/firebase_auth_helper.dart' as _i7;
import 'package:expire_app/helpers/firestore_helper.dart' as _i10;
import 'package:expire_app/helpers/user_info.dart' as _i17;
import 'package:expire_app/models/product.dart' as _i11;
import 'package:expire_app/models/shopping_list.dart' as _i12;
import 'package:expire_app/models/shopping_list_element.dart' as _i14;
import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:firebase_core/firebase_core.dart' as _i5;
import 'package:firebase_messaging/firebase_messaging.dart' as _i15;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    as _i6;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as _i3;
import 'package:google_sign_in/google_sign_in.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:shared_preferences/shared_preferences.dart' as _i16;

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

class _FakeFirebaseApp_3 extends _i1.Fake implements _i5.FirebaseApp {}

class _FakeNotificationSettings_4 extends _i1.Fake
    implements _i6.NotificationSettings {}

/// A class which mocks [FirebaseAuthHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseAuthHelper extends _i1.Mock
    implements _i7.FirebaseAuthHelper {
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
  _i8.SignInMethod get signInMethod =>
      (super.noSuchMethod(Invocation.getter(#signInMethod),
          returnValue: _i8.SignInMethod.None) as _i8.SignInMethod);
  @override
  _i9.Future<void>? setDisplayName(String? displayName) => (super.noSuchMethod(
      Invocation.method(#setDisplayName, [displayName]),
      returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>?);
  @override
  _i9.Future<void> signInWithEmail({String? email, String? password}) =>
      (super.noSuchMethod(
          Invocation.method(
              #signInWithEmail, [], {#email: email, #password: password}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> signUpWithEmail(
          {String? email, String? password, String? familyId}) =>
      (super.noSuchMethod(
          Invocation.method(#signUpWithEmail, [],
              {#email: email, #password: password, #familyId: familyId}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> googleLogIn() =>
      (super.noSuchMethod(Invocation.method(#googleLogIn, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> facebookLogIn() =>
      (super.noSuchMethod(Invocation.method(#facebookLogIn, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> logOut() =>
      (super.noSuchMethod(Invocation.method(#logOut, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
}

/// A class which mocks [FirestoreHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirestoreHelper extends _i1.Mock implements _i10.FirestoreHelper {
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
  _i9.Future<bool> familyExists({String? familyId}) => (super.noSuchMethod(
      Invocation.method(#familyExists, [], {#familyId: familyId}),
      returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<List<String>> getUsersFromFamilyId({String? familyId}) => (super
      .noSuchMethod(
          Invocation.method(#getUsersFromFamilyId, [], {#familyId: familyId}),
          returnValue: Future<List<String>>.value(<String>[])) as _i9
      .Future<List<String>>);
  @override
  _i9.Future<String?> getFamilyIdFromUserId({String? userId}) =>
      (super.noSuchMethod(
          Invocation.method(#getFamilyIdFromUserId, [], {#userId: userId}),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<String?> getDisplayNameFromUserId({String? userId}) =>
      (super.noSuchMethod(
          Invocation.method(#getDisplayNameFromUserId, [], {#userId: userId}),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<String?> getImageUrlFromProductId({String? productId}) =>
      (super.noSuchMethod(
          Invocation.method(
              #getImageUrlFromProductId, [], {#productId: productId}),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<List<_i11.Product>> getProductsFromFamilyId(String? familyId) =>
      (super.noSuchMethod(
              Invocation.method(#getProductsFromFamilyId, [familyId]),
              returnValue: Future<List<_i11.Product>>.value(<_i11.Product>[]))
          as _i9.Future<List<_i11.Product>>);
  @override
  _i9.Future<List<_i12.ShoppingList>> getShoppingListsFromFamilyId(
          String? familyId) =>
      (super.noSuchMethod(
              Invocation.method(#getShoppingListsFromFamilyId, [familyId]),
              returnValue:
                  Future<List<_i12.ShoppingList>>.value(<_i12.ShoppingList>[]))
          as _i9.Future<List<_i12.ShoppingList>>);
  @override
  _i9.Stream<_i13.QuerySnapshot<Object?>> getFamilyProductsStream(
          {String? familyId}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getFamilyProductsStream, [], {#familyId: familyId}),
              returnValue: Stream<_i13.QuerySnapshot<Object?>>.empty())
          as _i9.Stream<_i13.QuerySnapshot<Object?>>);
  @override
  _i9.Future<void> setDisplayName({String? userId, String? displayName}) =>
      (super.noSuchMethod(
          Invocation.method(#setDisplayName, [],
              {#userId: userId, #displayName: displayName}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> addUser({String? userId, String? familyId}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addUser, [], {#userId: userId, #familyId: familyId}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> leaveFamily() =>
      (super.noSuchMethod(Invocation.method(#leaveFamily, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> mergeFamilies(
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
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<String?> addProduct({_i11.Product? product, dynamic image}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addProduct, [], {#product: product, #image: image}),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<void> addShoppingList({_i12.ShoppingList? list}) => (super
      .noSuchMethod(Invocation.method(#addShoppingList, [], {#list: list}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> deleteProduct(String? productId) =>
      (super.noSuchMethod(Invocation.method(#deleteProduct, [productId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> deleteShoppingList(String? id) =>
      (super.noSuchMethod(Invocation.method(#deleteShoppingList, [id]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> deleteShoppingListElement(
          String? shoppingListid, String? elementId) =>
      (super.noSuchMethod(
          Invocation.method(
              #deleteShoppingListElement, [shoppingListid, elementId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> updateCompleted({String? listId, bool? completed}) =>
      (super.noSuchMethod(
          Invocation.method(
              #updateCompleted, [], {#listId: listId, #completed: completed}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> updateQuantity(
          {String? listId, String? elementId, int? quantity}) =>
      (super.noSuchMethod(
          Invocation.method(#updateQuantity, [],
              {#listId: listId, #elementId: elementId, #quantity: quantity}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> updateChecked(
          {String? listId, String? elementId, bool? checked}) =>
      (super.noSuchMethod(
          Invocation.method(#updateChecked, [],
              {#listId: listId, #elementId: elementId, #checked: checked}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> addElementToShoppingList(
          {String? listId, _i14.ShoppingListElement? shoppingListElement}) =>
      (super.noSuchMethod(
          Invocation.method(#addElementToShoppingList, [],
              {#listId: listId, #shoppingListElement: shoppingListElement}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
}

/// A class which mocks [FirebaseMessaging].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseMessaging extends _i1.Mock implements _i15.FirebaseMessaging {
  MockFirebaseMessaging() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.FirebaseApp get app => (super.noSuchMethod(Invocation.getter(#app),
      returnValue: _FakeFirebaseApp_3()) as _i5.FirebaseApp);
  @override
  set app(_i5.FirebaseApp? _app) =>
      super.noSuchMethod(Invocation.setter(#app, _app),
          returnValueForMissingStub: null);
  @override
  bool get isAutoInitEnabled =>
      (super.noSuchMethod(Invocation.getter(#isAutoInitEnabled),
          returnValue: false) as bool);
  @override
  _i9.Stream<String> get onTokenRefresh =>
      (super.noSuchMethod(Invocation.getter(#onTokenRefresh),
          returnValue: Stream<String>.empty()) as _i9.Stream<String>);
  @override
  Map<dynamic, dynamic> get pluginConstants =>
      (super.noSuchMethod(Invocation.getter(#pluginConstants),
          returnValue: <dynamic, dynamic>{}) as Map<dynamic, dynamic>);
  @override
  _i9.Future<_i6.RemoteMessage?> getInitialMessage() =>
      (super.noSuchMethod(Invocation.method(#getInitialMessage, []),
              returnValue: Future<_i6.RemoteMessage?>.value())
          as _i9.Future<_i6.RemoteMessage?>);
  @override
  _i9.Future<void> deleteToken() =>
      (super.noSuchMethod(Invocation.method(#deleteToken, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<String?> getAPNSToken() =>
      (super.noSuchMethod(Invocation.method(#getAPNSToken, []),
          returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  _i9.Future<String?> getToken({String? vapidKey}) => (super.noSuchMethod(
      Invocation.method(#getToken, [], {#vapidKey: vapidKey}),
      returnValue: Future<String?>.value()) as _i9.Future<String?>);
  @override
  bool isSupported() => (super.noSuchMethod(Invocation.method(#isSupported, []),
      returnValue: false) as bool);
  @override
  _i9.Future<_i6.NotificationSettings> getNotificationSettings() =>
      (super.noSuchMethod(Invocation.method(#getNotificationSettings, []),
              returnValue: Future<_i6.NotificationSettings>.value(
                  _FakeNotificationSettings_4()))
          as _i9.Future<_i6.NotificationSettings>);
  @override
  _i9.Future<_i6.NotificationSettings> requestPermission(
          {bool? alert = true,
          bool? announcement = false,
          bool? badge = true,
          bool? carPlay = false,
          bool? criticalAlert = false,
          bool? provisional = false,
          bool? sound = true}) =>
      (super.noSuchMethod(
              Invocation.method(#requestPermission, [], {
                #alert: alert,
                #announcement: announcement,
                #badge: badge,
                #carPlay: carPlay,
                #criticalAlert: criticalAlert,
                #provisional: provisional,
                #sound: sound
              }),
              returnValue: Future<_i6.NotificationSettings>.value(
                  _FakeNotificationSettings_4()))
          as _i9.Future<_i6.NotificationSettings>);
  @override
  _i9.Future<void> sendMessage(
          {String? to,
          Map<String, String>? data,
          String? collapseKey,
          String? messageId,
          String? messageType,
          int? ttl}) =>
      (super.noSuchMethod(
          Invocation.method(#sendMessage, [], {
            #to: to,
            #data: data,
            #collapseKey: collapseKey,
            #messageId: messageId,
            #messageType: messageType,
            #ttl: ttl
          }),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> setAutoInitEnabled(bool? enabled) =>
      (super.noSuchMethod(Invocation.method(#setAutoInitEnabled, [enabled]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> setForegroundNotificationPresentationOptions(
          {bool? alert = false, bool? badge = false, bool? sound = false}) =>
      (super.noSuchMethod(
          Invocation.method(#setForegroundNotificationPresentationOptions, [],
              {#alert: alert, #badge: badge, #sound: sound}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> subscribeToTopic(String? topic) =>
      (super.noSuchMethod(Invocation.method(#subscribeToTopic, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> unsubscribeFromTopic(String? topic) =>
      (super.noSuchMethod(Invocation.method(#unsubscribeFromTopic, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
}

/// A class which mocks [SharedPreferences].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedPreferences extends _i1.Mock implements _i16.SharedPreferences {
  MockSharedPreferences() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Set<String> getKeys() => (super.noSuchMethod(Invocation.method(#getKeys, []),
      returnValue: <String>{}) as Set<String>);
  @override
  Object? get(String? key) =>
      (super.noSuchMethod(Invocation.method(#get, [key])) as Object?);
  @override
  bool? getBool(String? key) =>
      (super.noSuchMethod(Invocation.method(#getBool, [key])) as bool?);
  @override
  int? getInt(String? key) =>
      (super.noSuchMethod(Invocation.method(#getInt, [key])) as int?);
  @override
  double? getDouble(String? key) =>
      (super.noSuchMethod(Invocation.method(#getDouble, [key])) as double?);
  @override
  String? getString(String? key) =>
      (super.noSuchMethod(Invocation.method(#getString, [key])) as String?);
  @override
  bool containsKey(String? key) =>
      (super.noSuchMethod(Invocation.method(#containsKey, [key]),
          returnValue: false) as bool);
  @override
  List<String>? getStringList(String? key) =>
      (super.noSuchMethod(Invocation.method(#getStringList, [key]))
          as List<String>?);
  @override
  _i9.Future<bool> setBool(String? key, bool? value) =>
      (super.noSuchMethod(Invocation.method(#setBool, [key, value]),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> setInt(String? key, int? value) =>
      (super.noSuchMethod(Invocation.method(#setInt, [key, value]),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> setDouble(String? key, double? value) =>
      (super.noSuchMethod(Invocation.method(#setDouble, [key, value]),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> setString(String? key, String? value) =>
      (super.noSuchMethod(Invocation.method(#setString, [key, value]),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> setStringList(String? key, List<String>? value) =>
      (super.noSuchMethod(Invocation.method(#setStringList, [key, value]),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> remove(String? key) =>
      (super.noSuchMethod(Invocation.method(#remove, [key]),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> commit() =>
      (super.noSuchMethod(Invocation.method(#commit, []),
          returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> clear() => (super.noSuchMethod(Invocation.method(#clear, []),
      returnValue: Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<void> reload() =>
      (super.noSuchMethod(Invocation.method(#reload, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
}

/// A class which mocks [UserInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserInfo extends _i1.Mock implements _i17.UserInfo {
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
  _i9.Future<void> initUserInfoProvider() =>
      (super.noSuchMethod(Invocation.method(#initUserInfoProvider, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
}