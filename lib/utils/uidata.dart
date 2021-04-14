import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class UIData {
  //routes
  static const String homeRoute = "/home";
  static const String addActivityPage = "/addActivityPage";
  static const String addResponsibilityPage = "/addResponsibilityPage";
  static const String notFoundRoute = "/No Search Result";
  static const String activityDetails = "/activityDetails";
  static const String responsibilityPage = "/responsibilityPage";
  static const String contactPage = "/contactPage";
  static const String joinOrganizationPage = "/joinOrganization";
  static const String loginPageRoute = "/login";
  static const String createOrgPage = "/createOrgPage";
  static const String switchOrgPage = "/switchOrgPage";
  static const String profilePage = "/profilePage";

  //strings
  static const String appName = "Talawa";

  //fonts
  static const String quickFont = "Quicksand";
  static const String ralewayFont = "Raleway";
  static const String quickBoldFont = "Quicksand_Bold.otf";
  static const String quickNormalFont = "Quicksand_Book.otf";
  static const String quickLightFont = "Quicksand_Light.otf";

  //images
  static const String imageDir = "assets/images";
  static const String pkImage = "$imageDir/pk.jpg";
  static const String profileImage = "$imageDir/profile.jpg";
  static const String blankImage = "$imageDir/blank.jpg";
  static const String dashboardImage = "$imageDir/dashboard.jpg";
  static const String loginImage = "$imageDir/login.jpg";
  static const String paymentImage = "$imageDir/payment.jpg";
  static const String settingsImage = "$imageDir/setting.jpeg";
  static const String shoppingImage = "$imageDir/shopping.jpeg";
  static const String timelineImage = "$imageDir/timeline.jpeg";
  static const String verifyImage = "$imageDir/verification.jpg";
  static const String splashScreen = "$imageDir/splashscreen.jpg";
  static const String talawaLogo = "$imageDir/talawaLogo-noBg.png";
  static const String cloud1 = "$imageDir/cloud1.jpg";
  static const String talawaLogoDark = "$imageDir/talawaLogo-dark.png";
  static const String quitoBackground = "$imageDir/quitoBackground.jpg";

  //gneric
  static const String coming_soon = "Coming Soon";

  //button text
  static const String createAccount = "Create an Account";
  static const String login = "Login";
  static const String signUp = "SIGN UP";
  static const String signIn = "SIGN IN";
  static const String join = "JOIN";
  static const String createOrg = "CREATE ORGANIZATION";
  static const String close = "Close";
  static const String yes = "Yes";
  static const String no = "No";
  static const String updateProfile = "Update Profile";
  static const String logout = "Logout";
  static const String leaveOrg = "Leave This Organization";
  static const String orgSetting = "Organization Settings";
  static const String profile = "Profile";
  static const String manage = "Manage";
  static const String home = "Home";
  static const String events = "Events";
  static const String creator = "Creator";
  static const String admins = "Admins";
  static const String eventChats = "Event Chats";
  static const String groups = "Groups";
  static const String members = "Members";
  static const String joinCreateOrg = "Join/Create\nOrganization";

  //textField label
  static const String labelSetUrl = "Type Org URL here";
  static const String labelFirstName = "First Name";
  static const String labelLastName = "Last Name";
  static const String labelEmail = "Email";
  static const String labelPassword = "Password";
  static const String labelConfirmPassword = "Confirm Password";
  static const String labelAddProfileImage = "Add Profile Image";
  static const String labelTitleToPost = "Password";
  static const String labelPost = "Write your post here....";
  static const String labelAddOrganizationImage = "Upload Organization Image";
  static const String labelOrgName = "Organization Name";
  static const String labelOrgDescription = "Organization Description";
  static const String labelOrgMemDescription = "Member Description";
  static const String labelTitle = "Title";
  static const String labelDescription = "Description";
  static const String labelLocation = "Location";
  static const String labelMakePublic = "Make Public";
  static const String labelMakeRegistrable = "Make Registrable";
  static const String labelRecurring = "Recurring";
  static const String labelAllDay = "All Day";
  static const String labelRecurrence = "Recurrence";
  static const String labelDate = "Date";
  static const String labelStartTime = "Start Date";
  static const String labelEndTime = "End Date";

  //hintText
  static const String hintSetUrl = "Type Org URL here";
  static const String hintFirstName = "Earl";
  static const String hintLastName = "John";
  static const String hintEmail = "foo@bar.com";
  static const String hintPassword = "Password";
  static const String hintConfirmPassword = "Confirm Password";
  static const String hintSearchMember = "Search Member";
  static const String hintSearchOrg = "Search Organization Name";
  static const String hintSendMessage = "Send a message..";
  static const String hintOrgName = "My Organization";
  static const String hintOrgDescription = "My Description";
  static const String hintOrgMemDescription = "Member Description";

  //normal text
  static const String textAlreadyHaveAccount = "Already have an account";
  static const String textDontHaveAccount = "Don\'t have and account";
  static const String textJoinOrgGreeting = "Welcome, \nJoin or Create your organization to get started";
  static const String textConfirmJoinOrg = "Are you sure you want to join this organization?";
  static const String textConfirmLogout = "Are you sure you want to logout?";
  static const String textConfirmLeave = "Are you sure you want to leave this organization?";
  static const String textConfirmTitle = "Confirmation";
  static const String textCurrentOrganization = "Current Organization:";
  static const String textOrgPublic = "Do you want your organization to be public?";
  static const String textOrgInSearch = "Do you want others to be able to find your organization from the search page?";


  //page titles
  static const String titleJoinOrg = "Join Organization";
  static const String titleProfile = "Profile";
  static const String titleNewsFeeds = "NewsFeed";
  static const String titleEvents = "Events";
  static const String titleNewPost = "New Post";
  static const String titleCreateOrg = "Create Organization";
  static const String titleNewEvent = "New Event";

  static const MaterialColor ui_kit_color = Colors.grey;
  static const LightGrey = Color.fromRGBO(242, 242, 242, 1);

  // static const Color quitoThemeColor = MaterialColor(0xFF7e1946, {50:Color.fromRGBO(126,25,70, .1),
  //   100:Color.fromRGBO(126,25,70, .2),
  //   200:Color.fromRGBO(126,25,70, .3),
  //   300:Color.fromRGBO(126,25,70, .4),
  //   400:Color.fromRGBO(126,25,70, .5),
  //   500:Color.fromRGBO(126,25,70, .6),
  //   600:Color.fromRGBO(126,25,70, .7),
  //   700:Color.fromRGBO(126,25,70, .8),
  //   800:Color.fromRGBO(126,25,70, .9),
  //   900:Color.fromRGBO(126,25,70, 1)});
  static const Color primaryColor = Color(0xffFEBC59);
  static const Color secondaryColor = Colors.blueAccent;

//colors
  static List<Color> kitGradients = [
    // new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),
    Colors.green.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [
    Colors.cyan.shade600,
    Colors.blue.shade900
  ];

  //randomcolor
  static final Random _random = new Random();

  /// Returns a random color.
  static Color next() {
    return new Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }
}
