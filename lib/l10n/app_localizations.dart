import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Meme Creat'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @startCreatingNow.
  ///
  /// In en, this message translates to:
  /// **'Start Creating Now!'**
  String get startCreatingNow;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @proBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Watermarks!'**
  String get proBenefitsTitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @searchMemes.
  ///
  /// In en, this message translates to:
  /// **'Search memes...'**
  String get searchMemes;

  /// No description provided for @aiMemeImage.
  ///
  /// In en, this message translates to:
  /// **'AI/Meme Image'**
  String get aiMemeImage;

  /// No description provided for @dailyGif.
  ///
  /// In en, this message translates to:
  /// **'GIF of the Day'**
  String get dailyGif;

  /// No description provided for @savedMemes.
  ///
  /// In en, this message translates to:
  /// **'Saved Memes'**
  String get savedMemes;

  /// No description provided for @recentCreations.
  ///
  /// In en, this message translates to:
  /// **'Recent Creations'**
  String get recentCreations;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'your_username'**
  String get username;

  /// No description provided for @memeCaption1.
  ///
  /// In en, this message translates to:
  /// **'When I try to use a new English word in a conversation.'**
  String get memeCaption1;

  /// No description provided for @memeCaption2.
  ///
  /// In en, this message translates to:
  /// **'My face when I finally understand a complex grammar rule.'**
  String get memeCaption2;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'GO PRO'**
  String get goPremium;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Meme World!'**
  String get welcomeTitle;

  /// No description provided for @memeCreationDescription.
  ///
  /// In en, this message translates to:
  /// **'Create Unique GIFs and Memes in Seconds'**
  String get memeCreationDescription;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to Start Creating?'**
  String get readyToStart;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @uploadYourFace.
  ///
  /// In en, this message translates to:
  /// **'1. Upload Your Face'**
  String get uploadYourFace;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select Photo from Gallery'**
  String get selectFromGallery;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @imageSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Image selection cancelled.'**
  String get imageSelectionCancelled;

  /// No description provided for @selectImageToProcess.
  ///
  /// In en, this message translates to:
  /// **'Select Image to Process'**
  String get selectImageToProcess;

  /// No description provided for @selectAnImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an image first.'**
  String get selectAnImageFirst;

  /// No description provided for @selectAGifTemplate.
  ///
  /// In en, this message translates to:
  /// **'2. Select a GIF Template'**
  String get selectAGifTemplate;

  /// No description provided for @defaultGifs.
  ///
  /// In en, this message translates to:
  /// **'Default GIFs'**
  String get defaultGifs;

  /// No description provided for @uploadYourOwnGif.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Own GIF'**
  String get uploadYourOwnGif;

  /// No description provided for @createGif.
  ///
  /// In en, this message translates to:
  /// **'Create GIF'**
  String get createGif;

  /// No description provided for @subscriptionManagement.
  ///
  /// In en, this message translates to:
  /// **'Subscription Management'**
  String get subscriptionManagement;

  /// No description provided for @currentPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Current Plan: Stitch PRO'**
  String get currentPlanTitle;

  /// No description provided for @nextRenewalDate.
  ///
  /// In en, this message translates to:
  /// **'Next renewal date:'**
  String get nextRenewalDate;

  /// No description provided for @proBenefitsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Your PRO Benefits:'**
  String get proBenefitsListTitle;

  /// No description provided for @proFeature1.
  ///
  /// In en, this message translates to:
  /// **'No watermarks'**
  String get proFeature1;

  /// No description provided for @proFeature2.
  ///
  /// In en, this message translates to:
  /// **'Access to all premium templates'**
  String get proFeature2;

  /// No description provided for @proFeature3.
  ///
  /// In en, this message translates to:
  /// **'Priority support and processing'**
  String get proFeature3;

  /// No description provided for @proFeature4.
  ///
  /// In en, this message translates to:
  /// **'Upload your own GIFs'**
  String get proFeature4;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage/Cancel Subscription'**
  String get manageSubscription;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @appearanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance Settings'**
  String get appearanceSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @customThemeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Custom theme disabled'**
  String get customThemeDisabled;

  /// No description provided for @useSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Use System Settings'**
  String get useSystemSettings;

  /// No description provided for @systemAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Automatic, synced with device settings'**
  String get systemAutoSync;

  /// No description provided for @systemSettingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Device setting disabled'**
  String get systemSettingDisabled;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @gifStat.
  ///
  /// In en, this message translates to:
  /// **'GIFs'**
  String get gifStat;

  /// No description provided for @likeStat.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likeStat;

  /// No description provided for @followerStat.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followerStat;

  /// No description provided for @ahmet.
  ///
  /// In en, this message translates to:
  /// **'Ahmet'**
  String get ahmet;

  /// No description provided for @ayse.
  ///
  /// In en, this message translates to:
  /// **'Ayşe'**
  String get ayse;

  /// No description provided for @proBenefitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Download without watermark and discover more templates!'**
  String get proBenefitsDescription;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @weekPeriod.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get weekPeriod;

  /// No description provided for @monthPeriod.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthPeriod;

  /// No description provided for @yearPeriod.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get yearPeriod;

  /// No description provided for @unlimitedMeme.
  ///
  /// In en, this message translates to:
  /// **'Unlimited meme generation'**
  String get unlimitedMeme;

  /// No description provided for @noWatermarks.
  ///
  /// In en, this message translates to:
  /// **'No watermarks'**
  String get noWatermarks;

  /// No description provided for @accessTemplates.
  ///
  /// In en, this message translates to:
  /// **'Access to all templates'**
  String get accessTemplates;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get enterEmail;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get enterUsername;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed.'**
  String get loginFailed;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up Failed.'**
  String get signUpFailed;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseSelectAGif.
  ///
  /// In en, this message translates to:
  /// **'Please select a GIF template or upload your own.'**
  String get pleaseSelectAGif;

  /// No description provided for @gifSelected.
  ///
  /// In en, this message translates to:
  /// **'GIF selected.'**
  String get gifSelected;

  /// No description provided for @pleaseSelectAnImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an image first'**
  String get pleaseSelectAnImageFirst;

  /// No description provided for @yourSelectedGif.
  ///
  /// In en, this message translates to:
  /// **'Your Selected GIF'**
  String get yourSelectedGif;

  /// No description provided for @backToTemplates.
  ///
  /// In en, this message translates to:
  /// **'Back to Templates'**
  String get backToTemplates;

  /// No description provided for @yourGif.
  ///
  /// In en, this message translates to:
  /// **'Your GIF'**
  String get yourGif;

  /// No description provided for @noGifsSavedYet.
  ///
  /// In en, this message translates to:
  /// **'No GIFs saved yet.'**
  String get noGifsSavedYet;

  /// No description provided for @noGifsCreatedYet.
  ///
  /// In en, this message translates to:
  /// **'No GIFs created yet.'**
  String get noGifsCreatedYet;

  /// No description provided for @pleaseLoginToSeeProfile.
  ///
  /// In en, this message translates to:
  /// **'Please login to see your profile.'**
  String get pleaseLoginToSeeProfile;

  /// No description provided for @processYourFace.
  ///
  /// In en, this message translates to:
  /// **'Process Your Face'**
  String get processYourFace;

  /// No description provided for @gifPreview.
  ///
  /// In en, this message translates to:
  /// **'GIF Preview'**
  String get gifPreview;

  /// No description provided for @proBenefitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Benefits'**
  String get proBenefitsSubtitle;

  /// No description provided for @goPro.
  ///
  /// In en, this message translates to:
  /// **'GO PRO'**
  String get goPro;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @gifNotFound.
  ///
  /// In en, this message translates to:
  /// **'GIF Not Found'**
  String get gifNotFound;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get likes;

  /// No description provided for @thisMayTakeAMoment.
  ///
  /// In en, this message translates to:
  /// **'This May Take a Moment'**
  String get thisMayTakeAMoment;

  /// No description provided for @creatingYourMasterpiece.
  ///
  /// In en, this message translates to:
  /// **'Creating Your Masterpiece'**
  String get creatingYourMasterpiece;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
