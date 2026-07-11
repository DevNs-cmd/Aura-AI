import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Aura AI'**
  String get appTitle;

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for the language setting tile
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Title for the explore page
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreDiscoverTools.
  ///
  /// In en, this message translates to:
  /// **'Discover tools to grow'**
  String get exploreDiscoverTools;

  /// No description provided for @exploreAskWithAura.
  ///
  /// In en, this message translates to:
  /// **'Ask with Aura'**
  String get exploreAskWithAura;

  /// No description provided for @exploreAiAssistantChat.
  ///
  /// In en, this message translates to:
  /// **'AI assistant Chat'**
  String get exploreAiAssistantChat;

  /// No description provided for @exploreAnalyzeAnything.
  ///
  /// In en, this message translates to:
  /// **'Analyze anything'**
  String get exploreAnalyzeAnything;

  /// No description provided for @exploreVisionScanner.
  ///
  /// In en, this message translates to:
  /// **'Vision Scanner'**
  String get exploreVisionScanner;

  /// No description provided for @exploreAskYourFiles.
  ///
  /// In en, this message translates to:
  /// **'Ask your files'**
  String get exploreAskYourFiles;

  /// No description provided for @exploreUploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get exploreUploadDocuments;

  /// No description provided for @exploreVoiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get exploreVoiceAssistant;

  /// No description provided for @exploreTalkHandsFree.
  ///
  /// In en, this message translates to:
  /// **'Talk hands-free'**
  String get exploreTalkHandsFree;

  /// No description provided for @exploreRecommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get exploreRecommendedForYou;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get settingsSecurity;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock (Passcode)'**
  String get settingsAppLock;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsVoicePitch.
  ///
  /// In en, this message translates to:
  /// **'Voice Pitch'**
  String get settingsVoicePitch;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache Data'**
  String get settingsClearCache;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout from Aura AI'**
  String get settingsLogout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsSelectLanguage;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get greetingNight;

  /// No description provided for @homeMyJournal.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get homeMyJournal;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeQuickJournal.
  ///
  /// In en, this message translates to:
  /// **'Quick Journal'**
  String get homeQuickJournal;

  /// No description provided for @homeEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get homeEvening;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get navJourney;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @heroCompanionRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Companion Recommendation'**
  String get heroCompanionRecommendation;

  /// No description provided for @heroLetsChat.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Chat'**
  String get heroLetsChat;

  /// No description provided for @quickPauseReflect.
  ///
  /// In en, this message translates to:
  /// **'Pause & reflect 🌿'**
  String get quickPauseReflect;

  /// No description provided for @quickGratefulToday.
  ///
  /// In en, this message translates to:
  /// **'What are you grateful for today?'**
  String get quickGratefulToday;

  /// No description provided for @quickPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get quickPersonal;

  /// No description provided for @quickSetIntentions.
  ///
  /// In en, this message translates to:
  /// **'Set intentions ☀️'**
  String get quickSetIntentions;

  /// No description provided for @quickHowFeel.
  ///
  /// In en, this message translates to:
  /// **'How do you want to feel?'**
  String get quickHowFeel;

  /// No description provided for @quickFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get quickFamily;

  /// No description provided for @chatAuraCompanion.
  ///
  /// In en, this message translates to:
  /// **'Aura Companion'**
  String get chatAuraCompanion;

  /// No description provided for @chatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online • GPT-4o'**
  String get chatOnline;

  /// No description provided for @chatClearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get chatClearChat;

  /// No description provided for @chatAddAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get chatAddAttachment;

  /// No description provided for @quickActionChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get quickActionChat;

  /// No description provided for @quickActionVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get quickActionVoice;

  /// No description provided for @quickActionVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get quickActionVision;

  /// No description provided for @quickActionJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get quickActionJournal;

  /// No description provided for @recommendationDefault.
  ///
  /// In en, this message translates to:
  /// **'Hello there! I\'m Aura, your supportive AI companion. Tell me how you feel today to set our mood.'**
  String get recommendationDefault;

  /// No description provided for @recommendationHappy.
  ///
  /// In en, this message translates to:
  /// **'Your space is full of sunshine today! Let\'s grow together. Want to write down your happy thoughts?'**
  String get recommendationHappy;

  /// No description provided for @recommendationCalm.
  ///
  /// In en, this message translates to:
  /// **'A peaceful mind leads to beautiful growth. Take a deep breath and tell me whatever is on your mind.'**
  String get recommendationCalm;

  /// No description provided for @recommendationMotivated.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got that productive spark! Let\'s review your goals and take some small steps forward.'**
  String get recommendationMotivated;

  /// No description provided for @recommendationRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Enjoy this cozy, calm breeze. Let\'s write a light reflection entry without any pressure.'**
  String get recommendationRelaxed;

  /// No description provided for @recommendationReflective.
  ///
  /// In en, this message translates to:
  /// **'It\'s a perfect day to listen to your inner voice. What\'s one thing you are learning about yourself?'**
  String get recommendationReflective;

  /// No description provided for @recommendationFocused.
  ///
  /// In en, this message translates to:
  /// **'Deep focus mode is active. Let\'s keep our target goals clear and work on them step-by-step.'**
  String get recommendationFocused;

  /// No description provided for @exploreDailyReflection.
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get exploreDailyReflection;

  /// No description provided for @exploreDailyReflectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Start your day with clarity and mindfulness.'**
  String get exploreDailyReflectionDesc;

  /// No description provided for @exploreTryNow.
  ///
  /// In en, this message translates to:
  /// **'Try Now'**
  String get exploreTryNow;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message Aura...'**
  String get chatMessageHint;

  /// No description provided for @chatExplainCode.
  ///
  /// In en, this message translates to:
  /// **'Explain code'**
  String get chatExplainCode;

  /// No description provided for @chatOptimizeScript.
  ///
  /// In en, this message translates to:
  /// **'Optimize script'**
  String get chatOptimizeScript;

  /// No description provided for @chatWhatGoal.
  ///
  /// In en, this message translates to:
  /// **'What is the goal?'**
  String get chatWhatGoal;

  /// No description provided for @chatSummarizeFile.
  ///
  /// In en, this message translates to:
  /// **'Summarize file'**
  String get chatSummarizeFile;

  /// No description provided for @voiceStatusListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceStatusListening;

  /// No description provided for @voiceStatusThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get voiceStatusThinking;

  /// No description provided for @voiceStatusSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get voiceStatusSpeaking;

  /// No description provided for @voiceCameraLensMode.
  ///
  /// In en, this message translates to:
  /// **'Camera/Lens analysis mode...'**
  String get voiceCameraLensMode;

  /// No description provided for @voiceDescriptionListening.
  ///
  /// In en, this message translates to:
  /// **'I\'m listening to you'**
  String get voiceDescriptionListening;

  /// No description provided for @voiceDescriptionThinking.
  ///
  /// In en, this message translates to:
  /// **'Processing thoughts...'**
  String get voiceDescriptionThinking;

  /// No description provided for @voiceDescriptionSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Aura is speaking'**
  String get voiceDescriptionSpeaking;

  /// No description provided for @visionTitle.
  ///
  /// In en, this message translates to:
  /// **'Aura Vision'**
  String get visionTitle;

  /// No description provided for @visionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show Aura what you see.'**
  String get visionSubtitle;

  /// No description provided for @visionHistorySnackbar.
  ///
  /// In en, this message translates to:
  /// **'Vision scan history opened (Mock).'**
  String get visionHistorySnackbar;

  /// No description provided for @visionReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to understand your world'**
  String get visionReadyTitle;

  /// No description provided for @visionReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose an image and Aura will analyze what matters.'**
  String get visionReadyDesc;

  /// No description provided for @visionActionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'See With Camera'**
  String get visionActionCameraTitle;

  /// No description provided for @visionActionCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture what\'s in front of you'**
  String get visionActionCameraSubtitle;

  /// No description provided for @visionActionLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore a Photo'**
  String get visionActionLibraryTitle;

  /// No description provided for @visionActionLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose from your library'**
  String get visionActionLibrarySubtitle;

  /// No description provided for @visionQuickModesTitle.
  ///
  /// In en, this message translates to:
  /// **'How should Aura help?'**
  String get visionQuickModesTitle;

  /// No description provided for @visionRecentSightingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Sightings'**
  String get visionRecentSightingsTitle;

  /// No description provided for @visionScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get visionScanAnother;

  /// No description provided for @visionTabScene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get visionTabScene;

  /// No description provided for @visionTabObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get visionTabObjects;

  /// No description provided for @visionTabText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get visionTabText;

  /// No description provided for @visionTabContext.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get visionTabContext;

  /// No description provided for @visionResultSceneTitle.
  ///
  /// In en, this message translates to:
  /// **'What Aura Sees'**
  String get visionResultSceneTitle;

  /// No description provided for @visionResultObjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Things I Noticed'**
  String get visionResultObjectsTitle;

  /// No description provided for @visionResultTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Text I Found'**
  String get visionResultTextTitle;

  /// No description provided for @visionResultContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Why It Might Matter'**
  String get visionResultContextTitle;

  /// No description provided for @visionOcrCopied.
  ///
  /// In en, this message translates to:
  /// **'OCR text copied to clipboard!'**
  String get visionOcrCopied;

  /// No description provided for @visionTextShared.
  ///
  /// In en, this message translates to:
  /// **'Text shared successfully!'**
  String get visionTextShared;

  /// No description provided for @visionButtonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get visionButtonCopy;

  /// No description provided for @visionButtonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get visionButtonShare;

  /// No description provided for @visionNoTextDetected.
  ///
  /// In en, this message translates to:
  /// **'No visible text was detected in the photo.'**
  String get visionNoTextDetected;

  /// No description provided for @visionDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'What You Can Do Next'**
  String get visionDrawerTitle;

  /// No description provided for @visionDrawerBtnAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask Aura'**
  String get visionDrawerBtnAsk;

  /// No description provided for @visionDrawerBtnSave.
  ///
  /// In en, this message translates to:
  /// **'Save Memory'**
  String get visionDrawerBtnSave;

  /// No description provided for @visionSavedToMemory.
  ///
  /// In en, this message translates to:
  /// **'Saved sight details to Memory!'**
  String get visionSavedToMemory;

  /// No description provided for @visionDrawerBtnLog.
  ///
  /// In en, this message translates to:
  /// **'Log Journal'**
  String get visionDrawerBtnLog;

  /// No description provided for @visionScanLooking.
  ///
  /// In en, this message translates to:
  /// **'Looking at the whole scene...'**
  String get visionScanLooking;

  /// No description provided for @visionScanFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding important details...'**
  String get visionScanFinding;

  /// No description provided for @visionScanReading.
  ///
  /// In en, this message translates to:
  /// **'Reading visible text...'**
  String get visionScanReading;

  /// No description provided for @visionScanConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting what I see...'**
  String get visionScanConnecting;

  /// No description provided for @visionScanPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your insight...'**
  String get visionScanPreparing;

  /// No description provided for @visionMockTitleDesk.
  ///
  /// In en, this message translates to:
  /// **'Office Desk Setup'**
  String get visionMockTitleDesk;

  /// No description provided for @visionMockTitleNotes.
  ///
  /// In en, this message translates to:
  /// **'Handwritten Notes'**
  String get visionMockTitleNotes;

  /// No description provided for @visionMockTitlePlant.
  ///
  /// In en, this message translates to:
  /// **'Plant on Window Sill'**
  String get visionMockTitlePlant;

  /// No description provided for @visionMockSceneDesk.
  ///
  /// In en, this message translates to:
  /// **'I see a modern and clean office desk setup. There is a silver laptop open on the desk, a mechanical keyboard, and a dark ceramic coffee mug. The desk has a light wooden texture.'**
  String get visionMockSceneDesk;

  /// No description provided for @visionMockSceneNotes.
  ///
  /// In en, this message translates to:
  /// **'I see a handwritten notebook page open on a wooden table with a pen lying next to it.'**
  String get visionMockSceneNotes;

  /// No description provided for @visionMockScenePlant.
  ///
  /// In en, this message translates to:
  /// **'I see a green potted houseplant sitting on a white window sill. Sunlight is coming through the glass window pane.'**
  String get visionMockScenePlant;

  /// No description provided for @visionMockContextDesk.
  ///
  /// In en, this message translates to:
  /// **'This setup is ideal for software development or writing. The planner notes indicate a high-priority product launch deadline approaching this Friday.'**
  String get visionMockContextDesk;

  /// No description provided for @visionMockContextNotes.
  ///
  /// In en, this message translates to:
  /// **'The text captures personal development ideas on habits. This fits well with your Journal reflecting features.'**
  String get visionMockContextNotes;

  /// No description provided for @visionMockContextPlant.
  ///
  /// In en, this message translates to:
  /// **'Natural light and plants can boost productivity and mood. Fits well with your Calm mood theme.'**
  String get visionMockContextPlant;

  /// No description provided for @visionMockOcrDesk.
  ///
  /// In en, this message translates to:
  /// **'PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans'**
  String get visionMockOcrDesk;

  /// No description provided for @visionMockOcrNotes.
  ///
  /// In en, this message translates to:
  /// **'Reflections on Growth:\nChange is constant. Focus on building habits, not just achieving goals. Take small steps daily.'**
  String get visionMockOcrNotes;

  /// No description provided for @visionMockOcrPlant.
  ///
  /// In en, this message translates to:
  /// **'PLANT CARE GUIDE'**
  String get visionMockOcrPlant;

  /// No description provided for @visionMockObjLaptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get visionMockObjLaptop;

  /// No description provided for @visionMockObjKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get visionMockObjKeyboard;

  /// No description provided for @visionMockObjCoffeeMug.
  ///
  /// In en, this message translates to:
  /// **'Coffee Mug'**
  String get visionMockObjCoffeeMug;

  /// No description provided for @visionMockObjNotebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get visionMockObjNotebook;

  /// No description provided for @visionMockObjPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get visionMockObjPen;

  /// No description provided for @visionMockObjHouseplant.
  ///
  /// In en, this message translates to:
  /// **'Houseplant'**
  String get visionMockObjHouseplant;

  /// No description provided for @visionMockObjWindowSill.
  ///
  /// In en, this message translates to:
  /// **'Window Sill'**
  String get visionMockObjWindowSill;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get journalTitle;

  /// No description provided for @journalClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get journalClearFilter;

  /// No description provided for @journalReflectionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Reflection Calendar'**
  String get journalReflectionCalendar;

  /// No description provided for @journalSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search reflections...'**
  String get journalSearchPlaceholder;

  /// No description provided for @journalCelebrateSmile.
  ///
  /// In en, this message translates to:
  /// **'Celebrate what made you smile today.'**
  String get journalCelebrateSmile;

  /// No description provided for @journalRecentReflections.
  ///
  /// In en, this message translates to:
  /// **'Recent Reflections'**
  String get journalRecentReflections;

  /// No description provided for @journalNoReflections.
  ///
  /// In en, this message translates to:
  /// **'No reflections found.'**
  String get journalNoReflections;

  /// No description provided for @journalCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create a New Journal'**
  String get journalCreateNew;

  /// No description provided for @journalPrompt1.
  ///
  /// In en, this message translates to:
  /// **'What\'s one small thing that brought you peace today, and why?'**
  String get journalPrompt1;

  /// No description provided for @journalPrompt2.
  ///
  /// In en, this message translates to:
  /// **'Reflect on a recent conversation that left you feeling positive or inspired.'**
  String get journalPrompt2;

  /// No description provided for @journalPrompt3.
  ///
  /// In en, this message translates to:
  /// **'What is a challenge you faced today, and how did you handle it?'**
  String get journalPrompt3;

  /// No description provided for @journalPrompt4.
  ///
  /// In en, this message translates to:
  /// **'Write down three things you are genuinely grateful for right now.'**
  String get journalPrompt4;

  /// No description provided for @journalPrompt5.
  ///
  /// In en, this message translates to:
  /// **'How have you moved closer to your core goals this week?'**
  String get journalPrompt5;

  /// No description provided for @journalPrompt6.
  ///
  /// In en, this message translates to:
  /// **'Describe a moment today when you felt completely in the zone/focused.'**
  String get journalPrompt6;

  /// No description provided for @journalNewEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Journal Entry'**
  String get journalNewEntryTitle;

  /// No description provided for @journalFeelingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get journalFeelingQuestion;

  /// No description provided for @journalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get journalTitleLabel;

  /// No description provided for @journalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Give your entry a title...'**
  String get journalTitleHint;

  /// No description provided for @journalTitleError.
  ///
  /// In en, this message translates to:
  /// **'A title is required'**
  String get journalTitleError;

  /// No description provided for @journalThoughtsLabel.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts...'**
  String get journalThoughtsLabel;

  /// No description provided for @journalThoughtsHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, feelings, or actions...'**
  String get journalThoughtsHint;

  /// No description provided for @journalThoughtsError.
  ///
  /// In en, this message translates to:
  /// **'Write down some reflections...'**
  String get journalThoughtsError;

  /// No description provided for @journalSaveEntryBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Entry'**
  String get journalSaveEntryBtn;

  /// No description provided for @journalPromptCardHeader.
  ///
  /// In en, this message translates to:
  /// **'AI Reflection Prompt'**
  String get journalPromptCardHeader;

  /// No description provided for @journalPromptCardBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Writing'**
  String get journalPromptCardBtn;

  /// No description provided for @journalRegardingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Regarding prompt \'{prompt}\': '**
  String journalRegardingPrompt(Object prompt);

  /// No description provided for @journalCardAiInsight.
  ///
  /// In en, this message translates to:
  /// **'AI Insight'**
  String get journalCardAiInsight;

  /// No description provided for @moodTagPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get moodTagPeaceful;

  /// No description provided for @moodTagProductive.
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get moodTagProductive;

  /// No description provided for @moodTagReflective.
  ///
  /// In en, this message translates to:
  /// **'Reflective'**
  String get moodTagReflective;

  /// No description provided for @moodTagHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get moodTagHeavy;

  /// No description provided for @journalDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry'**
  String get journalDetailTitle;

  /// No description provided for @journalAuraInsight.
  ///
  /// In en, this message translates to:
  /// **'Aura AI Insight'**
  String get journalAuraInsight;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'June 2024'**
  String get calendarTitle;

  /// No description provided for @calendarAddEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Event for June {day}'**
  String calendarAddEventTitle(Object day);

  /// No description provided for @calendarEventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get calendarEventTitleHint;

  /// No description provided for @calendarTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String calendarTimeLabel(Object time);

  /// No description provided for @calendarSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get calendarSelectTime;

  /// No description provided for @calendarCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get calendarCategory;

  /// No description provided for @calendarCatJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get calendarCatJournal;

  /// No description provided for @calendarCatWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get calendarCatWorkout;

  /// No description provided for @calendarCatReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get calendarCatReflection;

  /// No description provided for @calendarCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get calendarCatOther;

  /// No description provided for @calendarCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get calendarCancel;

  /// No description provided for @calendarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get calendarAdd;

  /// No description provided for @calendarTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today, June {day}'**
  String calendarTodayLabel(Object day);

  /// No description provided for @calendarNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events scheduled for this day'**
  String get calendarNoEvents;

  /// No description provided for @calendarMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get calendarMon;

  /// No description provided for @calendarTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get calendarTue;

  /// No description provided for @calendarWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get calendarWed;

  /// No description provided for @calendarThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get calendarThu;

  /// No description provided for @calendarFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get calendarFri;

  /// No description provided for @calendarSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get calendarSat;

  /// No description provided for @calendarSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get calendarSun;

  /// No description provided for @calendarMorningJournal.
  ///
  /// In en, this message translates to:
  /// **'Morning Journal'**
  String get calendarMorningJournal;

  /// No description provided for @calendarWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get calendarWorkout;

  /// No description provided for @moodNameHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodNameHappy;

  /// No description provided for @moodDescHappy.
  ///
  /// In en, this message translates to:
  /// **'Bright and warm — radiate positivity.'**
  String get moodDescHappy;

  /// No description provided for @moodNameCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodNameCalm;

  /// No description provided for @moodDescCalm.
  ///
  /// In en, this message translates to:
  /// **'Soft blues for a peaceful mind.'**
  String get moodDescCalm;

  /// No description provided for @moodNameMotivated.
  ///
  /// In en, this message translates to:
  /// **'Motivated'**
  String get moodNameMotivated;

  /// No description provided for @moodDescMotivated.
  ///
  /// In en, this message translates to:
  /// **'Energising greens to fuel your drive.'**
  String get moodDescMotivated;

  /// No description provided for @moodNameRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get moodNameRelaxed;

  /// No description provided for @moodDescRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Gentle purples for easy-going vibes.'**
  String get moodDescRelaxed;

  /// No description provided for @moodNameReflective.
  ///
  /// In en, this message translates to:
  /// **'Reflective'**
  String get moodNameReflective;

  /// No description provided for @moodDescReflective.
  ///
  /// In en, this message translates to:
  /// **'Soft pinks for peaceful self-reflection.'**
  String get moodDescReflective;

  /// No description provided for @moodNameFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get moodNameFocused;

  /// No description provided for @moodDescFocused.
  ///
  /// In en, this message translates to:
  /// **'Bold orange and blue for laser focus.'**
  String get moodDescFocused;

  /// No description provided for @moodNameTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodNameTired;

  /// No description provided for @moodDescTired.
  ///
  /// In en, this message translates to:
  /// **'Soft greys for low-energy moments.'**
  String get moodDescTired;

  /// No description provided for @moodNameInspired.
  ///
  /// In en, this message translates to:
  /// **'Inspired'**
  String get moodNameInspired;

  /// No description provided for @moodDescInspired.
  ///
  /// In en, this message translates to:
  /// **'Deep premium reds to spark creative flow.'**
  String get moodDescInspired;

  /// No description provided for @emotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotionTitle;

  /// No description provided for @emotionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here are four core emotions for your journal'**
  String get emotionSubtitle;

  /// No description provided for @emotionGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get emotionGreat;

  /// No description provided for @emotionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get emotionGood;

  /// No description provided for @emotionOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get emotionOkay;

  /// No description provided for @emotionHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get emotionHappy;

  /// No description provided for @emotionSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get emotionSad;

  /// No description provided for @emotionCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get emotionCalm;

  /// No description provided for @emotionAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get emotionAnxious;

  /// No description provided for @homeFeelingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get homeFeelingQuestion;

  /// No description provided for @homeGrowingTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re Growing'**
  String get homeGrowingTitle;

  /// No description provided for @homeRememberTitle.
  ///
  /// In en, this message translates to:
  /// **'What I Remember About You'**
  String get homeRememberTitle;

  /// No description provided for @quickActionReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get quickActionReflection;

  /// No description provided for @quickActionGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get quickActionGrowth;

  /// No description provided for @mockMemoryPrefTitle.
  ///
  /// In en, this message translates to:
  /// **'Preference: Prefers blue aesthetic style'**
  String get mockMemoryPrefTitle;

  /// No description provided for @mockMemoryPrefTime.
  ///
  /// In en, this message translates to:
  /// **'Stored 2 days ago'**
  String get mockMemoryPrefTime;

  /// No description provided for @mockMemoryInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Insight: Project \'Phoenix\' breakdown steps'**
  String get mockMemoryInsightTitle;

  /// No description provided for @mockMemoryInsightTime.
  ///
  /// In en, this message translates to:
  /// **'Stored 5 days ago'**
  String get mockMemoryInsightTime;

  /// No description provided for @mockMemoryFactTitle.
  ///
  /// In en, this message translates to:
  /// **'Fact: Annual conference in London is Oct 12'**
  String get mockMemoryFactTitle;

  /// No description provided for @mockMemoryFactTime.
  ///
  /// In en, this message translates to:
  /// **'Stored 1 week ago'**
  String get mockMemoryFactTime;

  /// No description provided for @mockGoalSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Work Sessions'**
  String get mockGoalSessionTitle;

  /// No description provided for @mockGoalSessionSub.
  ///
  /// In en, this message translates to:
  /// **'12 / 20 hours complete this week'**
  String get mockGoalSessionSub;

  /// No description provided for @mockGoalReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading: Atomic Habits'**
  String get mockGoalReadingTitle;

  /// No description provided for @mockGoalReadingSub.
  ///
  /// In en, this message translates to:
  /// **'Chapter 4: The 1% Rule (In Progress)'**
  String get mockGoalReadingSub;

  /// No description provided for @heroGreetingDefault.
  ///
  /// In en, this message translates to:
  /// **'Hi there, friend!'**
  String get heroGreetingDefault;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileTitleEdit;

  /// No description provided for @profilePremiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get profilePremiumMember;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileAvatarUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully!'**
  String get profileAvatarUpdatedSuccess;

  /// No description provided for @profileChoosePic.
  ///
  /// In en, this message translates to:
  /// **'Choose Profile Picture'**
  String get profileChoosePic;

  /// No description provided for @profileLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileLabelName;

  /// No description provided for @profileHintName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileHintName;

  /// No description provided for @profileValNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get profileValNameRequired;

  /// No description provided for @profileLabelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileLabelEmail;

  /// No description provided for @profileHintEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get profileHintEmail;

  /// No description provided for @profileValEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get profileValEmailRequired;

  /// No description provided for @profileBtnSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileBtnSaveChanges;

  /// No description provided for @profileStatMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get profileStatMemories;

  /// No description provided for @profileStatGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get profileStatGoals;

  /// No description provided for @profileStatProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get profileStatProgress;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuSmartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get profileMenuSmartReminders;

  /// No description provided for @profileMenuPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileMenuPreferences;

  /// No description provided for @profileMenuPersonalizedForYou.
  ///
  /// In en, this message translates to:
  /// **'Personalized for you'**
  String get profileMenuPersonalizedForYou;

  /// No description provided for @profileMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileMenuLogout;

  /// No description provided for @personalityEmpathetic.
  ///
  /// In en, this message translates to:
  /// **'Empathetic'**
  String get personalityEmpathetic;

  /// No description provided for @personalityAnalytical.
  ///
  /// In en, this message translates to:
  /// **'Analytical'**
  String get personalityAnalytical;

  /// No description provided for @personalityWitty.
  ///
  /// In en, this message translates to:
  /// **'Witty'**
  String get personalityWitty;

  /// No description provided for @personalityConcise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get personalityConcise;

  /// No description provided for @personalityCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get personalityCreative;

  /// No description provided for @personalityTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Personality'**
  String get personalityTitle;

  /// No description provided for @personalitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Aura adapts to your vibe. Choose your companion\'s tone:'**
  String get personalitySubtitle;

  /// No description provided for @profileUsageInsights.
  ///
  /// In en, this message translates to:
  /// **'Usage Insights'**
  String get profileUsageInsights;

  /// No description provided for @profileUsageWeeklyChange.
  ///
  /// In en, this message translates to:
  /// **'+12% vs last week'**
  String get profileUsageWeeklyChange;

  /// No description provided for @profileUsageWeeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity this week'**
  String get profileUsageWeeklyActivity;

  /// No description provided for @avatarCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get avatarCorporate;

  /// No description provided for @avatarTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get avatarTech;

  /// No description provided for @avatarCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get avatarCreative;

  /// No description provided for @avatarNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get avatarNature;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySun;

  /// No description provided for @visionModeUnderstandScene.
  ///
  /// In en, this message translates to:
  /// **'Understand Scene'**
  String get visionModeUnderstandScene;

  /// No description provided for @visionModeReadText.
  ///
  /// In en, this message translates to:
  /// **'Read Text'**
  String get visionModeReadText;

  /// No description provided for @visionModeIdentifyObjects.
  ///
  /// In en, this message translates to:
  /// **'Identify Objects'**
  String get visionModeIdentifyObjects;

  /// No description provided for @visionModeDescribeImage.
  ///
  /// In en, this message translates to:
  /// **'Describe Image'**
  String get visionModeDescribeImage;

  /// No description provided for @visionModeFindDetails.
  ///
  /// In en, this message translates to:
  /// **'Find Details'**
  String get visionModeFindDetails;

  /// No description provided for @visionConfidenceValue.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% confidence'**
  String visionConfidenceValue(Object percentage);

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Your Files'**
  String get documentsTitle;

  /// No description provided for @documentsTryAsking.
  ///
  /// In en, this message translates to:
  /// **'Try asking Aura'**
  String get documentsTryAsking;

  /// No description provided for @documentsYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Your Knowledge'**
  String get documentsYourKnowledge;

  /// No description provided for @documentsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get documentsSeeAll;

  /// No description provided for @documentsAddFiles.
  ///
  /// In en, this message translates to:
  /// **'Add Files'**
  String get documentsAddFiles;

  /// No description provided for @documentsOcrReady.
  ///
  /// In en, this message translates to:
  /// **'{size} • {type} • Ready'**
  String documentsOcrReady(Object size, Object type);

  /// No description provided for @documentsOcrReadySimple.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get documentsOcrReadySimple;

  /// No description provided for @documentsOcrTypePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get documentsOcrTypePdf;

  /// No description provided for @documentsOcrTypeDoc.
  ///
  /// In en, this message translates to:
  /// **'DOC'**
  String get documentsOcrTypeDoc;

  /// No description provided for @documentsOcrTypeTxt.
  ///
  /// In en, this message translates to:
  /// **'TXT'**
  String get documentsOcrTypeTxt;

  /// No description provided for @documentsSuggestionSummarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize my documents'**
  String get documentsSuggestionSummarize;

  /// No description provided for @documentsSuggestionDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Find important deadlines'**
  String get documentsSuggestionDeadlines;

  /// No description provided for @documentsSuggestionMainIdeas.
  ///
  /// In en, this message translates to:
  /// **'What are the main ideas?'**
  String get documentsSuggestionMainIdeas;

  /// No description provided for @documentsSuggestionActionItems.
  ///
  /// In en, this message translates to:
  /// **'Find action items'**
  String get documentsSuggestionActionItems;

  /// No description provided for @documentsMockAskedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Asked: \"{text}\" (Mock)'**
  String documentsMockAskedSnackbar(Object text);

  /// No description provided for @documentsMockAskingSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Asking Aura about \"{name}\"...'**
  String documentsMockAskingSnackbar(Object name);

  /// No description provided for @documentsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Details'**
  String get documentsDetailTitle;

  /// No description provided for @documentsDetailWhatAuraFound.
  ///
  /// In en, this message translates to:
  /// **'What Aura Found'**
  String get documentsDetailWhatAuraFound;

  /// No description provided for @documentsDetailTakeaways.
  ///
  /// In en, this message translates to:
  /// **'AURA\'S TAKEAWAYS'**
  String get documentsDetailTakeaways;

  /// No description provided for @documentsDetailKeyConcepts.
  ///
  /// In en, this message translates to:
  /// **'KEY CONCEPTS'**
  String get documentsDetailKeyConcepts;

  /// No description provided for @documentsDetailPreview.
  ///
  /// In en, this message translates to:
  /// **'Document Preview'**
  String get documentsDetailPreview;

  /// No description provided for @documentsDetailPreviewLines.
  ///
  /// In en, this message translates to:
  /// **'This is a preview representation of the file context. Aura parsed layout lines: 1-15.\n\n'**
  String get documentsDetailPreviewLines;

  /// No description provided for @documentsDetailPreviewLorem.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam elementum dolor ac nulla tristique condimentum. In sed est et lectus accumsan fringilla. Nunc lobortis ipsum elit, id pellentesque risus molestie id. Nullam vel nulla et ante volutpat tempor. Sed vel leo purus. Praesent sit amet ipsum sit amet arcu dignissim hendrerit. Duis finibus, mi sed finibus scelerisque, sapien lorem pretium tellus, ut pellentesque risus elit non ligula.'**
  String get documentsDetailPreviewLorem;

  /// No description provided for @documentsDetailBtnAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask Aura about this document'**
  String get documentsDetailBtnAsk;

  /// No description provided for @documentsDetailStartingChat.
  ///
  /// In en, this message translates to:
  /// **'Starting contextual Chat for \"{name}\"...'**
  String documentsDetailStartingChat(Object name);

  /// No description provided for @documentsAllFiles.
  ///
  /// In en, this message translates to:
  /// **'All Files'**
  String get documentsAllFiles;

  /// No description provided for @documentsAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your files...'**
  String get documentsAskHint;

  /// No description provided for @documentsMenuAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask Aura'**
  String get documentsMenuAsk;

  /// No description provided for @documentsMenuPreview.
  ///
  /// In en, this message translates to:
  /// **'Open preview'**
  String get documentsMenuPreview;

  /// No description provided for @documentsMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get documentsMenuDelete;

  /// No description provided for @documentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Your Knowledge Space'**
  String get documentsEmptyTitle;

  /// No description provided for @documentsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Add notes, PDFs, and files so Aura can help you understand and use what matters.'**
  String get documentsEmptyDesc;

  /// No description provided for @documentsEmptyBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Your First File'**
  String get documentsEmptyBtn;

  /// No description provided for @documentsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String documentsSelectedCount(num count);

  /// No description provided for @documentsBtnSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get documentsBtnSelectAll;

  /// No description provided for @documentsBtnDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get documentsBtnDeleteSelected;

  /// No description provided for @documentsKnowledgeSpaceReady.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Space Ready.'**
  String get documentsKnowledgeSpaceReady;

  /// No description provided for @documentsActiveCount.
  ///
  /// In en, this message translates to:
  /// **'Aura is active across all {count} document(s).'**
  String documentsActiveCount(Object count);

  /// No description provided for @documentsProgressUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get documentsProgressUploading;

  /// No description provided for @documentsProgressExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting layout...'**
  String get documentsProgressExtracting;

  /// No description provided for @documentsProgressAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing context...'**
  String get documentsProgressAnalyzing;

  /// No description provided for @documentsProgressConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting orbs...'**
  String get documentsProgressConnecting;

  /// No description provided for @documentsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Knowledge'**
  String get documentsSheetTitle;

  /// No description provided for @documentsSheetDesc.
  ///
  /// In en, this message translates to:
  /// **'Aura reads your documents, extracts details, and creates a local reference index.'**
  String get documentsSheetDesc;

  /// No description provided for @documentsOptionFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF or Document'**
  String get documentsOptionFileTitle;

  /// No description provided for @documentsOptionFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Supports PDF, DOCX, TXT (Max 20MB)'**
  String get documentsOptionFileDesc;

  /// No description provided for @documentsOptionDriveTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Google Drive'**
  String get documentsOptionDriveTitle;

  /// No description provided for @documentsOptionDriveDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect and sync docs directly'**
  String get documentsOptionDriveDesc;

  /// No description provided for @documentsOptionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Document with Camera'**
  String get documentsOptionCameraTitle;

  /// No description provided for @documentsOptionCameraDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan page layout and convert to text'**
  String get documentsOptionCameraDesc;

  /// No description provided for @documentsSheetSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Your files are parsed locally on-device. No data is stored externally without permission.'**
  String get documentsSheetSecurityDesc;

  /// No description provided for @documentsSheetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get documentsSheetCancel;

  /// No description provided for @documentsAlertUploadFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a File First'**
  String get documentsAlertUploadFirstTitle;

  /// No description provided for @documentsAlertUploadFirstDesc.
  ///
  /// In en, this message translates to:
  /// **'Aura needs at least one document to read before answering Q&A requests. Please upload notes, PDFs, or files to begin.'**
  String get documentsAlertUploadFirstDesc;

  /// No description provided for @documentsAlertUploadFirstBtn.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get documentsAlertUploadFirstBtn;

  /// No description provided for @documentsFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'Files Selected'**
  String get documentsFilesSelected;

  /// No description provided for @documentsBtnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get documentsBtnClear;

  /// No description provided for @documentsBtnRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get documentsBtnRemove;

  /// No description provided for @documentsOrbDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your knowledge, connected.'**
  String get documentsOrbDefaultTitle;

  /// No description provided for @documentsOrbDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload documents and ask Aura anything about what they contain.'**
  String get documentsOrbDefaultDesc;

  /// No description provided for @documentsOrbEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Give Aura something to learn.'**
  String get documentsOrbEmptyTitle;

  /// No description provided for @documentsOrbEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload notes, PDFs, or files to build your knowledge space.'**
  String get documentsOrbEmptyDesc;

  /// No description provided for @documentsOrbAnalyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading your files...'**
  String get documentsOrbAnalyzingTitle;

  /// No description provided for @documentsOrbAnalyzingDesc.
  ///
  /// In en, this message translates to:
  /// **'Aura is indexing layout, text, and structure.'**
  String get documentsOrbAnalyzingDesc;

  /// No description provided for @documentsOrbReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to explore.'**
  String get documentsOrbReadyTitle;

  /// No description provided for @documentsOrbReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask anything across {count} selected document(s).'**
  String documentsOrbReadyDesc(Object count);

  /// No description provided for @voiceCameraSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Camera/Lens analysis mode...'**
  String get voiceCameraSnackbar;

  /// No description provided for @voiceDescListening.
  ///
  /// In en, this message translates to:
  /// **'I\'m listening to you'**
  String get voiceDescListening;

  /// No description provided for @voiceDescThinking.
  ///
  /// In en, this message translates to:
  /// **'Processing thoughts...'**
  String get voiceDescThinking;

  /// No description provided for @voiceDescSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Aura is speaking'**
  String get voiceDescSpeaking;

  /// No description provided for @voiceBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get voiceBackTooltip;

  /// No description provided for @voiceCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Camera Analysis'**
  String get voiceCameraTooltip;

  /// No description provided for @voiceMuteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mute Microphone'**
  String get voiceMuteTooltip;

  /// No description provided for @voiceUnmuteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unmute Microphone'**
  String get voiceUnmuteTooltip;

  /// No description provided for @voiceEndCallTooltip.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get voiceEndCallTooltip;

  /// No description provided for @voiceSpeakerOnTooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn Speaker On'**
  String get voiceSpeakerOnTooltip;

  /// No description provided for @voiceSpeakerOffTooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn Speaker Off'**
  String get voiceSpeakerOffTooltip;

  /// No description provided for @moodTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get moodTitle;

  /// No description provided for @moodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize Aura AI to match your current mood.'**
  String get moodSubtitle;

  /// No description provided for @moodPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get moodPreferredLanguage;

  /// No description provided for @moodChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get moodChooseLanguage;

  /// No description provided for @moodLanguageSelectDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred translation for authenticated areas.'**
  String get moodLanguageSelectDesc;

  /// No description provided for @moodBtnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get moodBtnContinue;
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
      <String>['de', 'en', 'es', 'fr', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
