import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @general_settings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get general_settings;

  /// No description provided for @update_profile_preferences.
  ///
  /// In en, this message translates to:
  /// **'Update your profile and application preferences.'**
  String get update_profile_preferences;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @upload_image.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get upload_image;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @start_page.
  ///
  /// In en, this message translates to:
  /// **'Start Page'**
  String get start_page;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @my_exam.
  ///
  /// In en, this message translates to:
  /// **'My Exam'**
  String get my_exam;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @create_new.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get create_new;

  /// No description provided for @shared_with_me.
  ///
  /// In en, this message translates to:
  /// **'Shared with me'**
  String get shared_with_me;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @starred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get starred;

  /// No description provided for @ai_generate.
  ///
  /// In en, this message translates to:
  /// **'AI generate'**
  String get ai_generate;

  /// No description provided for @spam_content.
  ///
  /// In en, this message translates to:
  /// **'Spam Content'**
  String get spam_content;

  /// No description provided for @trash_can.
  ///
  /// In en, this message translates to:
  /// **'Trash Can'**
  String get trash_can;

  /// No description provided for @what_to_create.
  ///
  /// In en, this message translates to:
  /// **'What do you want to create'**
  String get what_to_create;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam;

  /// No description provided for @empty_trash_can.
  ///
  /// In en, this message translates to:
  /// **'Empty trash can'**
  String get empty_trash_can;

  /// No description provided for @empty_trash_can_description.
  ///
  /// In en, this message translates to:
  /// **'Items moved to the trash will be permanently deleted after 30 days.'**
  String get empty_trash_can_description;

  /// No description provided for @open_pdf_file.
  ///
  /// In en, this message translates to:
  /// **'Open PDF File'**
  String get open_pdf_file;

  /// No description provided for @new_card.
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get new_card;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier_this_month.
  ///
  /// In en, this message translates to:
  /// **'Earlier this month'**
  String get earlier_this_month;

  /// No description provided for @last_month.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get last_month;

  /// No description provided for @earlier_this_year.
  ///
  /// In en, this message translates to:
  /// **'Earlier this year'**
  String get earlier_this_year;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @my_exam_description.
  ///
  /// In en, this message translates to:
  /// **'Manage and organize your personal exam collection'**
  String get my_exam_description;

  /// No description provided for @shared_with_me_description.
  ///
  /// In en, this message translates to:
  /// **'Access exams shared by other users'**
  String get shared_with_me_description;

  /// No description provided for @recently_description.
  ///
  /// In en, this message translates to:
  /// **'Quick access to your recently viewed content'**
  String get recently_description;

  /// No description provided for @starred_description.
  ///
  /// In en, this message translates to:
  /// **'Your favorite and bookmarked content'**
  String get starred_description;

  /// No description provided for @ai_generate_description.
  ///
  /// In en, this message translates to:
  /// **'Create exams and questions using AI assistance'**
  String get ai_generate_description;

  /// No description provided for @spam_content_description.
  ///
  /// In en, this message translates to:
  /// **'Review and manage flagged content'**
  String get spam_content_description;

  /// No description provided for @trash_can_description.
  ///
  /// In en, this message translates to:
  /// **'Recover or permanently delete items'**
  String get trash_can_description;

  /// No description provided for @search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search in Phygen...'**
  String get search_placeholder;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// No description provided for @landing_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Phygen'**
  String get landing_title;

  /// No description provided for @landing_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The ultimate platform for creating, managing, and sharing exams.'**
  String get landing_subtitle;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learn_more;

  /// No description provided for @sign_in_title.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Your Account'**
  String get sign_in_title;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dont_have_account;

  /// No description provided for @sign_up_here.
  ///
  /// In en, this message translates to:
  /// **'Sign up here'**
  String get sign_up_here;

  /// No description provided for @sign_up_title.
  ///
  /// In en, this message translates to:
  /// **'Create a New Account'**
  String get sign_up_title;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @sign_in_here.
  ///
  /// In en, this message translates to:
  /// **'Sign in here'**
  String get sign_in_here;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @help_and_support.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get help_and_support;

  /// No description provided for @display_and_accessibility.
  ///
  /// In en, this message translates to:
  /// **'Display & Accessibility'**
  String get display_and_accessibility;

  /// No description provided for @contribute_your_opinion.
  ///
  /// In en, this message translates to:
  /// **'Contribute your opinion'**
  String get contribute_your_opinion;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get log_out;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @start_page_description.
  ///
  /// In en, this message translates to:
  /// **'Choose which page to display when you open PhyGen.'**
  String get start_page_description;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @create_question.
  ///
  /// In en, this message translates to:
  /// **'Create Question'**
  String get create_question;

  /// No description provided for @create_exam.
  ///
  /// In en, this message translates to:
  /// **'Create Exam'**
  String get create_exam;

  /// No description provided for @create_from_file.
  ///
  /// In en, this message translates to:
  /// **'Create from file'**
  String get create_from_file;

  /// No description provided for @my_exam_title.
  ///
  /// In en, this message translates to:
  /// **'My Exam'**
  String get my_exam_title;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get this_week;

  /// No description provided for @empty_trash_title.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the trash'**
  String get empty_trash_title;

  /// No description provided for @empty_trash_description.
  ///
  /// In en, this message translates to:
  /// **'Items in the trash will be automatically deleted after 30 days. You can also permanently delete items yourself.'**
  String get empty_trash_description;

  /// No description provided for @landing_description_html.
  ///
  /// In en, this message translates to:
  /// **'The assessment platform is trusted by over<br />300,000+ teachers'**
  String get landing_description_html;

  /// No description provided for @feature_question_bank.
  ///
  /// In en, this message translates to:
  /// **'Question bank'**
  String get feature_question_bank;

  /// No description provided for @feature_mix_exam.
  ///
  /// In en, this message translates to:
  /// **'Mix exam'**
  String get feature_mix_exam;

  /// No description provided for @feature_mark_sheet.
  ///
  /// In en, this message translates to:
  /// **'Mark the multiple-choice sheet'**
  String get feature_mark_sheet;

  /// No description provided for @create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get create_new_account;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @terms_and_policy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service and Privacy Policy'**
  String get terms_and_policy;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome_back;

  /// No description provided for @sign_in_to_your_phygen_account.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your PhyGen account.'**
  String get sign_in_to_your_phygen_account;

  /// No description provided for @enter_your_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enter_your_email;

  /// No description provided for @enter_your_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enter_your_password;

  /// No description provided for @signing_in.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signing_in;

  /// No description provided for @or_continue_with.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get or_continue_with;

  /// No description provided for @continue_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continue_with_google;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @data_deletion.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion Policy'**
  String get data_deletion;

  /// No description provided for @sign_up_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join PhyGen and start managing your exams'**
  String get sign_up_subtitle;

  /// No description provided for @enter_your_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enter_your_full_name;

  /// No description provided for @enter_your_email_address.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enter_your_email_address;

  /// No description provided for @create_a_password.
  ///
  /// In en, this message translates to:
  /// **'Create a password (at least 6 characters)'**
  String get create_a_password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @confirm_your_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirm_your_password;

  /// No description provided for @creating_account.
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creating_account;

  /// No description provided for @error_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get error_fill_all_fields;

  /// No description provided for @error_login_failed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login. Please try again.'**
  String get error_login_failed;

  /// No description provided for @error_popup_closed.
  ///
  /// In en, this message translates to:
  /// **'The login window has been closed. Please try again.'**
  String get error_popup_closed;

  /// No description provided for @error_popup_blocked.
  ///
  /// In en, this message translates to:
  /// **'The browser has blocked the popup window. Please allow popups and try again.'**
  String get error_popup_blocked;

  /// No description provided for @error_popup_cancelled.
  ///
  /// In en, this message translates to:
  /// **'The login request has been cancelled. Please try again.'**
  String get error_popup_cancelled;

  /// No description provided for @error_network_failed.
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet connection.'**
  String get error_network_failed;

  /// No description provided for @error_login_default.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get error_login_default;

  /// No description provided for @error_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Confirmation password does not match.'**
  String get error_password_mismatch;

  /// No description provided for @error_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get error_password_too_short;

  /// No description provided for @error_signup_failed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during registration. Please try again.'**
  String get error_signup_failed;

  /// No description provided for @error_signup_default.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get error_signup_default;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
