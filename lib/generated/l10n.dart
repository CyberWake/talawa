// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Admins`
  String get admins {
    return Intl.message(
      'Admins',
      name: 'admins',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `中国人`
  String get chinese {
    return Intl.message(
      '中国人',
      name: 'chinese',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Create an Account`
  String get createAccount {
    return Intl.message(
      'Create an Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `CREATE ORGANIZATION`
  String get createOrg {
    return Intl.message(
      'CREATE ORGANIZATION',
      name: 'createOrg',
      desc: '',
      args: [],
    );
  }

  /// `Creator`
  String get creator {
    return Intl.message(
      'Creator',
      name: 'creator',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get en {
    return Intl.message(
      'English',
      name: 'en',
      desc: '',
      args: [],
    );
  }

  /// `English(US)`
  String get enUS {
    return Intl.message(
      'English(US)',
      name: 'enUS',
      desc: '',
      args: [],
    );
  }

  /// `Event Chats`
  String get eventChats {
    return Intl.message(
      'Event Chats',
      name: 'eventChats',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get events {
    return Intl.message(
      'Events',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get groups {
    return Intl.message(
      'Groups',
      name: 'groups',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get hintConfirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'hintConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `foo@bar.com`
  String get hintEmail {
    return Intl.message(
      'foo@bar.com',
      name: 'hintEmail',
      desc: '',
      args: [],
    );
  }

  /// `Earl`
  String get hintFirstName {
    return Intl.message(
      'Earl',
      name: 'hintFirstName',
      desc: '',
      args: [],
    );
  }

  /// `John`
  String get hintLastName {
    return Intl.message(
      'John',
      name: 'hintLastName',
      desc: '',
      args: [],
    );
  }

  /// `My Description`
  String get hintOrgDescription {
    return Intl.message(
      'My Description',
      name: 'hintOrgDescription',
      desc: '',
      args: [],
    );
  }

  /// `Member Description`
  String get hintOrgMemDescription {
    return Intl.message(
      'Member Description',
      name: 'hintOrgMemDescription',
      desc: '',
      args: [],
    );
  }

  /// `My Organization`
  String get hintOrgName {
    return Intl.message(
      'My Organization',
      name: 'hintOrgName',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get hintPassword {
    return Intl.message(
      'Password',
      name: 'hintPassword',
      desc: '',
      args: [],
    );
  }

  /// `Search Member`
  String get hintSearchMember {
    return Intl.message(
      'Search Member',
      name: 'hintSearchMember',
      desc: '',
      args: [],
    );
  }

  /// `Search Organization Name`
  String get hintSearchOrg {
    return Intl.message(
      'Search Organization Name',
      name: 'hintSearchOrg',
      desc: '',
      args: [],
    );
  }

  /// `Send a message..`
  String get hintSendMessage {
    return Intl.message(
      'Send a message..',
      name: 'hintSendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Type Org URL here`
  String get hintSetUrl {
    return Intl.message(
      'Type Org URL here',
      name: 'hintSetUrl',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `JOIN`
  String get join {
    return Intl.message(
      'JOIN',
      name: 'join',
      desc: '',
      args: [],
    );
  }

  /// `Join/Create\nOrganization`
  String get joinCreateOrg {
    return Intl.message(
      'Join/Create\nOrganization',
      name: 'joinCreateOrg',
      desc: '',
      args: [],
    );
  }

  /// `Upload Organization Image`
  String get labelAddOrganizationImage {
    return Intl.message(
      'Upload Organization Image',
      name: 'labelAddOrganizationImage',
      desc: '',
      args: [],
    );
  }

  /// `Add Profile Image`
  String get labelAddProfileImage {
    return Intl.message(
      'Add Profile Image',
      name: 'labelAddProfileImage',
      desc: '',
      args: [],
    );
  }

  /// `All Day`
  String get labelAllDay {
    return Intl.message(
      'All Day',
      name: 'labelAllDay',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get labelConfirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'labelConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get labelDate {
    return Intl.message(
      'Date',
      name: 'labelDate',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get labelDescription {
    return Intl.message(
      'Description',
      name: 'labelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get labelEmail {
    return Intl.message(
      'Email',
      name: 'labelEmail',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get labelEndTime {
    return Intl.message(
      'End Date',
      name: 'labelEndTime',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get labelFirstName {
    return Intl.message(
      'First Name',
      name: 'labelFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get labelLastName {
    return Intl.message(
      'Last Name',
      name: 'labelLastName',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get labelLocation {
    return Intl.message(
      'Location',
      name: 'labelLocation',
      desc: '',
      args: [],
    );
  }

  /// `Make Public`
  String get labelMakePublic {
    return Intl.message(
      'Make Public',
      name: 'labelMakePublic',
      desc: '',
      args: [],
    );
  }

  /// `Make Registrable`
  String get labelMakeRegistrable {
    return Intl.message(
      'Make Registrable',
      name: 'labelMakeRegistrable',
      desc: '',
      args: [],
    );
  }

  /// `Organization Description`
  String get labelOrgDescription {
    return Intl.message(
      'Organization Description',
      name: 'labelOrgDescription',
      desc: '',
      args: [],
    );
  }

  /// `Member Description`
  String get labelOrgMemDescription {
    return Intl.message(
      'Member Description',
      name: 'labelOrgMemDescription',
      desc: '',
      args: [],
    );
  }

  /// `Organization Name`
  String get labelOrgName {
    return Intl.message(
      'Organization Name',
      name: 'labelOrgName',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get labelPassword {
    return Intl.message(
      'Password',
      name: 'labelPassword',
      desc: '',
      args: [],
    );
  }

  /// `Write your post here....`
  String get labelPost {
    return Intl.message(
      'Write your post here....',
      name: 'labelPost',
      desc: '',
      args: [],
    );
  }

  /// `Recurrence`
  String get labelRecurrence {
    return Intl.message(
      'Recurrence',
      name: 'labelRecurrence',
      desc: '',
      args: [],
    );
  }

  /// `Recurring`
  String get labelRecurring {
    return Intl.message(
      'Recurring',
      name: 'labelRecurring',
      desc: '',
      args: [],
    );
  }

  /// `Type Org URL here`
  String get labelSetUrl {
    return Intl.message(
      'Type Org URL here',
      name: 'labelSetUrl',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get labelStartTime {
    return Intl.message(
      'Start Date',
      name: 'labelStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get labelTitle {
    return Intl.message(
      'Title',
      name: 'labelTitle',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get labelTitleToPost {
    return Intl.message(
      'Password',
      name: 'labelTitleToPost',
      desc: '',
      args: [],
    );
  }

  /// `Leave This Organization`
  String get leaveOrg {
    return Intl.message(
      'Leave This Organization',
      name: 'leaveOrg',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Manage`
  String get manage {
    return Intl.message(
      'Manage',
      name: 'manage',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Organization Settings`
  String get orgSetting {
    return Intl.message(
      'Organization Settings',
      name: 'orgSetting',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Español`
  String get spanish {
    return Intl.message(
      'Español',
      name: 'spanish',
      desc: '',
      args: [],
    );
  }

  /// `SIGN IN`
  String get signIn {
    return Intl.message(
      'SIGN IN',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `SIGN UP`
  String get signUp {
    return Intl.message(
      'SIGN UP',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account`
  String get textAlreadyHaveAccount {
    return Intl.message(
      'Already have an account',
      name: 'textAlreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to join this organization?`
  String get textConfirmJoinOrg {
    return Intl.message(
      'Are you sure you want to join this organization?',
      name: 'textConfirmJoinOrg',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave this organization?`
  String get textConfirmLeave {
    return Intl.message(
      'Are you sure you want to leave this organization?',
      name: 'textConfirmLeave',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get textConfirmLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'textConfirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get textConfirmTitle {
    return Intl.message(
      'Confirmation',
      name: 'textConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Organization:`
  String get textCurrentOrganization {
    return Intl.message(
      'Current Organization:',
      name: 'textCurrentOrganization',
      desc: '',
      args: [],
    );
  }

  /// `Don't have and account`
  String get textDontHaveAccount {
    return Intl.message(
      'Don\'t have and account',
      name: 'textDontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, \nJoin or Create your organization to get started`
  String get textJoinOrgGreeting {
    return Intl.message(
      'Welcome, \nJoin or Create your organization to get started',
      name: 'textJoinOrgGreeting',
      desc: '',
      args: [],
    );
  }

  /// `Do you want others to be able to find your organization from the search page?`
  String get textOrgInSearch {
    return Intl.message(
      'Do you want others to be able to find your organization from the search page?',
      name: 'textOrgInSearch',
      desc: '',
      args: [],
    );
  }

  /// `Do you want your organization to be public?`
  String get textOrgPublic {
    return Intl.message(
      'Do you want your organization to be public?',
      name: 'textOrgPublic',
      desc: '',
      args: [],
    );
  }

  /// `Create Organization`
  String get titleCreateOrg {
    return Intl.message(
      'Create Organization',
      name: 'titleCreateOrg',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get titleEvents {
    return Intl.message(
      'Events',
      name: 'titleEvents',
      desc: '',
      args: [],
    );
  }

  /// `Join Organization`
  String get titleJoinOrg {
    return Intl.message(
      'Join Organization',
      name: 'titleJoinOrg',
      desc: '',
      args: [],
    );
  }

  /// `New Event`
  String get titleNewEvent {
    return Intl.message(
      'New Event',
      name: 'titleNewEvent',
      desc: '',
      args: [],
    );
  }

  /// `New Post`
  String get titleNewPost {
    return Intl.message(
      'New Post',
      name: 'titleNewPost',
      desc: '',
      args: [],
    );
  }

  /// `NewsFeed`
  String get titleNewsFeeds {
    return Intl.message(
      'NewsFeed',
      name: 'titleNewsFeeds',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get titleProfile {
    return Intl.message(
      'Profile',
      name: 'titleProfile',
      desc: '',
      args: [],
    );
  }

  /// `Update Profile`
  String get updateProfile {
    return Intl.message(
      'Update Profile',
      name: 'updateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}