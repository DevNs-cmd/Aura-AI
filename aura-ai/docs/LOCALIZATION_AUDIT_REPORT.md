# Localization Audit Report

Generated on: 2026-07-06T23:42:52.132428

## Summary
- **Total Files Scanned**: 97
- **Remaining Hardcoded Strings**: 989
- **Already Localized Strings**: 276
- **Total Candidate Strings**: 1265

## Details by File

### [locale_controller.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/localization/locale_controller.dart)
Path: `lib/core/localization/locale_controller.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 7 | Unknown | `language` | `static const String prefKey = 'language';` |

### [supported_languages.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/localization/supported_languages.dart)
Path: `lib/core/localization/supported_languages.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 34 | Unknown | `English` | `nativeName: 'English',` |
| 35 | Unknown | `English` | `englishName: 'English',` |
| 40 | Unknown | `Hindi` | `englishName: 'Hindi',` |
| 43 | Unknown | `es` | `locale: Locale('es'),` |
| 44 | Unknown | `Español` | `nativeName: 'Español',` |
| 45 | Unknown | `Spanish` | `englishName: 'Spanish',` |
| 49 | Unknown | `fr` | `locale: Locale('fr'),` |
| 50 | Unknown | `Français` | `nativeName: 'Français',` |
| 51 | Unknown | `French` | `englishName: 'French',` |

### [mood_theme_model.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/theme/mood_theme_model.dart)
Path: `lib/core/theme/mood_theme_model.dart` | Remaining hardcoded strings: **49**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 41 | Unknown | `Happy` | `'Happy',` |
| 42 | Unknown | `Calm` | `'Calm',` |
| 43 | Unknown | `Motivated` | `'Motivated',` |
| 44 | Unknown | `Relaxed` | `'Relaxed',` |
| 45 | Unknown | `Reflective` | `'Reflective',` |
| 46 | Unknown | `Focused` | `'Focused',` |
| 47 | Unknown | `Tired` | `'Tired',` |
| 48 | Unknown | `Inspired` | `'Inspired',` |
| 56 | Unknown | `Happy` | `case 'Happy':` |
| 58 | Unknown | `Happy` | `name: 'Happy',` |
| 60 | Unknown | `Bright and warm — radiate positivity.` | `description: 'Bright and warm — radiate positivity.',` |
| 73 | Unknown | `Calm` | `case 'Calm':` |
| 75 | Unknown | `Calm` | `name: 'Calm',` |
| 77 | Unknown | `Soft blues for a peaceful mind.` | `description: 'Soft blues for a peaceful mind.',` |
| 90 | Unknown | `Motivated` | `case 'Motivated':` |
| 92 | Unknown | `Motivated` | `name: 'Motivated',` |
| 94 | Unknown | `Energising greens to fuel your drive.` | `description: 'Energising greens to fuel your drive.',` |
| 107 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 109 | Unknown | `Relaxed` | `name: 'Relaxed',` |
| 111 | Unknown | `Gentle purples for easy-going vibes.` | `description: 'Gentle purples for easy-going vibes.',` |
| 124 | Unknown | `Reflective` | `case 'Reflective':` |
| 126 | Unknown | `Reflective` | `name: 'Reflective',` |
| 128 | Unknown | `Soft pinks for peaceful self-reflection.` | `description: 'Soft pinks for peaceful self-reflection.',` |
| 141 | Unknown | `Focused` | `case 'Focused':` |
| 143 | Unknown | `Focused` | `name: 'Focused',` |
| 145 | Unknown | `Bold orange and blue for laser focus.` | `description: 'Bold orange and blue for laser focus.',` |
| 158 | Unknown | `Tired` | `case 'Tired':` |
| 160 | Unknown | `Tired` | `name: 'Tired',` |
| 162 | Unknown | `Soft greys for low-energy moments.` | `description: 'Soft greys for low-energy moments.',` |
| 175 | Unknown | `Inspired` | `case 'Inspired':` |
| 177 | Unknown | `Inspired` | `name: 'Inspired',` |
| 179 | Unknown | `Deep premium reds to spark creative flow.` | `description: 'Deep premium reds to spark creative flow.',` |
| 194 | Unknown | `Happy` | `return fromMoodName('Happy');` |
| 203 | Unknown | `Happy` | `case 'Happy':` |
| 205 | Unknown | `Calm` | `case 'Calm':` |
| 207 | Unknown | `Motivated` | `case 'Motivated':` |
| 209 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 211 | Unknown | `Reflective` | `case 'Reflective':` |
| 213 | Unknown | `Focused` | `case 'Focused':` |
| 215 | Unknown | `Tired` | `case 'Tired':` |
| 217 | Unknown | `Inspired` | `case 'Inspired':` |
| 229 | Unknown | `Happy` | `case 'Happy':` |
| 231 | Unknown | `Calm` | `case 'Calm':` |
| 233 | Unknown | `Motivated` | `case 'Motivated':` |
| 235 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 237 | Unknown | `Reflective` | `case 'Reflective':` |
| 239 | Unknown | `Focused` | `case 'Focused':` |
| 241 | Unknown | `Tired` | `case 'Tired':` |
| 243 | Unknown | `Inspired` | `case 'Inspired':` |

### [theme_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/theme/theme_provider.dart)
Path: `lib/core/theme/theme_provider.dart` | Remaining hardcoded strings: **11**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 22 | Unknown | `none` | `bool get hasMoodSelected => currentMood != 'none';` |
| 48 | Unknown | `none` | `ThemeNotifier() : super(ThemeState(isDarkMode: false, currentMood: 'none')) {` |
| 54 | Unknown | `is_dark_mode` | `final isDark = _prefs?.getBool('is_dark_mode') ?? false;` |
| 55 | Unknown | `current_mood` | `final mood = _prefs?.getString('current_mood') ?? 'none';` |
| 55 | Unknown | `none` | `final mood = _prefs?.getString('current_mood') ?? 'none';` |
| 62 | Unknown | `is_dark_mode` | `await _prefs?.setBool('is_dark_mode', newIsDark);` |
| 67 | Unknown | `is_dark_mode` | `await _prefs?.setBool('is_dark_mode', isDark);` |
| 72 | Unknown | `current_mood` | `await _prefs?.setString('current_mood', mood);` |
| 76 | Unknown | `none` | `state = state.copyWith(currentMood: 'none');` |
| 77 | Unknown | `current_mood` | `await _prefs?.setString('current_mood', 'none');` |
| 77 | Unknown | `none` | `await _prefs?.setString('current_mood', 'none');` |

### [emotion_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/widgets/emotion_bar.dart)
Path: `lib/core/widgets/emotion_bar.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 37 | Unknown | `happy` | `case 'happy':` |
| 39 | Unknown | `sad` | `case 'sad':` |
| 41 | Unknown | `calm` | `case 'calm':` |
| 43 | Unknown | `anxious` | `case 'anxious':` |
| 57 | Label/Content | `Happy` | `label: 'Happy',` |
| 62 | Label/Content | `Sad` | `label: 'Sad',` |
| 67 | Label/Content | `Calm` | `label: 'Calm',` |
| 72 | Label/Content | `Anxious` | `label: 'Anxious',` |
| 213 | Unknown | `${(item.percentage * 100).toInt()}%` | `'${(item.percentage * 100).toInt()}%',` |

### [mood_landscape_illustration.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/widgets/mood_landscape_illustration.dart)
Path: `lib/core/widgets/mood_landscape_illustration.dart` | Remaining hardcoded strings: **12**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 39 | Unknown | `Happy` | `case 'Happy':` |
| 46 | Unknown | `Calm` | `case 'Calm':` |
| 53 | Unknown | `Motivated` | `case 'Motivated':` |
| 60 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 67 | Unknown | `Reflective` | `case 'Reflective':` |
| 74 | Unknown | `Focused` | `case 'Focused':` |
| 91 | Unknown | `Happy` | `case 'Happy':` |
| 94 | Unknown | `Calm` | `case 'Calm':` |
| 97 | Unknown | `Motivated` | `case 'Motivated':` |
| 100 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 103 | Unknown | `Reflective` | `case 'Reflective':` |
| 106 | Unknown | `Focused` | `case 'Focused':` |

### [auth_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/auth_provider.dart)
Path: `lib/features/auth/auth_provider.dart` | Remaining hardcoded strings: **4**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 64 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |
| 84 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |
| 100 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |
| 116 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |

### [auth_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/auth_repository.dart)
Path: `lib/features/auth/auth_repository.dart` | Remaining hardcoded strings: **14**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 26 | Unknown | `error@example.com` | `if (email == 'error@example.com') {` |
| 27 | Unknown | `Invalid credentials. Please try again.` | `throw Exception('Invalid credentials. Please try again.');` |
| 31 | Unknown | `mock-user-123` | `id: 'mock-user-123',` |
| 33 | Unknown | `Alex Rivera` | `displayName: 'Alex Rivera',` |
| 51 | Unknown | `taken` | `if (email.contains('taken')) {` |
| 52 | Unknown | `This email address is already in use.` | `throw Exception('This email address is already in use.');` |
| 56 | Unknown | `mock-user-123` | `id: 'mock-user-123',` |
| 58 | Unknown | `Alex Rivera` | `displayName: name.isNotEmpty ? name : 'Alex Rivera',` |
| 70 | Unknown | `google-user-999` | `id: 'google-user-999',` |
| 71 | Unknown | `alex.rivera.google@example.com` | `email: 'alex.rivera.google@example.com',` |
| 72 | Unknown | `Alex Rivera` | `displayName: 'Alex Rivera',` |
| 83 | Unknown | `apple-user-888` | `id: 'apple-user-888',` |
| 84 | Unknown | `alex.rivera.apple@example.com` | `email: 'alex.rivera.apple@example.com',` |
| 85 | Unknown | `Alex Rivera` | `displayName: 'Alex Rivera',` |

### [forgot_password_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/forgot_password_screen.dart)
Path: `lib/features/auth/forgot_password_screen.dart` | Remaining hardcoded strings: **11**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 143 | Unknown | `Find Your Way Back` | `'Find Your Way Back',` |
| 152 | Unknown | `We'll help you securely return to your Aura.` | `"We'll help you securely return to your Aura.",` |
| 161 | Label/Content | `Email Address` | `label: 'Email Address',` |
| 162 | Input Decoration | `name@example.com` | `hintText: 'name@example.com',` |
| 168 | Unknown | `Email address is required` | `return 'Email address is required';` |
| 170 | Unknown | `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$` | `final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');` |
| 172 | Unknown | `Enter a valid email address` | `return 'Enter a valid email address';` |
| 179 | Unknown | `Send Reset Link` | `text: 'Send Reset Link',` |
| 209 | Unknown | `Email Sent` | `'Email Sent',` |
| 219 | Unknown | `We've sent a password reset link to\n${_emailController.text.trim()}` | `"We've sent a password reset link to\n${_emailController.text.trim()}",` |
| 230 | Unknown | `Back to Sign In` | `text: 'Back to Sign In',` |

### [login_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/login_screen.dart)
Path: `lib/features/auth/login_screen.dart` | Remaining hardcoded strings: **33**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 62 | Unknown | `Email address is required` | `return 'Email address is required';` |
| 64 | Unknown | `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$` | `final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');` |
| 66 | Unknown | `Enter a valid email address` | `return 'Enter a valid email address';` |
| 73 | Unknown | `Password is required` | `return 'Password is required';` |
| 76 | Unknown | `Password must be at least 6 characters` | `return 'Password must be at least 6 characters';` |
| 83 | Unknown | `Name is required` | `return 'Name is required';` |
| 123 | Unknown | `/home` | `context.go('/home');` |
| 125 | Unknown | `/mood-selection` | `context.go('/mood-selection');` |
| 167 | Unknown | `Your Personal AI Companion` | `'Your Personal AI Companion',` |
| 247 | Interactive Control | `Sign In` | `Tab(text: 'Sign In'),` |
| 248 | Interactive Control | `Register` | `Tab(text: 'Register'),` |
| 292 | Label/Content | `Email Address` | `label: 'Email Address',` |
| 293 | Input Decoration | `name@example.com` | `hintText: 'name@example.com',` |
| 301 | Label/Content | `Password` | `label: 'Password',` |
| 330 | Unknown | `/forgot-password` | `onPressed: () => context.push('/forgot-password'),` |
| 337 | Unknown | `Forgot Password?` | `'Forgot Password?',` |
| 350 | Unknown | `Sign In` | `text: 'Sign In',` |
| 370 | Unknown | `or continue with` | `'or continue with',` |
| 390 | Unknown | `Google` | `text: 'Google',` |
| 396 | Unknown | `Apple` | `text: 'Apple',` |
| 407 | Unknown | `Don't have an account? ` | `"Don't have an account? ",` |
| 416 | Unknown | `Create Account` | `'Create Account',` |
| 439 | Label/Content | `Full Name` | `label: 'Full Name',` |
| 440 | Input Decoration | `Your Name` | `hintText: 'Your Name',` |
| 447 | Label/Content | `Email Address` | `label: 'Email Address',` |
| 448 | Input Decoration | `name@example.com` | `hintText: 'name@example.com',` |
| 456 | Label/Content | `Password` | `label: 'Password',` |
| 483 | Unknown | `Sign Up` | `text: 'Sign Up',` |
| 503 | Unknown | `or continue with` | `'or continue with',` |
| 523 | Unknown | `Google` | `text: 'Google',` |
| 529 | Unknown | `Apple` | `text: 'Apple',` |
| 540 | Unknown | `Already have an account? ` | `'Already have an account? ',` |
| 549 | Unknown | `Sign In` | `'Sign In',` |

### [onboarding_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/onboarding_screen.dart)
Path: `lib/features/auth/onboarding_screen.dart` | Remaining hardcoded strings: **20**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 49 | Unknown | `/login` | `context.go('/login');` |
| 54 | Unknown | `/login` | `context.go('/login');` |
| 94 | Unknown | `Skip` | `'Skip',` |
| 157 | Unknown | `Let's Begin` | `text: _currentPage == 3 ? 'Let\'s Begin' : 'Continue',` |
| 157 | Unknown | `Continue` | `text: _currentPage == 3 ? 'Let\'s Begin' : 'Continue',` |
| 211 | Label/Content | `Talk` | `label: 'Talk',` |
| 218 | Label/Content | `Memory` | `label: 'Memory',` |
| 227 | Label/Content | `Goals` | `label: 'Goals',` |
| 235 | Label/Content | `Reflect` | `label: 'Reflect',` |
| 251 | Unknown | `An AI Companion That Knows You` | `'An AI Companion That Knows You',` |
| 266 | Unknown | `Aura learns from your conversations and grows more helpful over time.` | `'Aura learns from your conversations and grows more helpful over time.',` |
| 308 | Unknown | `Your Journey, Remembered` | `'Your Journey, Remembered',` |
| 323 | Unknown | `Aura remembers important moments, preferences, and context that matter to you.` | `'Aura remembers important moments, preferences, and context that matter to you.',` |
| 373 | Unknown | `Hi! How can I support your day today?` | `text: "Hi! How can I support your day today?",` |
| 386 | Unknown | `Remind me to finish reading my book.` | `text: "Remind me to finish reading my book.",` |
| 399 | Unknown | `Sure! Stored in memories. Let's make time.` | `text: "Sure! Stored in memories. Let's make time.",` |
| 412 | Unknown | `Conversations With Context` | `'Conversations With Context',` |
| 427 | Unknown | `Talk naturally. Aura uses what it knows about you to provide more personal responses.` | `'Talk naturally. Aura uses what it knows about you to provide more personal responses.',` |
| 493 | Unknown | `Your Aura Is Ready` | `'Your Aura Is Ready',` |
| 508 | Unknown | `Start building a companion that understands you better every day.` | `'Start building a companion that understands you better every day.',` |

### [chat_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/chat_repository.dart)
Path: `lib/features/chat/chat_repository.dart` | Remaining hardcoded strings: **49**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 21 | Unknown | `Hello! I've analyzed your recent journal entries. You seem to be focusing on productivity. Would you like to draft a weekly summary or explore a new creative idea today?` | `: "Hello! I've analyzed your recent journal entries. You seem to be focusing on productivity. Would you like to draft a weekly summary or explore a new creative idea today?",` |
| 29 | Unknown | `Let's look at the Python script you suggested for automating my task tracking.` | `: "Let's look at the Python script you suggested for automating my task tracking.",` |
| 37 | Unknown | `Certainly! Here is the optimized version of the script with error handling and logging integrated.` | `: "Certainly! Here is the optimized version of the script with error handling and logging integrated.",` |
| 56 | Unknown | `msg-user-${DateTime.now().millisecondsSinceEpoch}` | `id: 'msg-user-${DateTime.now().millisecondsSinceEpoch}',` |
| 78 | Unknown | `I've received your request! Let know if you'd like to dive deeper or explore other goals.` | `: "I've received your request! Let know if you'd like to dive deeper or explore other goals.";` |
| 80 | Unknown | `explain` | `if (lastUserMessage.contains('explain') \|\|` |
| 81 | Unknown | `code` | `lastUserMessage.contains('code') \|\|` |
| 84 | Unknown | `यहाँ स्पष्टीकरण दिया गया है:\n\n` | `? "यहाँ स्पष्टीकरण दिया गया है:\n\n"` |
| 85 | Unknown | ````python\n` | `"```python\n"` |
| 86 | Unknown | `import logging\n\n` | `"import logging\n\n"` |
| 87 | Unknown | `# त्रुटि लॉगिंग कॉन्फ़िगर करें\n` | `"# त्रुटि लॉगिंग कॉन्फ़िगर करें\n"` |
| 88 | Unknown | `logging.basicConfig(level=logging.INFO)\n\n` | `"logging.basicConfig(level=logging.INFO)\n\n"` |
| 89 | Unknown | `def track_task(task_id):\n` | `"def track_task(task_id):\n"` |
| 90 | Unknown | `    try:\n` | `"    try:\n"` |
| 91 | Unknown | `        logging.info(f'Task {task_id} successfully started')\n` | `"        logging.info(f'Task {task_id} successfully started')\n"` |
| 92 | Unknown | `        # ट्रैकिंग तर्क यहाँ जाता है...\n` | `"        # ट्रैकिंग तर्क यहाँ जाता है...\n"` |
| 93 | Unknown | `    except Exception as e:\n` | `"    except Exception as e:\n"` |
| 94 | Unknown | `        logging.error(f'Failure: {e}')\n` | `"        logging.error(f'Failure: {e}')\n"` |
| 95 | Unknown | ````\n\n` | `"```\n\n"` |
| 97 | Unknown | `Here's the explanation:\n\n` | `: "Here's the explanation:\n\n"` |
| 98 | Unknown | ````python\n` | `"```python\n"` |
| 99 | Unknown | `import logging\n\n` | `"import logging\n\n"` |
| 100 | Unknown | `# Configure error logging\n` | `"# Configure error logging\n"` |
| 101 | Unknown | `logging.basicConfig(level=logging.INFO)\n\n` | `"logging.basicConfig(level=logging.INFO)\n\n"` |
| 102 | Unknown | `def track_task(task_id):\n` | `"def track_task(task_id):\n"` |
| 103 | Unknown | `    try:\n` | `"    try:\n"` |
| 104 | Unknown | `        logging.info(f'Task {task_id} successfully started')\n` | `"        logging.info(f'Task {task_id} successfully started')\n"` |
| 105 | Unknown | `        # Tracking logic goes here...\n` | `"        # Tracking logic goes here...\n"` |
| 106 | Unknown | `    except Exception as e:\n` | `"    except Exception as e:\n"` |
| 107 | Unknown | `        logging.error(f'Failure: {e}')\n` | `"        logging.error(f'Failure: {e}')\n"` |
| 108 | Unknown | ````\n\n` | `"```\n\n"` |
| 109 | Unknown | `This script initializes logging and encapsulates task tracking in a robust try-except wrapper.` | `"This script initializes logging and encapsulates task tracking in a robust try-except wrapper.";` |
| 110 | Unknown | `optimize` | `} else if (lastUserMessage.contains('optimize') \|\|` |
| 111 | Unknown | `script` | `lastUserMessage.contains('script') \|\|` |
| 114 | Unknown | `मैंने प्रदर्शन के लिए पायथन स्क्रिप्ट को अनुकूलित किया है। संचालन अब बैच में हैं और समानांतर में निष्पादित होते हैं:\n\n` | `? "मैंने प्रदर्शन के लिए पायथन स्क्रिप्ट को अनुकूलित किया है। संचालन अब बैच में हैं और समानांतर में निष्पादित होते हैं:\n\n"` |
| 115 | Unknown | ````python\n` | `"```python\n"` |
| 116 | Unknown | `import asyncio\n\n` | `"import asyncio\n\n"` |
| 117 | Unknown | `async def process_batch(tasks):\n` | `"async def process_batch(tasks):\n"` |
| 118 | Unknown | `    # समानांतर में कई कार्यों को निष्पादित करना\n` | `"    # समानांतर में कई कार्यों को निष्पादित करना\n"` |
| 119 | Unknown | `    results = await asyncio.gather(*[track_task(t) for t in tasks])\n` | `"    results = await asyncio.gather(*[track_task(t) for t in tasks])\n"` |
| 120 | Unknown | `    return results\n` | `"    return results\n"` |
| 122 | Unknown | `I have optimized the Python script for performance. The operations are now batched and execute in parallel:\n\n` | `: "I have optimized the Python script for performance. The operations are now batched and execute in parallel:\n\n"` |
| 123 | Unknown | ````python\n` | `"```python\n"` |
| 124 | Unknown | `import asyncio\n\n` | `"import asyncio\n\n"` |
| 125 | Unknown | `async def process_batch(tasks):\n` | `"async def process_batch(tasks):\n"` |
| 126 | Unknown | `    # Executing multiple tasks asynchronously\n` | `"    # Executing multiple tasks asynchronously\n"` |
| 127 | Unknown | `    results = await asyncio.gather(*[track_task(t) for t in tasks])\n` | `"    results = await asyncio.gather(*[track_task(t) for t in tasks])\n"` |
| 128 | Unknown | `    return results\n` | `"    return results\n"` |
| 133 | Unknown | `msg-ai-${DateTime.now().millisecondsSinceEpoch}` | `id: 'msg-ai-${DateTime.now().millisecondsSinceEpoch}',` |

### [chat_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/presentation/chat_screen.dart)
Path: `lib/features/chat/presentation/chat_screen.dart` | Remaining hardcoded strings: **15**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 88 | Unknown | `/home` | `context.go('/home');` |
| 140 | Unknown | `clear` | `if (value == 'clear') {` |
| 143 | Text Widget / Tooltip | `Chat history cleared` | `const SnackBar(content: Text('Chat history cleared')),` |
| 149 | Unknown | `clear` | `value: 'clear',` |
| 159 | Unknown | `Clear Chat` | `'Clear Chat',` |
| 208 | Unknown | `Q&A DOCUMENT CONTEXT` | `'Q&A DOCUMENT CONTEXT',` |
| 361 | Unknown | `Add Attachment` | `'Add Attachment',` |
| 378 | Label/Content | `Camera` | `label: 'Camera',` |
| 384 | Unknown | `Analyze this physical workspace setup.` | `'Analyze this physical workspace setup.',` |
| 395 | Label/Content | `Gallery` | `label: 'Gallery',` |
| 401 | Unknown | `Explain this project plan diagram.` | `'Explain this project plan diagram.',` |
| 412 | Label/Content | `Document` | `label: 'Document',` |
| 418 | Unknown | `📎 Attached: project_spec.pdf\nPlease review sections 1 and 2.` | `'📎 Attached: project_spec.pdf\nPlease review sections 1 and 2.',` |
| 427 | Label/Content | `Voice` | `label: 'Voice',` |
| 430 | Unknown | `/voice` | `context.push('/voice');` |

### [chat_bubble.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/presentation/widgets/chat_bubble.dart)
Path: `lib/features/chat/presentation/widgets/chat_bubble.dart` | Remaining hardcoded strings: **24**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 27 | Unknown | `Delete Message` | `'Delete Message',` |
| 31 | Unknown | `Are you sure you want to delete this message? This action cannot be undone.` | `'Are you sure you want to delete this message? This action cannot be undone.',` |
| 37 | Unknown | `Cancel` | `'Cancel',` |
| 47 | Text Widget / Tooltip | `Message deleted` | `).showSnackBar(const SnackBar(content: Text('Message deleted')));` |
| 50 | Unknown | `Delete` | `'Delete',` |
| 82 | Unknown | `Copy Message Text` | `'Copy Message Text',` |
| 89 | Text Widget / Tooltip | `Copied text to clipboard` | `const SnackBar(content: Text('Copied text to clipboard')),` |
| 96 | Unknown | `Share Message` | `'Share Message',` |
| 103 | Text Widget / Tooltip | `Simulated System Share API...` | `content: Text('Simulated System Share API...'),` |
| 114 | Unknown | `Delete Message` | `'Delete Message',` |
| 244 | Unknown | `roadmap` | `(message.content.toLowerCase().contains("roadmap") \|\|` |
| 245 | Unknown | `document` | `message.content.toLowerCase().contains("document") \|\|` |
| 246 | Unknown | `file` | `message.content.toLowerCase().contains("file"))) ...[` |
| 272 | Unknown | `Source: Project Roadmap.pdf • Sec 2` | `'Source: Project Roadmap.pdf • Sec 2',` |
| 293 | Unknown | `hh:mm a` | `DateFormat('hh:mm a').format(message.timestamp),` |
| 306 | Text Widget / Tooltip | `Liked message` | `const SnackBar(content: Text('Liked message')),` |
| 322 | Text Widget / Tooltip | `Regenerating...` | `content: Text('Regenerating...'),` |
| 381 | Unknown | `\n` | `final lines = part.split('\n');` |
| 382 | Unknown | `code` | `String lang = 'code';` |
| 387 | Unknown | `\n` | `codeBody = lines.sublist(1).join('\n').trim();` |
| 428 | Unknown | `Courier` | `fontFamily: 'Courier',` |
| 436 | Text Widget / Tooltip | `Copied code to clipboard` | `content: Text('Copied code to clipboard'),` |
| 449 | Unknown | `Copy` | `'Copy',` |
| 469 | Unknown | `Courier` | `fontFamily: 'Courier',` |

### [goals_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/goals_provider.dart)
Path: `lib/features/goals/goals_provider.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 58 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |

### [goals_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/goals_repository.dart)
Path: `lib/features/goals/goals_repository.dart` | Remaining hardcoded strings: **19**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 19 | Unknown | `goal-1` | `id: 'goal-1',` |
| 20 | Title/Subtitle | `Morning Yoga Routine` | `title: 'Morning Yoga Routine',` |
| 21 | Unknown | `Health` | `category: 'Health',` |
| 23 | Unknown | `15 of 20 sessions` | `statusText: '15 of 20 sessions',` |
| 24 | Unknown | `Oct 30` | `deadline: 'Oct 30',` |
| 27 | Unknown | `goal-2` | `id: 'goal-2',` |
| 28 | Title/Subtitle | `Master Flutter DSL` | `title: 'Master Flutter DSL',` |
| 29 | Unknown | `Learning` | `category: 'Learning',` |
| 31 | Unknown | `8 of 20 modules` | `statusText: '8 of 20 modules',` |
| 32 | Unknown | `Nov 12` | `deadline: 'Nov 12',` |
| 35 | Unknown | `goal-3` | `id: 'goal-3',` |
| 36 | Title/Subtitle | `Q4 Strategy Deck` | `title: 'Q4 Strategy Deck',` |
| 37 | Unknown | `Work` | `category: 'Work',` |
| 39 | Unknown | `Almost there!` | `statusText: 'Almost there!',` |
| 40 | Unknown | `Oct 25` | `deadline: 'Oct 25',` |
| 62 | Unknown | `goal-${DateTime.now().millisecondsSinceEpoch}` | `id: 'goal-${DateTime.now().millisecondsSinceEpoch}',` |
| 63 | Title/Subtitle | `New Goal` | `title: title.isEmpty ? 'New Goal' : title,` |
| 66 | Unknown | `0 of ${targetVal.toInt()} $unit` | `statusText: '0 of ${targetVal.toInt()} $unit',` |
| 67 | Unknown | `Dec 31` | `deadline: deadline.isEmpty ? 'Dec 31' : deadline,` |

### [create_goal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/create_goal_screen.dart)
Path: `lib/features/goals/presentation/create_goal_screen.dart` | Remaining hardcoded strings: **20**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 20 | Unknown | `sessions` | `final _unitController = TextEditingController(text: 'sessions');` |
| 21 | Unknown | `Dec 31` | `final _deadlineController = TextEditingController(text: 'Dec 31');` |
| 23 | Unknown | `Health` | `String _selectedCategory = 'Health';` |
| 24 | Unknown | `Health` | `final List<String> _categories = const ['Health', 'Work', 'Learning'];` |
| 24 | Unknown | `Work` | `final List<String> _categories = const ['Health', 'Work', 'Learning'];` |
| 24 | Unknown | `Learning` | `final List<String> _categories = const ['Health', 'Work', 'Learning'];` |
| 71 | Unknown | `New Goal` | `'New Goal',` |
| 89 | Unknown | `Category Focus` | `'Category Focus',` |
| 142 | Label/Content | `Goal Title` | `label: 'Goal Title',` |
| 143 | Input Decoration | `e.g. Master Flutter DSL` | `hintText: 'e.g. Master Flutter DSL',` |
| 147 | Unknown | `A title is required` | `return 'A title is required';` |
| 159 | Label/Content | `Target Goal Value` | `label: 'Target Goal Value',` |
| 165 | Unknown | `Enter a number` | `return 'Enter a number';` |
| 174 | Label/Content | `Unit of Measure` | `label: 'Unit of Measure',` |
| 175 | Input Decoration | `sessions` | `hintText: 'sessions',` |
| 179 | Unknown | `Unit is required` | `return 'Unit is required';` |
| 191 | Label/Content | `Target Date / Deadline` | `label: 'Target Date / Deadline',` |
| 192 | Input Decoration | `e.g. Oct 30` | `hintText: 'e.g. Oct 30',` |
| 196 | Unknown | `A target date is required` | `return 'A target date is required';` |
| 205 | Unknown | `Save Goal` | `text: 'Save Goal',` |

### [goals_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/goals_screen.dart)
Path: `lib/features/goals/presentation/goals_screen.dart` | Remaining hardcoded strings: **14**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 22 | Unknown | `All` | `final String _statusFilter = 'All';` |
| 23 | Unknown | `All` | `final String _categoryFilter = 'All';` |
| 34 | Unknown | `Active` | `if (_statusFilter == 'Active' && g.isCompleted) return false;` |
| 35 | Unknown | `Completed` | `if (_statusFilter == 'Completed' && !g.isCompleted) return false;` |
| 36 | Unknown | `All` | `if (_categoryFilter != 'All' && g.category != _categoryFilter) {` |
| 52 | Unknown | `My Goals` | `'My Goals',` |
| 71 | Unknown | `You're making great progress!` | `"You're making great progress!",` |
| 117 | Text Widget / Tooltip | `Goal progress updated!` | `content: Text('Goal progress updated!'),` |
| 136 | Title/Subtitle | `Completed` | `title: 'Completed',` |
| 146 | Title/Subtitle | `Focus Time` | `title: 'Focus Time',` |
| 147 | Unknown | `32h` | `value: '32h',` |
| 156 | Title/Subtitle | `Streak` | `title: 'Streak',` |
| 157 | Unknown | `12d` | `value: '12d',` |
| 175 | Unknown | `+ Add New Goal` | `text: '+ Add New Goal',` |

### [goal_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/goal_detail_screen.dart)
Path: `lib/features/goals/presentation/goal_detail_screen.dart` | Remaining hardcoded strings: **25**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 18 | Unknown | `title` | `{'title': 'Establish baseline sessions', 'completed': true},` |
| 18 | Unknown | `Establish baseline sessions` | `{'title': 'Establish baseline sessions', 'completed': true},` |
| 18 | Unknown | `completed` | `{'title': 'Establish baseline sessions', 'completed': true},` |
| 19 | Unknown | `title` | `{'title': 'Maintain a 5-day session streak', 'completed': true},` |
| 19 | Unknown | `Maintain a 5-day session streak` | `{'title': 'Maintain a 5-day session streak', 'completed': true},` |
| 19 | Unknown | `completed` | `{'title': 'Maintain a 5-day session streak', 'completed': true},` |
| 20 | Unknown | `title` | `{'title': 'Log 15 sessions in total', 'completed': goal.progress >= 0.75},` |
| 20 | Unknown | `Log 15 sessions in total` | `{'title': 'Log 15 sessions in total', 'completed': goal.progress >= 0.75},` |
| 20 | Unknown | `completed` | `{'title': 'Log 15 sessions in total', 'completed': goal.progress >= 0.75},` |
| 22 | Unknown | `title` | `'title': 'Reach final target (20 sessions)',` |
| 22 | Unknown | `Reach final target (20 sessions)` | `'title': 'Reach final target (20 sessions)',` |
| 23 | Unknown | `completed` | `'completed': goal.progress >= 1.0,` |
| 41 | Unknown | `/home` | `context.go('/home');` |
| 46 | Unknown | `Goal Details` | `'Goal Details',` |
| 63 | Text Widget / Tooltip | `Delete Goal` | `title: const Text('Delete Goal'),` |
| 65 | Unknown | `Are you sure you want to delete this goal? This action cannot be undone.` | `'Are you sure you want to delete this goal? This action cannot be undone.',` |
| 70 | Text Widget / Tooltip | `Cancel` | `child: const Text('Cancel'),` |
| 77 | Text Widget / Tooltip | `Goal deleted` | `const SnackBar(content: Text('Goal deleted')),` |
| 82 | Unknown | `Delete` | `'Delete',` |
| 155 | Unknown | `${(goal.progress * 100).toInt()}%` | `'${(goal.progress * 100).toInt()}%',` |
| 181 | Unknown | `Milestones` | `'Milestones',` |
| 212 | Unknown | `completed` | `final bool done = item['completed'];` |
| 229 | Unknown | `title` | `item['title'],` |
| 255 | Unknown | `Log Session Progress` | `text: 'Log Session Progress',` |
| 262 | Text Widget / Tooltip | `Goal progress updated!` | `const SnackBar(content: Text('Goal progress updated!')),` |

### [category_focus_chart.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/widgets/category_focus_chart.dart)
Path: `lib/features/goals/presentation/widgets/category_focus_chart.dart` | Remaining hardcoded strings: **4**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 22 | Unknown | `Category Focus` | `'Category Focus',` |
| 48 | Label/Content | `Work` | `label: 'Work',` |
| 54 | Label/Content | `Health` | `label: 'Health',` |
| 60 | Label/Content | `Learning` | `label: 'Learning',` |

### [goal_tile.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/widgets/goal_tile.dart)
Path: `lib/features/goals/presentation/widgets/goal_tile.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 78 | Unknown | `${(goal.progress * 100).toInt()}%` | `'${(goal.progress * 100).toInt()}%',` |

### [productivity_chart.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/widgets/productivity_chart.dart)
Path: `lib/features/goals/presentation/widgets/productivity_chart.dart` | Remaining hardcoded strings: **8**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 27 | Unknown | `Productivity Score` | `'Productivity Score',` |
| 90 | Unknown | `M` | `'M',` |
| 98 | Unknown | `T` | `'T',` |
| 106 | Unknown | `W` | `'W',` |
| 114 | Unknown | `T` | `'T',` |
| 122 | Unknown | `F` | `'F',` |
| 130 | Unknown | `S` | `'S',` |
| 138 | Unknown | `S` | `'S',` |

### [calendar_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/calendar_screen.dart)
Path: `lib/features/home/calendar_screen.dart` | Remaining hardcoded strings: **10**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 44 | Unknown | `08:00 AM` | `time: '08:00 AM',` |
| 51 | Unknown | `07:00 PM` | `time: '07:00 PM',` |
| 66 | Unknown | `Journal` | `String selectedCategory = 'Journal';` |
| 169 | Unknown | `Journal` | `'Journal': AppLocalizations.of(context)!.calendarCatJournal,` |
| 170 | Unknown | `Workout` | `'Workout': AppLocalizations.of(context)!.calendarCatWorkout,` |
| 171 | Unknown | `Reflection` | `'Reflection': AppLocalizations.of(context)!.calendarCatReflection,` |
| 172 | Unknown | `Other` | `'Other': AppLocalizations.of(context)!.calendarCatOther,` |
| 208 | Unknown | `Journal` | `if (selectedCategory == 'Journal') {` |
| 211 | Unknown | `Workout` | `} else if (selectedCategory == 'Workout') {` |
| 214 | Unknown | `Reflection` | `} else if (selectedCategory == 'Reflection') {` |

### [documents_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/documents_screen.dart)
Path: `lib/features/home/documents_screen.dart` | Remaining hardcoded strings: **56**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 28 | Unknown | `name` | `{'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},` |
| 28 | Unknown | `Project Roadmap.pdf` | `{'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},` |
| 28 | Unknown | `size` | `{'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},` |
| 28 | Unknown | `2.4 MB` | `{'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},` |
| 28 | Unknown | `type` | `{'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},` |
| 28 | Unknown | `PDF` | `{'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},` |
| 29 | Unknown | `name` | `{'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},` |
| 29 | Unknown | `Flutter Guide.docx` | `{'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},` |
| 29 | Unknown | `size` | `{'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},` |
| 29 | Unknown | `1.1 MB` | `{'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},` |
| 29 | Unknown | `type` | `{'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},` |
| 29 | Unknown | `DOCX` | `{'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},` |
| 30 | Unknown | `name` | `{'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},` |
| 30 | Unknown | `Notes.txt` | `{'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},` |
| 30 | Unknown | `size` | `{'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},` |
| 30 | Unknown | `320 KB` | `{'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},` |
| 30 | Unknown | `type` | `{'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},` |
| 30 | Unknown | `TXT` | `{'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},` |
| 31 | Unknown | `name` | `{'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},` |
| 31 | Unknown | `Design Ideas.pdf` | `{'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},` |
| 31 | Unknown | `size` | `{'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},` |
| 31 | Unknown | `1.8 MB` | `{'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},` |
| 31 | Unknown | `type` | `{'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},` |
| 31 | Unknown | `PDF` | `{'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},` |
| 53 | Unknown | `Uploaded Doc_${_documents.length + 1}.pdf` | `_uploadingFileName = 'Uploaded Doc_${_documents.length + 1}.pdf';` |
| 65 | Unknown | `name` | `'name': _uploadingFileName!,` |
| 66 | Unknown | `size` | `'size': '1.5 MB',` |
| 66 | Unknown | `1.5 MB` | `'size': '1.5 MB',` |
| 67 | Unknown | `type` | `'type': 'PDF',` |
| 67 | Unknown | `PDF` | `'type': 'PDF',` |
| 73 | Text Widget / Tooltip | `Document successfully parsed and indexed!` | `content: Text('Document successfully parsed and indexed!'),` |
| 82 | Unknown | `name` | `_documents.removeWhere((doc) => doc['name'] == name);` |
| 87 | Text Widget / Tooltip | `Removed "$name" from workspace.` | `).showSnackBar(SnackBar(content: Text('Removed "$name" from workspace.')));` |
| 93 | Unknown | `name` | `_documents.removeWhere((doc) => _selectedFileNames.contains(doc['name']));` |
| 97 | Text Widget / Tooltip | `Removed $count document(s) from workspace.` | `SnackBar(content: Text('Removed $count document(s) from workspace.')),` |
| 109 | Unknown | `name` | `final name = (doc['name'] as String).toLowerCase();` |
| 138 | Input Decoration | `Search files...` | `hintText: 'Search files...',` |
| 153 | Unknown | `Ask Your Files` | `'Ask Your Files',` |
| 188 | Unknown | `select` | `if (val == 'select') {` |
| 191 | Unknown | `name` | `_documents.map((d) => d['name'] as String),` |
| 196 | Text Widget / Tooltip | `Action "$val" selected (Mock).` | `SnackBar(content: Text('Action "$val" selected (Mock).')),` |
| 201 | Text Widget / Tooltip | `select` | `PopupMenuItem(value: 'select', child: Text('Select All')),` |
| 201 | Text Widget / Tooltip | `Select All` | `PopupMenuItem(value: 'select', child: Text('Select All')),` |
| 202 | Text Widget / Tooltip | `sort` | `PopupMenuItem(value: 'sort', child: Text('Sort Files')),` |
| 202 | Text Widget / Tooltip | `Sort Files` | `PopupMenuItem(value: 'sort', child: Text('Sort Files')),` |
| 203 | Text Widget / Tooltip | `storage` | `PopupMenuItem(value: 'storage', child: Text('Storage Info')),` |
| 203 | Text Widget / Tooltip | `Storage Info` | `PopupMenuItem(value: 'storage', child: Text('Storage Info')),` |
| 372 | Unknown | `name` | `final docName = doc['name'] as String;` |
| 390 | Unknown | `size` | `size: doc['size'] as String,` |
| 391 | Unknown | `type` | `type: doc['type'] as String,` |
| 395 | Unknown | `/document-detail` | `'/document-detail',` |
| 397 | Unknown | `name` | `'name': docName,` |
| 398 | Unknown | `size` | `'size': doc['size'] as String,` |
| 398 | Unknown | `size` | `'size': doc['size'] as String,` |
| 399 | Unknown | `type` | `'type': doc['type'] as String,` |
| 399 | Unknown | `type` | `'type': doc['type'] as String,` |

### [document_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/document_detail_screen.dart)
Path: `lib/features/home/document_detail_screen.dart` | Remaining hardcoded strings: **30**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 31 | Unknown | `PDF` | `if (type.toUpperCase() == 'PDF') {` |
| 34 | Unknown | `DOC` | `} else if (type.toUpperCase() == 'DOC' \|\| type.toUpperCase() == 'DOCX') {` |
| 34 | Unknown | `DOCX` | `} else if (type.toUpperCase() == 'DOC' \|\| type.toUpperCase() == 'DOCX') {` |
| 37 | Unknown | `TXT` | `} else if (type.toUpperCase() == 'TXT') {` |
| 44 | Unknown | `Initial architectural layouts, dependencies mapping, and routing endpoints.` | `"Initial architectural layouts, dependencies mapping, and routing endpoints.",` |
| 45 | Unknown | `Identifies standard specifications, UI assets scaling constraints, and lints policies.` | `"Identifies standard specifications, UI assets scaling constraints, and lints policies.",` |
| 46 | Unknown | `Contains details of local preferences syncing states with shared device memory.` | `"Contains details of local preferences syncing states with shared device memory.",` |
| 49 | Unknown | `Roadmap` | `if (name.contains("Roadmap")) {` |
| 51 | Unknown | `Milestones timeline stretching from baseline discovery to final verification phases.` | `"Milestones timeline stretching from baseline discovery to final verification phases.",` |
| 52 | Unknown | `Highlights key deliverables for Chat interface elements and locale translation sheets.` | `"Highlights key deliverables for Chat interface elements and locale translation sheets.",` |
| 53 | Unknown | `Identifies resource dependencies, test suite execution constraints, and handoff criteria.` | `"Identifies resource dependencies, test suite execution constraints, and handoff criteria.",` |
| 55 | Unknown | `Guide` | `} else if (name.contains("Guide")) {` |
| 57 | Unknown | `Standard conventions for writing Riverpod controllers and binding GoRouter scopes.` | `"Standard conventions for writing Riverpod controllers and binding GoRouter scopes.",` |
| 58 | Unknown | `Details layout scaling, custom painters usage, and theme colors mapping constraints.` | `"Details layout scaling, custom painters usage, and theme colors mapping constraints.",` |
| 59 | Unknown | `Comprehensive walkthrough of setting up mock classes inside testing suites.` | `"Comprehensive walkthrough of setting up mock classes inside testing suites.",` |
| 63 | Unknown | `Roadmap` | `final List<String> keyConcepts = name.contains("Roadmap")` |
| 64 | Unknown | `Timeline` | `? ["Timeline", "Deliverables", "Phases", "Handoff"]` |
| 64 | Unknown | `Deliverables` | `? ["Timeline", "Deliverables", "Phases", "Handoff"]` |
| 64 | Unknown | `Phases` | `? ["Timeline", "Deliverables", "Phases", "Handoff"]` |
| 64 | Unknown | `Handoff` | `? ["Timeline", "Deliverables", "Phases", "Handoff"]` |
| 65 | Unknown | `Guide` | `: name.contains("Guide")` |
| 66 | Unknown | `Riverpod` | `? ["Riverpod", "GoRouter", "Theme", "Testing"]` |
| 66 | Unknown | `GoRouter` | `? ["Riverpod", "GoRouter", "Theme", "Testing"]` |
| 66 | Unknown | `Theme` | `? ["Riverpod", "GoRouter", "Theme", "Testing"]` |
| 66 | Unknown | `Testing` | `? ["Riverpod", "GoRouter", "Theme", "Testing"]` |
| 67 | Unknown | `Notes` | `: ["Notes", "Draft", "Concepts", "Reference"];` |
| 67 | Unknown | `Draft` | `: ["Notes", "Draft", "Concepts", "Reference"];` |
| 67 | Unknown | `Concepts` | `: ["Notes", "Draft", "Concepts", "Reference"];` |
| 67 | Unknown | `Reference` | `: ["Notes", "Draft", "Concepts", "Reference"];` |
| 319 | Unknown | `/chat` | `context.push('/chat');` |

### [explore_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/explore_screen.dart)
Path: `lib/features/home/explore_screen.dart` | Remaining hardcoded strings: **5**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 116 | Unknown | `/chat` | `onTap: () => context.push('/chat'),` |
| 127 | Unknown | `/vision` | `onTap: () => context.push('/vision'),` |
| 138 | Unknown | `/documents` | `onTap: () => context.push('/documents'),` |
| 149 | Unknown | `/voice` | `onTap: () => context.push('/voice'),` |
| 222 | Unknown | `/chat` | `context.push('/chat');` |

### [home_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/home_screen.dart)
Path: `lib/features/home/home_screen.dart` | Remaining hardcoded strings: **8**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 96 | Unknown | `/chat` | `context.push('/chat');` |
| 105 | Unknown | `/voice` | `context.push('/voice');` |
| 114 | Unknown | `/vision` | `context.push('/vision');` |
| 392 | Unknown | `Jose Maria` | `final userName = authState.user?.displayName ?? 'Jose Maria';` |
| 431 | Unknown | `/profile` | `onTap: () => context.push('/profile'),` |
| 465 | Unknown | `E` | `'E',` |
| 469 | Unknown | `d` | `'d',` |
| 479 | Unknown | `/calendar` | `context.push('/calendar');` |

### [aura_document_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/aura_document_card.dart)
Path: `lib/features/home/widgets/ask_your_files/aura_document_card.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 37 | Unknown | `PDF` | `if (type.toUpperCase() == 'PDF') {` |
| 40 | Unknown | `DOC` | `} else if (type.toUpperCase() == 'DOC' \|\| type.toUpperCase() == 'DOCX') {` |
| 40 | Unknown | `DOCX` | `} else if (type.toUpperCase() == 'DOC' \|\| type.toUpperCase() == 'DOCX') {` |
| 43 | Unknown | `TXT` | `} else if (type.toUpperCase() == 'TXT') {` |
| 145 | Unknown | `delete` | `if (val == 'delete' && onDelete != null) {` |
| 147 | Unknown | `ask` | `} else if (val == 'ask' && onAskAura != null) {` |
| 153 | Unknown | `ask` | `value: 'ask',` |
| 173 | Unknown | `open` | `value: 'open',` |
| 188 | Unknown | `delete` | `value: 'delete',` |

### [document_selection_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/document_selection_bar.dart)
Path: `lib/features/home/widgets/ask_your_files/document_selection_bar.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 54 | Unknown | `$selectedCount` | `'$selectedCount',` |

### [upload_progress_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/upload_progress_card.dart)
Path: `lib/features/home/widgets/ask_your_files/upload_progress_card.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 143 | Unknown | `${(_progressValue * 100).toInt()}%` | `'${(_progressValue * 100).toInt()}%',` |

### [upload_source_sheet.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/upload_source_sheet.dart)
Path: `lib/features/home/widgets/ask_your_files/upload_source_sheet.dart` | Remaining hardcoded strings: **3**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 67 | Unknown | `File` | `onTap: () => onSourceSelected('File'),` |
| 76 | Unknown | `Drive` | `onTap: () => onSourceSelected('Drive'),` |
| 85 | Unknown | `Camera` | `onTap: () => onSourceSelected('Camera'),` |

### [hero_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/hero_card.dart)
Path: `lib/features/home/widgets/hero_card.dart` | Remaining hardcoded strings: **7**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 16 | Unknown | `Happy` | `case 'Happy':` |
| 18 | Unknown | `Calm` | `case 'Calm':` |
| 20 | Unknown | `Motivated` | `case 'Motivated':` |
| 22 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 24 | Unknown | `Reflective` | `case 'Reflective':` |
| 26 | Unknown | `Focused` | `case 'Focused':` |
| 77 | Unknown | `none` | `themeState.currentMood == 'none'` |

### [mood_selector.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/mood_selector.dart)
Path: `lib/features/home/widgets/mood_selector.dart` | Remaining hardcoded strings: **12**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 19 | Label/Content | `Happy` | `MoodItem(label: 'Happy', emoji: '😊'),` |
| 20 | Label/Content | `Calm` | `MoodItem(label: 'Calm', emoji: '☁️'),` |
| 21 | Label/Content | `Motivated` | `MoodItem(label: 'Motivated', emoji: '🌱'),` |
| 22 | Label/Content | `Relaxed` | `MoodItem(label: 'Relaxed', emoji: '🌙'),` |
| 23 | Label/Content | `Reflective` | `MoodItem(label: 'Reflective', emoji: '🌧️'),` |
| 24 | Label/Content | `Focused` | `MoodItem(label: 'Focused', emoji: '⚡'),` |
| 31 | Unknown | `Happy` | `case 'Happy':` |
| 33 | Unknown | `Calm` | `case 'Calm':` |
| 35 | Unknown | `Motivated` | `case 'Motivated':` |
| 37 | Unknown | `Relaxed` | `case 'Relaxed':` |
| 39 | Unknown | `Reflective` | `case 'Reflective':` |
| 41 | Unknown | `Focused` | `case 'Focused':` |

### [quick_actions.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/quick_actions.dart)
Path: `lib/features/home/widgets/quick_actions.dart` | Remaining hardcoded strings: **12**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 29 | Unknown | `voice` | `case 'voice':` |
| 31 | Unknown | `vision` | `case 'vision':` |
| 33 | Unknown | `reflection` | `case 'reflection':` |
| 35 | Unknown | `growth` | `case 'growth':` |
| 50 | Label/Content | `Voice` | `label: 'Voice',` |
| 52 | Unknown | `voice` | `onTap: () => onActionSelected?.call('voice'),` |
| 55 | Label/Content | `Vision` | `label: 'Vision',` |
| 57 | Unknown | `vision` | `onTap: () => onActionSelected?.call('vision'),` |
| 60 | Label/Content | `Reflection` | `label: 'Reflection',` |
| 62 | Unknown | `journal` | `onTap: () => onActionSelected?.call('journal'),` |
| 65 | Label/Content | `Growth` | `label: 'Growth',` |
| 67 | Unknown | `goals` | `onTap: () => onActionSelected?.call('goals'),` |

### [journal_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/journal_provider.dart)
Path: `lib/features/journal/journal_provider.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 50 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |

### [journal_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/journal_repository.dart)
Path: `lib/features/journal/journal_repository.dart` | Remaining hardcoded strings: **27**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 13 | Unknown | `journal-1` | `id: 'journal-1',` |
| 14 | Title/Subtitle | `A Morning Walk in the Park` | `title: 'A Morning Walk in the Park',` |
| 16 | Unknown | `The air was crisp and the golden leaves were falling. I felt a profound sense of connection with nature as I wandered along the paths. Taking time away from my desk made me realize how important offline breaks are for long-term sustainability.` | `'The air was crisp and the golden leaves were falling. I felt a profound sense of connection with nature as I wandered along the paths. Taking time away from my desk made me realize how important offline breaks are for long-term sustainability.',` |
| 18 | Unknown | `Good` | `mood: 'Good', // Mapped to 'Good' mood icon` |
| 20 | Unknown | `Your heart rate and mental clarity improve significantly during early outdoor activities. Schedule more walks.` | `'Your heart rate and mental clarity improve significantly during early outdoor activities. Schedule more walks.',` |
| 23 | Unknown | `journal-2` | `id: 'journal-2',` |
| 24 | Title/Subtitle | `Project Milestone Reached` | `title: 'Project Milestone Reached',` |
| 26 | Unknown | `Finally finished the core architecture for the new project. It's been a long week of debugging and refactoring, but getting this built makes all the work worthwhile.` | `'Finally finished the core architecture for the new project. It\'s been a long week of debugging and refactoring, but getting this built makes all the work worthwhile.',` |
| 28 | Unknown | `Great` | `mood: 'Great',` |
| 30 | Unknown | `Completing big blocks of logic boosts your momentum. Break next milestones into similar chunks.` | `'Completing big blocks of logic boosts your momentum. Break next milestones into similar chunks.',` |
| 33 | Unknown | `journal-3` | `id: 'journal-3',` |
| 34 | Title/Subtitle | `Coffee with an Old Friend` | `title: 'Coffee with an Old Friend',` |
| 36 | Unknown | `We haven't talked in years. It was strange yet so familiar. We discussed our future plans and reminisced about old school days. Realized that strong social bonds really keep me grounded.` | `'We haven\'t talked in years. It was strange yet so familiar. We discussed our future plans and reminisced about old school days. Realized that strong social bonds really keep me grounded.',` |
| 38 | Unknown | `Okay` | `mood: 'Okay',` |
| 40 | Unknown | `Reconnecting with old connections provides emotional stability and reduces baseline stress levels.` | `'Reconnecting with old connections provides emotional stability and reduces baseline stress levels.',` |
| 58 | Unknown | `journal-${DateTime.now().millisecondsSinceEpoch}` | `id: 'journal-${DateTime.now().millisecondsSinceEpoch}',` |
| 59 | Title/Subtitle | `Untitled Entry` | `title: title.isEmpty ? 'Untitled Entry' : title,` |
| 74 | Unknown | `stress` | `if (lower.contains('stress') \|\|` |
| 75 | Unknown | `tired` | `lower.contains('tired') \|\|` |
| 76 | Unknown | `exhausted` | `lower.contains('exhausted')) {` |
| 77 | Unknown | `It seems you are feeling overwhelmed. Prioritize sleep and schedule a brief break to reset.` | `return 'It seems you are feeling overwhelmed. Prioritize sleep and schedule a brief break to reset.';` |
| 79 | Unknown | `happy` | `if (lower.contains('happy') \|\|` |
| 80 | Unknown | `excited` | `lower.contains('excited') \|\|` |
| 81 | Unknown | `great` | `lower.contains('great') \|\|` |
| 82 | Unknown | `accomplished` | `lower.contains('accomplished')) {` |
| 83 | Unknown | `You are in a positive state. Capitalize on this energy for creative tasks today.` | `return 'You are in a positive state. Capitalize on this energy for creative tasks today.';` |
| 85 | Unknown | `Regular reflection keeps you aligned. Continue tracking your daily thoughts to notice weekly trends.` | `return 'Regular reflection keeps you aligned. Continue tracking your daily thoughts to notice weekly trends.';` |

### [create_journal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/create_journal_screen.dart)
Path: `lib/features/journal/presentation/create_journal_screen.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 24 | Unknown | `Happy` | `String _selectedMood = 'Happy';` |
| 50 | Unknown | `Happy` | `case 'Happy':` |
| 52 | Unknown | `Sad` | `case 'Sad':` |
| 54 | Unknown | `Calm` | `case 'Calm':` |
| 56 | Unknown | `Anxious` | `case 'Anxious':` |
| 116 | Unknown | `Happy` | `'Happy',` |
| 123 | Unknown | `Sad` | `'Sad',` |
| 130 | Unknown | `Calm` | `'Calm',` |
| 137 | Unknown | `Anxious` | `'Anxious',` |

### [journal_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/journal_detail_screen.dart)
Path: `lib/features/journal/presentation/journal_detail_screen.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 15 | Unknown | `Great` | `case 'Great':` |
| 17 | Unknown | `Good` | `case 'Good':` |
| 19 | Unknown | `Okay` | `case 'Okay':` |
| 21 | Unknown | `Sad` | `case 'Sad':` |
| 31 | Unknown | `Great` | `case 'Great':` |
| 33 | Unknown | `Good` | `case 'Good':` |
| 35 | Unknown | `Okay` | `case 'Okay':` |
| 37 | Unknown | `Sad` | `case 'Sad':` |
| 81 | Unknown | `EEEE, MMMM dd, yyyy` | `DateFormat('EEEE, MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(entry.createdAt),` |

### [journal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/journal_screen.dart)
Path: `lib/features/journal/presentation/journal_screen.dart` | Remaining hardcoded strings: **3**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 171 | Unknown | `E` | `final dayOfWeek = DateFormat('E', Localizations.localeOf(context).toString()).format(date);` |
| 172 | Unknown | `d` | `final dayOfMonth = DateFormat('d', Localizations.localeOf(context).toString()).format(date);` |
| 445 | Unknown | `/create-journal` | `onPressed: () => context.push('/create-journal'),` |

### [journal_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/journal_card.dart)
Path: `lib/features/journal/presentation/widgets/journal_card.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 24 | Unknown | `Great` | `case 'Great':` |
| 26 | Unknown | `Good` | `case 'Good':` |
| 28 | Unknown | `Okay` | `case 'Okay':` |
| 30 | Unknown | `Sad` | `case 'Sad':` |
| 40 | Unknown | `Great` | `case 'Great':` |
| 42 | Unknown | `Good` | `case 'Good':` |
| 44 | Unknown | `Okay` | `case 'Okay':` |
| 46 | Unknown | `Sad` | `case 'Sad':` |
| 90 | Unknown | `MMMM dd, yyyy` | `DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(entry.createdAt),` |

### [mood_selector.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/mood_selector.dart)
Path: `lib/features/journal/presentation/widgets/mood_selector.dart` | Remaining hardcoded strings: **8**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 23 | Label/Content | `Great` | `JournalMoodItem(label: 'Great', emoji: '🤩'),` |
| 24 | Label/Content | `Good` | `JournalMoodItem(label: 'Good', emoji: '😊'),` |
| 25 | Label/Content | `Okay` | `JournalMoodItem(label: 'Okay', emoji: '😐'),` |
| 26 | Label/Content | `Sad` | `JournalMoodItem(label: 'Sad', emoji: '😔'),` |
| 32 | Unknown | `Great` | `case 'Great':` |
| 34 | Unknown | `Good` | `case 'Good':` |
| 36 | Unknown | `Okay` | `case 'Okay':` |
| 38 | Unknown | `Sad` | `case 'Sad':` |

### [writing_prompt_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/writing_prompt_card.dart)
Path: `lib/features/journal/presentation/widgets/writing_prompt_card.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 88 | Unknown | `What's one small thing that brought you peace today, and why?` | `promptText.isEmpty \|\| promptText == "What's one small thing that brought you peace today, and why?"` |

### [memory_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/memory_provider.dart)
Path: `lib/features/memory/memory_provider.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 62 | Unknown | `Exception: ` | `errorMessage: e.toString().replaceAll('Exception: ', ''),` |

### [memory_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/memory_repository.dart)
Path: `lib/features/memory/memory_repository.dart` | Remaining hardcoded strings: **11**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 20 | Unknown | `mem-1` | `id: 'mem-1',` |
| 21 | Title/Subtitle | `Favorite Coffee Order` | `title: 'Favorite Coffee Order',` |
| 23 | Unknown | `You prefer a Double Espresso with a dash of oat milk, not too hot.` | `'You prefer a Double Espresso with a dash of oat milk, not too hot.',` |
| 30 | Unknown | `mem-2` | `id: 'mem-2',` |
| 31 | Title/Subtitle | `Project 'Aegis' Deadline` | `title: "Project 'Aegis' Deadline",` |
| 33 | Unknown | `The final submission for Project Aegis is due on Friday, Nov 15th at 5 PM EST.` | `'The final submission for Project Aegis is due on Friday, Nov 15th at 5 PM EST.',` |
| 40 | Unknown | `mem-3` | `id: 'mem-3',` |
| 41 | Title/Subtitle | `Interest: Brutalism` | `title: 'Interest: Brutalism',` |
| 43 | Unknown | `You showed a strong interest in Brutalist architecture design styles and structural concrete aesthetics.` | `'You showed a strong interest in Brutalist architecture design styles and structural concrete aesthetics.',` |
| 67 | Unknown | `mem-${DateTime.now().millisecondsSinceEpoch}` | `id: 'mem-${DateTime.now().millisecondsSinceEpoch}',` |
| 68 | Title/Subtitle | `Untitled Fact` | `title: title.isEmpty ? 'Untitled Fact' : title,` |

### [create_memory_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/presentation/create_memory_screen.dart)
Path: `lib/features/memory/presentation/create_memory_screen.dart` | Remaining hardcoded strings: **15**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 23 | Unknown | `high` | `String _selectedImportance = 'high';` |
| 67 | Unknown | `Add Memory Fact` | `'Add Memory Fact',` |
| 85 | Unknown | `Category` | `'Category',` |
| 140 | Label/Content | `Fact Title` | `label: 'Fact Title',` |
| 141 | Input Decoration | `e.g. Favorite Coffee Order` | `hintText: 'e.g. Favorite Coffee Order',` |
| 145 | Unknown | `A title is required` | `return 'A title is required';` |
| 154 | Unknown | `Description Details` | `'Description Details',` |
| 166 | Unknown | `Details are required` | `return 'Details are required';` |
| 175 | Input Decoration | `What should Aura remember about you?` | `hintText: 'What should Aura remember about you?',` |
| 206 | Unknown | `Importance Level` | `'Importance Level',` |
| 214 | Unknown | `low` | `children: ['low', 'medium', 'high'].map((imp) {` |
| 214 | Unknown | `medium` | `children: ['low', 'medium', 'high'].map((imp) {` |
| 214 | Unknown | `high` | `children: ['low', 'medium', 'high'].map((imp) {` |
| 259 | Unknown | `Pin Fact to Dashboard` | `'Pin Fact to Dashboard',` |
| 280 | Unknown | `Save Memory Fact` | `text: 'Save Memory Fact',` |

### [memory_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/presentation/memory_screen.dart)
Path: `lib/features/memory/presentation/memory_screen.dart` | Remaining hardcoded strings: **19**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 22 | Unknown | `All` | `String _selectedFilter = 'All'; // 'All', 'Personal', 'Work'` |
| 83 | Unknown | `Created: ${DateFormat(` | `'Created: ${DateFormat('yyyy-MM-dd hh:mm a').format(memory.storedAt)}',` |
| 83 | Unknown | `).format(memory.storedAt)}` | `'Created: ${DateFormat('yyyy-MM-dd hh:mm a').format(memory.storedAt)}',` |
| 117 | Text Widget / Tooltip | `Memory deleted` | `).showSnackBar(const SnackBar(content: Text('Memory deleted')));` |
| 123 | Unknown | `Close` | `'Close',` |
| 214 | Unknown | `Today` | `return 'Today';` |
| 216 | Unknown | `Yesterday` | `return 'Yesterday';` |
| 218 | Unknown | `${diff.inDays} days ago` | `return '${diff.inDays} days ago';` |
| 220 | Unknown | `MMM d` | `return DateFormat('MMM d').format(date);` |
| 233 | Unknown | `Personal` | `if (_selectedFilter == 'Personal' &&` |
| 237 | Unknown | `Work` | `if (_selectedFilter == 'Work' && m.category != MemoryCategory.work) {` |
| 263 | Unknown | `My Memory` | `'My Memory',` |
| 280 | Unknown | `Things I remember about you` | `'Things I remember about you',` |
| 330 | Input Decoration | `Search facts and insights...` | `hintText: 'Search facts and insights...',` |
| 361 | Label/Content | `All` | `label: 'All',` |
| 369 | Label/Content | `Personal` | `label: 'Personal',` |
| 377 | Label/Content | `Work` | `label: 'Work',` |
| 495 | Unknown | `+ Add Memory` | `text: '+ Add Memory',` |
| 522 | Unknown | `No memories found.` | `'No memories found.',` |

### [memory_card_tile.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/presentation/widgets/memory_card_tile.dart)
Path: `lib/features/memory/presentation/widgets/memory_card_tile.dart` | Remaining hardcoded strings: **10**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 52 | Unknown | `Personal` | `return 'Personal';` |
| 54 | Unknown | `Work` | `return 'Work';` |
| 56 | Unknown | `Insight` | `return 'Insight';` |
| 58 | Unknown | `Fact` | `return 'Fact';` |
| 65 | Unknown | `Remembered today` | `return 'Remembered today';` |
| 67 | Unknown | `Remembered yesterday` | `return 'Remembered yesterday';` |
| 69 | Unknown | `Remembered ${diff.inDays} days ago` | `return 'Remembered ${diff.inDays} days ago';` |
| 71 | Unknown | `Remembered ${DateFormat(` | `return 'Remembered ${DateFormat('MMM d').format(date)}';` |
| 71 | Unknown | `).format(date)}` | `return 'Remembered ${DateFormat('MMM d').format(date)}';` |
| 174 | Unknown | `high` | `'high',` |

### [mood_selection_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/mood/presentation/mood_selection_screen.dart)
Path: `lib/features/mood/presentation/mood_selection_screen.dart` | Remaining hardcoded strings: **53**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 26 | Unknown | `emoji` | `'emoji': '😊',` |
| 27 | Unknown | `name` | `'name': 'Happy',` |
| 27 | Unknown | `Happy` | `'name': 'Happy',` |
| 28 | Unknown | `description` | `'description': 'Feeling positive and energetic',` |
| 28 | Unknown | `Feeling positive and energetic` | `'description': 'Feeling positive and energetic',` |
| 30 | Unknown | `emoji` | `{'emoji': '☁️', 'name': 'Calm', 'description': 'Relaxed and peaceful'},` |
| 30 | Unknown | `name` | `{'emoji': '☁️', 'name': 'Calm', 'description': 'Relaxed and peaceful'},` |
| 30 | Unknown | `Calm` | `{'emoji': '☁️', 'name': 'Calm', 'description': 'Relaxed and peaceful'},` |
| 30 | Unknown | `description` | `{'emoji': '☁️', 'name': 'Calm', 'description': 'Relaxed and peaceful'},` |
| 30 | Unknown | `Relaxed and peaceful` | `{'emoji': '☁️', 'name': 'Calm', 'description': 'Relaxed and peaceful'},` |
| 32 | Unknown | `emoji` | `'emoji': '🌱',` |
| 33 | Unknown | `name` | `'name': 'Motivated',` |
| 33 | Unknown | `Motivated` | `'name': 'Motivated',` |
| 34 | Unknown | `description` | `'description': 'Ready to achieve goals',` |
| 34 | Unknown | `Ready to achieve goals` | `'description': 'Ready to achieve goals',` |
| 36 | Unknown | `emoji` | `{'emoji': '🌙', 'name': 'Relaxed', 'description': 'Taking things slowly'},` |
| 36 | Unknown | `name` | `{'emoji': '🌙', 'name': 'Relaxed', 'description': 'Taking things slowly'},` |
| 36 | Unknown | `Relaxed` | `{'emoji': '🌙', 'name': 'Relaxed', 'description': 'Taking things slowly'},` |
| 36 | Unknown | `description` | `{'emoji': '🌙', 'name': 'Relaxed', 'description': 'Taking things slowly'},` |
| 36 | Unknown | `Taking things slowly` | `{'emoji': '🌙', 'name': 'Relaxed', 'description': 'Taking things slowly'},` |
| 38 | Unknown | `emoji` | `'emoji': '🌧️',` |
| 39 | Unknown | `name` | `'name': 'Reflective',` |
| 39 | Unknown | `Reflective` | `'name': 'Reflective',` |
| 40 | Unknown | `description` | `'description': 'Thoughtful and introspective',` |
| 40 | Unknown | `Thoughtful and introspective` | `'description': 'Thoughtful and introspective',` |
| 43 | Unknown | `emoji` | `'emoji': '⚡',` |
| 44 | Unknown | `name` | `'name': 'Focused',` |
| 44 | Unknown | `Focused` | `'name': 'Focused',` |
| 45 | Unknown | `description` | `'description': 'Ready to get things done',` |
| 45 | Unknown | `Ready to get things done` | `'description': 'Ready to get things done',` |
| 47 | Unknown | `emoji` | `{'emoji': '😴', 'name': 'Tired', 'description': 'Need a gentle experience'},` |
| 47 | Unknown | `name` | `{'emoji': '😴', 'name': 'Tired', 'description': 'Need a gentle experience'},` |
| 47 | Unknown | `Tired` | `{'emoji': '😴', 'name': 'Tired', 'description': 'Need a gentle experience'},` |
| 47 | Unknown | `description` | `{'emoji': '😴', 'name': 'Tired', 'description': 'Need a gentle experience'},` |
| 47 | Unknown | `Need a gentle experience` | `{'emoji': '😴', 'name': 'Tired', 'description': 'Need a gentle experience'},` |
| 49 | Unknown | `emoji` | `'emoji': '❤️',` |
| 50 | Unknown | `name` | `'name': 'Inspired',` |
| 50 | Unknown | `Inspired` | `'name': 'Inspired',` |
| 51 | Unknown | `description` | `'description': 'Feeling creative today',` |
| 51 | Unknown | `Feeling creative today` | `'description': 'Feeling creative today',` |
| 69 | Unknown | `name` | `final activeMoodName = _moods[_currentIndex]['name']!;` |
| 97 | Unknown | `How are you feeling today?` | `'How are you feeling today?',` |
| 107 | Unknown | `Let's personalize Aura AI to match your current mood.` | `'Let\'s personalize Aura AI to match your current mood.',` |
| 136 | Unknown | `name` | `mood['name']!,` |
| 205 | Unknown | `emoji` | `mood['emoji']!,` |
| 211 | Unknown | `name` | `mood['name']!,` |
| 224 | Unknown | `description` | `mood['description']!,` |
| 323 | Unknown | `Preferred Language` | `'Preferred Language',` |
| 364 | Unknown | `Continue` | `text: 'Continue',` |
| 378 | Unknown | `/home` | `context.go('/home');` |
| 392 | Unknown | `name` | `final activeMoodName = _moods[_currentIndex]['name']!;` |
| 432 | Unknown | `Choose Language` | `'Choose Language',` |
| 441 | Unknown | `Select your preferred translation for authenticated areas.` | `'Select your preferred translation for authenticated areas.',` |

### [notifications_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/notifications/notifications_repository.dart)
Path: `lib/features/notifications/notifications_repository.dart` | Remaining hardcoded strings: **15**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 14 | Unknown | `notif-1` | `id: 'notif-1',` |
| 15 | Title/Subtitle | `Daily Reflection Time` | `title: 'Daily Reflection Time',` |
| 17 | Unknown | `Take 2 minutes to log your reflections. Writing helps reduce baseline stress.` | `'Take 2 minutes to log your reflections. Writing helps reduce baseline stress.',` |
| 19 | Unknown | `Journal` | `category: 'Journal',` |
| 20 | Unknown | `medium` | `priority: 'medium',` |
| 24 | Unknown | `notif-2` | `id: 'notif-2',` |
| 25 | Title/Subtitle | `Goal Milestone Alert` | `title: 'Goal Milestone Alert',` |
| 27 | Unknown | `Keep the momentum going! Only 5 sessions left to achieve your Morning Yoga Routine target.` | `'Keep the momentum going! Only 5 sessions left to achieve your Morning Yoga Routine target.',` |
| 29 | Unknown | `Goals` | `category: 'Goals',` |
| 30 | Unknown | `high` | `priority: 'high',` |
| 34 | Unknown | `notif-3` | `id: 'notif-3',` |
| 35 | Title/Subtitle | `Aura Analytics Insight` | `title: 'Aura Analytics Insight',` |
| 37 | Unknown | `We noticed you log your highest focus scores on Tuesday mornings. Plan next week accordingly.` | `'We noticed you log your highest focus scores on Tuesday mornings. Plan next week accordingly.',` |
| 39 | Unknown | `AI Suggestions` | `category: 'AI Suggestions',` |
| 40 | Unknown | `low` | `priority: 'low',` |

### [notifications_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/notifications/presentation/notifications_screen.dart)
Path: `lib/features/notifications/presentation/notifications_screen.dart` | Remaining hardcoded strings: **28**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 30 | Unknown | `notification_permission_shown` | `prefs.getBool('notification_permission_shown') ?? false;` |
| 57 | Unknown | `Enable Notifications` | `'Enable Notifications',` |
| 66 | Unknown | `Aura AI would like to send you notifications for your goal progress check-ins, journal writing prompts, and daily companion insights.` | `'Aura AI would like to send you notifications for your goal progress check-ins, journal writing prompts, and daily companion insights.',` |
| 75 | Unknown | `notification_permission_shown` | `await prefs.setBool('notification_permission_shown', true);` |
| 79 | Text Widget / Tooltip | `Notifications disabled` | `const SnackBar(content: Text('Notifications disabled')),` |
| 84 | Unknown | `Don't Allow` | `'Don\'t Allow',` |
| 93 | Unknown | `notification_permission_shown` | `await prefs.setBool('notification_permission_shown', true);` |
| 98 | Text Widget / Tooltip | `Notifications enabled!` | `content: Text('Notifications enabled!'),` |
| 105 | Unknown | `Allow` | `'Allow',` |
| 120 | Unknown | `Journal` | `case 'Journal':` |
| 122 | Unknown | `Goals` | `case 'Goals':` |
| 124 | Unknown | `AI Suggestions` | `case 'AI Suggestions':` |
| 133 | Unknown | `Journal` | `case 'Journal':` |
| 135 | Unknown | `Goals` | `case 'Goals':` |
| 137 | Unknown | `AI Suggestions` | `case 'AI Suggestions':` |
| 146 | Unknown | `high` | `case 'high':` |
| 148 | Unknown | `medium` | `case 'medium':` |
| 150 | Unknown | `low` | `case 'low':` |
| 160 | Unknown | `Just now` | `return 'Just now';` |
| 162 | Unknown | `${diff.inHours}h ago` | `return '${diff.inHours}h ago';` |
| 164 | Unknown | `MMM d, h:mm a` | `return DateFormat('MMM d, h:mm a').format(date);` |
| 207 | Unknown | `/home` | `context.go('/home');` |
| 212 | Unknown | `Notifications` | `'Notifications',` |
| 225 | Unknown | `Read All` | `'Read All',` |
| 247 | Unknown | `Today` | `_buildSectionHeader('Today', isDark),` |
| 269 | Unknown | `Yesterday & Earlier` | `_buildSectionHeader('Yesterday & Earlier', isDark),` |
| 496 | Unknown | `All caught up!` | `'All caught up!',` |
| 505 | Unknown | `No new notifications.` | `'No new notifications.',` |

### [edit_profile_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/edit_profile_screen.dart)
Path: `lib/features/profile/presentation/edit_profile_screen.dart` | Remaining hardcoded strings: **20**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 60 | Unknown | `label` | `'label': 'Corporate',` |
| 60 | Unknown | `Corporate` | `'label': 'Corporate',` |
| 61 | Unknown | `url` | `'url':` |
| 65 | Unknown | `label` | `'label': 'Tech',` |
| 65 | Unknown | `Tech` | `'label': 'Tech',` |
| 66 | Unknown | `url` | `'url':` |
| 70 | Unknown | `label` | `'label': 'Creative',` |
| 70 | Unknown | `Creative` | `'label': 'Creative',` |
| 71 | Unknown | `url` | `'url':` |
| 75 | Unknown | `label` | `'label': 'Nature',` |
| 75 | Unknown | `Nature` | `'label': 'Nature',` |
| 76 | Unknown | `url` | `'url':` |
| 85 | Unknown | `corporate` | `case 'corporate':` |
| 87 | Unknown | `tech` | `case 'tech':` |
| 89 | Unknown | `creative` | `case 'creative':` |
| 91 | Unknown | `nature` | `case 'nature':` |
| 123 | Unknown | `url` | `.updateAvatar(avatar['url']!);` |
| 135 | Unknown | `url` | `backgroundImage: NetworkImage(avatar['url']!),` |
| 139 | Unknown | `label` | `getLocalAvatarLabel(avatar['label']!),` |
| 180 | Unknown | `/home` | `context.go('/home');` |

### [profile_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/profile_screen.dart)
Path: `lib/features/profile/presentation/profile_screen.dart` | Remaining hardcoded strings: **4**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 42 | Unknown | `/home` | `context.go('/home');` |
| 232 | Unknown | `/notifications` | `onTap: () => context.push('/notifications'),` |
| 248 | Unknown | `/settings` | `context.push('/settings');` |
| 264 | Unknown | `/login` | `context.go('/login');` |

### [personality_selector.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/widgets/personality_selector.dart)
Path: `lib/features/profile/presentation/widgets/personality_selector.dart` | Remaining hardcoded strings: **10**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 19 | Unknown | `Empathetic` | `'Empathetic',` |
| 20 | Unknown | `Analytical` | `'Analytical',` |
| 21 | Unknown | `Witty` | `'Witty',` |
| 22 | Unknown | `Concise` | `'Concise',` |
| 23 | Unknown | `Creative` | `'Creative',` |
| 30 | Unknown | `Empathetic` | `case 'Empathetic':` |
| 32 | Unknown | `Analytical` | `case 'Analytical':` |
| 34 | Unknown | `Witty` | `case 'Witty':` |
| 36 | Unknown | `Concise` | `case 'Concise':` |
| 38 | Unknown | `Creative` | `case 'Creative':` |

### [profile_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/profile_provider.dart)
Path: `lib/features/profile/profile_provider.dart` | Remaining hardcoded strings: **3**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 36 | Unknown | `Alex Rivera` | `userName: 'Alex Rivera',` |
| 37 | Unknown | `alex.rivera@example.com` | `email: 'alex.rivera@example.com',` |
| 40 | Unknown | `Empathetic` | `selectedPersonality: 'Empathetic',` |

### [settings_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/settings/presentation/settings_screen.dart)
Path: `lib/features/settings/presentation/settings_screen.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 42 | Unknown | `/home` | `context.go('/home');` |
| 152 | Unknown | `Push Notifications` | `'Push Notifications',` |
| 226 | Unknown | `About Aura AI` | `_buildSectionHeader(context, 'About Aura AI', isDark),` |
| 295 | Unknown | `/login` | `context.go('/login');` |
| 432 | Unknown | `Clear Cache Data` | `'Clear Cache Data',` |
| 439 | Unknown | `Are you sure you want to clear all offline cached images, conversations, and logs? This action is irreversible.` | `'Are you sure you want to clear all offline cached images, conversations, and logs? This action is irreversible.',` |
| 446 | Unknown | `Cancel` | `'Cancel',` |
| 458 | Text Widget / Tooltip | `Cache successfully cleared!` | `content: Text('Cache successfully cleared!'),` |
| 464 | Unknown | `Clear` | `'Clear',` |

### [settings_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/settings/settings_provider.dart)
Path: `lib/features/settings/settings_provider.dart` | Remaining hardcoded strings: **8**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 15 | Unknown | `Empathetic` | `this.voicePitch = 'Empathetic',` |
| 46 | Unknown | `notifications_enabled` | `final notifs = _prefs?.getBool('notifications_enabled') ?? true;` |
| 47 | Unknown | `app_lock_enabled` | `final lock = _prefs?.getBool('app_lock_enabled') ?? false;` |
| 48 | Unknown | `voice_pitch` | `final pitch = _prefs?.getString('voice_pitch') ?? 'Empathetic';` |
| 48 | Unknown | `Empathetic` | `final pitch = _prefs?.getString('voice_pitch') ?? 'Empathetic';` |
| 69 | Unknown | `notifications_enabled` | `await _prefs?.setBool('notifications_enabled', val);` |
| 75 | Unknown | `app_lock_enabled` | `await _prefs?.setBool('app_lock_enabled', val);` |
| 80 | Unknown | `voice_pitch` | `await _prefs?.setString('voice_pitch', value);` |

### [splash_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/splash/presentation/splash_screen.dart)
Path: `lib/features/splash/presentation/splash_screen.dart` | Remaining hardcoded strings: **4**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 48 | Unknown | `/onboarding` | `context.go('/onboarding');` |
| 126 | Unknown | `Your Personal AI Companion` | `'Your Personal AI Companion',` |
| 139 | Unknown | `Understands you. Remembers you. Grows with you.` | `'Understands you. Remembers you. Grows with you.',` |
| 160 | Unknown | `Connecting to your Aura...` | `'Connecting to your Aura...',` |

### [vision_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/vision_screen.dart)
Path: `lib/features/vision/presentation/vision_screen.dart` | Remaining hardcoded strings: **136**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 137 | Unknown | `Understand Scene` | `String _selectedMode = 'Understand Scene';` |
| 143 | Unknown | `imagePath` | `'imagePath':` |
| 145 | Unknown | `title` | `'title': 'Office Desk Setup',` |
| 145 | Unknown | `Office Desk Setup` | `'title': 'Office Desk Setup',` |
| 146 | Unknown | `mode` | `'mode': 'Understand Scene',` |
| 146 | Unknown | `Understand Scene` | `'mode': 'Understand Scene',` |
| 147 | Unknown | `detectedObjects` | `'detectedObjects': [` |
| 148 | Unknown | `name` | `{'name': 'Laptop', 'confidence': 0.98},` |
| 148 | Unknown | `Laptop` | `{'name': 'Laptop', 'confidence': 0.98},` |
| 148 | Unknown | `confidence` | `{'name': 'Laptop', 'confidence': 0.98},` |
| 149 | Unknown | `name` | `{'name': 'Keyboard', 'confidence': 0.95},` |
| 149 | Unknown | `Keyboard` | `{'name': 'Keyboard', 'confidence': 0.95},` |
| 149 | Unknown | `confidence` | `{'name': 'Keyboard', 'confidence': 0.95},` |
| 150 | Unknown | `name` | `{'name': 'Coffee Mug', 'confidence': 0.89},` |
| 150 | Unknown | `Coffee Mug` | `{'name': 'Coffee Mug', 'confidence': 0.89},` |
| 150 | Unknown | `confidence` | `{'name': 'Coffee Mug', 'confidence': 0.89},` |
| 152 | Unknown | `ocrText` | `'ocrText':` |
| 153 | Unknown | `PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans` | `'PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans',` |
| 154 | Unknown | `scene` | `'scene':` |
| 155 | Unknown | `I see a modern and clean office desk setup. There is a silver laptop open on the desk, a mechanical keyboard, and a dark ceramic coffee mug. The desk has a light wooden texture.` | `'I see a modern and clean office desk setup. There is a silver laptop open on the desk, a mechanical keyboard, and a dark ceramic coffee mug. The desk has a light wooden texture.',` |
| 156 | Unknown | `context` | `'context':` |
| 157 | Unknown | `This setup is ideal for software development or writing. The planner notes indicate a high-priority product launch deadline approaching this Friday.` | `'This setup is ideal for software development or writing. The planner notes indicate a high-priority product launch deadline approaching this Friday.',` |
| 158 | Unknown | `timestamp` | `'timestamp': '2h ago',` |
| 158 | Unknown | `2h ago` | `'timestamp': '2h ago',` |
| 161 | Unknown | `imagePath` | `'imagePath':` |
| 163 | Unknown | `title` | `'title': 'Handwritten Notes',` |
| 163 | Unknown | `Handwritten Notes` | `'title': 'Handwritten Notes',` |
| 164 | Unknown | `mode` | `'mode': 'Read Text',` |
| 164 | Unknown | `Read Text` | `'mode': 'Read Text',` |
| 165 | Unknown | `detectedObjects` | `'detectedObjects': [` |
| 166 | Unknown | `name` | `{'name': 'Notebook', 'confidence': 0.99},` |
| 166 | Unknown | `Notebook` | `{'name': 'Notebook', 'confidence': 0.99},` |
| 166 | Unknown | `confidence` | `{'name': 'Notebook', 'confidence': 0.99},` |
| 167 | Unknown | `name` | `{'name': 'Pen', 'confidence': 0.93},` |
| 167 | Unknown | `Pen` | `{'name': 'Pen', 'confidence': 0.93},` |
| 167 | Unknown | `confidence` | `{'name': 'Pen', 'confidence': 0.93},` |
| 169 | Unknown | `ocrText` | `'ocrText':` |
| 170 | Unknown | `Reflections on Growth:\nChange is constant. Focus on building habits, not just achieving goals. Take small steps daily.` | `'Reflections on Growth:\nChange is constant. Focus on building habits, not just achieving goals. Take small steps daily.',` |
| 171 | Unknown | `scene` | `'scene':` |
| 172 | Unknown | `I see a handwritten notebook page open on a wooden table with a pen lying next to it.` | `'I see a handwritten notebook page open on a wooden table with a pen lying next to it.',` |
| 173 | Unknown | `context` | `'context':` |
| 174 | Unknown | `The text captures personal development ideas on habits. This fits well with your Journal reflecting features.` | `'The text captures personal development ideas on habits. This fits well with your Journal reflecting features.',` |
| 175 | Unknown | `timestamp` | `'timestamp': 'Yesterday',` |
| 175 | Unknown | `Yesterday` | `'timestamp': 'Yesterday',` |
| 178 | Unknown | `imagePath` | `'imagePath':` |
| 180 | Unknown | `title` | `'title': 'Plant on Window Sill',` |
| 180 | Unknown | `Plant on Window Sill` | `'title': 'Plant on Window Sill',` |
| 181 | Unknown | `mode` | `'mode': 'Identify Objects',` |
| 181 | Unknown | `Identify Objects` | `'mode': 'Identify Objects',` |
| 182 | Unknown | `detectedObjects` | `'detectedObjects': [` |
| 183 | Unknown | `name` | `{'name': 'Houseplant', 'confidence': 0.97},` |
| 183 | Unknown | `Houseplant` | `{'name': 'Houseplant', 'confidence': 0.97},` |
| 183 | Unknown | `confidence` | `{'name': 'Houseplant', 'confidence': 0.97},` |
| 184 | Unknown | `name` | `{'name': 'Window Sill', 'confidence': 0.92},` |
| 184 | Unknown | `Window Sill` | `{'name': 'Window Sill', 'confidence': 0.92},` |
| 184 | Unknown | `confidence` | `{'name': 'Window Sill', 'confidence': 0.92},` |
| 186 | Unknown | `ocrText` | `'ocrText': 'PLANT CARE GUIDE',` |
| 186 | Unknown | `PLANT CARE GUIDE` | `'ocrText': 'PLANT CARE GUIDE',` |
| 187 | Unknown | `scene` | `'scene':` |
| 188 | Unknown | `I see a green potted houseplant sitting on a white window sill. Sunlight is coming through the glass window pane.` | `'I see a green potted houseplant sitting on a white window sill. Sunlight is coming through the glass window pane.',` |
| 189 | Unknown | `context` | `'context':` |
| 190 | Unknown | `Natural light and plants can boost productivity and mood. Fits well with your Calm mood theme.` | `'Natural light and plants can boost productivity and mood. Fits well with your Calm mood theme.',` |
| 191 | Unknown | `timestamp` | `'timestamp': '3 days ago',` |
| 191 | Unknown | `3 days ago` | `'timestamp': '3 days ago',` |
| 197 | Unknown | `visionScanLooking` | `'visionScanLooking',` |
| 198 | Unknown | `visionScanFinding` | `'visionScanFinding',` |
| 199 | Unknown | `visionScanReading` | `'visionScanReading',` |
| 200 | Unknown | `visionScanConnecting` | `'visionScanConnecting',` |
| 201 | Unknown | `visionScanPreparing` | `'visionScanPreparing',` |
| 211 | Unknown | `Office Desk Setup` | `if (title == 'Office Desk Setup') return l10n.visionMockTitleDesk;` |
| 212 | Unknown | `Handwritten Notes` | `if (title == 'Handwritten Notes') return l10n.visionMockTitleNotes;` |
| 213 | Unknown | `Plant on Window Sill` | `if (title == 'Plant on Window Sill') return l10n.visionMockTitlePlant;` |
| 219 | Unknown | `Understand Scene` | `if (mode == 'Understand Scene') return l10n.visionModeUnderstandScene;` |
| 220 | Unknown | `Read Text` | `if (mode == 'Read Text') return l10n.visionModeReadText;` |
| 221 | Unknown | `Identify Objects` | `if (mode == 'Identify Objects') return l10n.visionModeIdentifyObjects;` |
| 222 | Unknown | `Describe Image` | `if (mode == 'Describe Image') return l10n.visionModeDescribeImage;` |
| 223 | Unknown | `Find Details` | `if (mode == 'Find Details') return l10n.visionModeFindDetails;` |
| 229 | Unknown | `I see a modern and clean office desk setup` | `if (scene.startsWith('I see a modern and clean office desk setup')) return l10n.visionMockSceneDesk;` |
| 230 | Unknown | `I see a handwritten notebook page open` | `if (scene.startsWith('I see a handwritten notebook page open')) return l10n.visionMockSceneNotes;` |
| 231 | Unknown | `I see a green potted houseplant` | `if (scene.startsWith('I see a green potted houseplant')) return l10n.visionMockScenePlant;` |
| 237 | Unknown | `This setup is ideal` | `if (contextText.startsWith('This setup is ideal')) return l10n.visionMockContextDesk;` |
| 238 | Unknown | `The text captures` | `if (contextText.startsWith('The text captures')) return l10n.visionMockContextNotes;` |
| 239 | Unknown | `Natural light and plants` | `if (contextText.startsWith('Natural light and plants')) return l10n.visionMockContextPlant;` |
| 245 | Unknown | `PLAN:` | `if (ocr.startsWith('PLAN:')) return l10n.visionMockOcrDesk;` |
| 246 | Unknown | `Reflections on Growth:` | `if (ocr.startsWith('Reflections on Growth:')) return l10n.visionMockOcrNotes;` |
| 247 | Unknown | `PLANT CARE GUIDE` | `if (ocr.startsWith('PLANT CARE GUIDE')) return l10n.visionMockOcrPlant;` |
| 253 | Unknown | `Laptop` | `if (name == 'Laptop') return l10n.visionMockObjLaptop;` |
| 254 | Unknown | `Keyboard` | `if (name == 'Keyboard') return l10n.visionMockObjKeyboard;` |
| 255 | Unknown | `Coffee Mug` | `if (name == 'Coffee Mug') return l10n.visionMockObjCoffeeMug;` |
| 256 | Unknown | `Notebook` | `if (name == 'Notebook') return l10n.visionMockObjNotebook;` |
| 257 | Unknown | `Pen` | `if (name == 'Pen') return l10n.visionMockObjPen;` |
| 258 | Unknown | `Houseplant` | `if (name == 'Houseplant') return l10n.visionMockObjHouseplant;` |
| 259 | Unknown | `Window Sill` | `if (name == 'Window Sill') return l10n.visionMockObjWindowSill;` |
| 266 | Unknown | `visionScanLooking` | `case 'visionScanLooking': return l10n.visionScanLooking;` |
| 267 | Unknown | `visionScanFinding` | `case 'visionScanFinding': return l10n.visionScanFinding;` |
| 268 | Unknown | `visionScanReading` | `case 'visionScanReading': return l10n.visionScanReading;` |
| 269 | Unknown | `visionScanConnecting` | `case 'visionScanConnecting': return l10n.visionScanConnecting;` |
| 270 | Unknown | `visionScanPreparing` | `case 'visionScanPreparing': return l10n.visionScanPreparing;` |
| 292 | Unknown | `camera` | `ref.read(visionProvider.notifier).selectImage('camera');` |
| 312 | Unknown | `mode` | `_selectedMode = sighting['mode'];` |
| 316 | Unknown | `mock` | `ref.read(visionProvider.notifier).selectImage('mock');` |
| 331 | Unknown | `imagePath` | `? _selectedMockSighting!['imagePath'] as String` |
| 339 | Text Widget / Tooltip | `scene` | `? _getLocalSceneText(context, _selectedMockSighting!['scene'] as String)` |
| 342 | Unknown | `detectedObjects` | `? _selectedMockSighting!['detectedObjects']` |
| 346 | Unknown | `ocrText` | `? (_selectedMockSighting!['ocrText'] != null` |
| 347 | Text Widget / Tooltip | `ocrText` | `? _getLocalOcrText(context, _selectedMockSighting!['ocrText'] as String)` |
| 351 | Text Widget / Tooltip | `context` | `? _getLocalContextText(context, _selectedMockSighting!['context'] as String)` |
| 373 | Unknown | `/home` | `context.go('/home');` |
| 499 | Unknown | `Scan Another` | `'Scan Another',` |
| 761 | Unknown | `name` | `{'name': 'Understand Scene', 'icon': Icons.visibility_outlined},` |
| 761 | Unknown | `Understand Scene` | `{'name': 'Understand Scene', 'icon': Icons.visibility_outlined},` |
| 761 | Unknown | `icon` | `{'name': 'Understand Scene', 'icon': Icons.visibility_outlined},` |
| 762 | Unknown | `name` | `{'name': 'Read Text', 'icon': Icons.text_fields_outlined},` |
| 762 | Unknown | `Read Text` | `{'name': 'Read Text', 'icon': Icons.text_fields_outlined},` |
| 762 | Unknown | `icon` | `{'name': 'Read Text', 'icon': Icons.text_fields_outlined},` |
| 763 | Unknown | `name` | `{'name': 'Identify Objects', 'icon': Icons.category_outlined},` |
| 763 | Unknown | `Identify Objects` | `{'name': 'Identify Objects', 'icon': Icons.category_outlined},` |
| 763 | Unknown | `icon` | `{'name': 'Identify Objects', 'icon': Icons.category_outlined},` |
| 764 | Unknown | `name` | `{'name': 'Describe Image', 'icon': Icons.description_outlined},` |
| 764 | Unknown | `Describe Image` | `{'name': 'Describe Image', 'icon': Icons.description_outlined},` |
| 764 | Unknown | `icon` | `{'name': 'Describe Image', 'icon': Icons.description_outlined},` |
| 765 | Unknown | `name` | `{'name': 'Find Details', 'icon': Icons.zoom_in_rounded},` |
| 765 | Unknown | `Find Details` | `{'name': 'Find Details', 'icon': Icons.zoom_in_rounded},` |
| 765 | Unknown | `icon` | `{'name': 'Find Details', 'icon': Icons.zoom_in_rounded},` |
| 784 | Unknown | `name` | `final isSelected = _selectedMode == m['name'];` |
| 790 | Unknown | `name` | `_selectedMode = m['name'];` |
| 831 | Unknown | `icon` | `m['icon'] as IconData,` |
| 837 | Unknown | `name` | `_getLocalModeName(context, m['name'] as String),` |
| 909 | Unknown | `imagePath` | `sighting['imagePath'] as String,` |
| 921 | Unknown | `title` | `_getLocalSightingTitle(context, sighting['title'] as String),` |
| 934 | Unknown | `mode` | `_getLocalModeName(context, sighting['mode'] as String),` |
| 1066 | Unknown | `confidence` | `final double progress = obj['confidence'] as double;` |
| 1076 | Unknown | `name` | `_getLocalObjectName(context, obj['name'] as String),` |
| 1086 | Unknown | `${(progress * 100).toInt()}%` | `'${(progress * 100).toInt()}%',` |
| 1309 | Unknown | `/chat` | `context.push('/chat');` |
| 1338 | Unknown | `/create-journal` | `context.push('/create-journal');` |

### [detected_objects_list.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/widgets/detected_objects_list.dart)
Path: `lib/features/vision/presentation/widgets/detected_objects_list.dart` | Remaining hardcoded strings: **9**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 56 | Unknown | `name` | `final String name = obj['name'];` |
| 57 | Unknown | `confidence` | `final double confidence = obj['confidence'];` |
| 106 | Unknown | `Laptop` | `if (name == 'Laptop') return l10n.visionMockObjLaptop;` |
| 107 | Unknown | `Keyboard` | `if (name == 'Keyboard') return l10n.visionMockObjKeyboard;` |
| 108 | Unknown | `Coffee Mug` | `if (name == 'Coffee Mug') return l10n.visionMockObjCoffeeMug;` |
| 109 | Unknown | `Notebook` | `if (name == 'Notebook') return l10n.visionMockObjNotebook;` |
| 110 | Unknown | `Pen` | `if (name == 'Pen') return l10n.visionMockObjPen;` |
| 111 | Unknown | `Houseplant` | `if (name == 'Houseplant') return l10n.visionMockObjHouseplant;` |
| 112 | Unknown | `Window Sill` | `if (name == 'Window Sill') return l10n.visionMockObjWindowSill;` |

### [ocr_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/widgets/ocr_card.dart)
Path: `lib/features/vision/presentation/widgets/ocr_card.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 60 | Unknown | `Courier` | `fontFamily: 'Courier', // Monospace feel` |

### [vision_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/vision_provider.dart)
Path: `lib/features/vision/vision_provider.dart` | Remaining hardcoded strings: **10**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 59 | Unknown | `name` | `{'name': 'Laptop', 'confidence': 0.98},` |
| 59 | Unknown | `Laptop` | `{'name': 'Laptop', 'confidence': 0.98},` |
| 59 | Unknown | `confidence` | `{'name': 'Laptop', 'confidence': 0.98},` |
| 60 | Unknown | `name` | `{'name': 'Keyboard', 'confidence': 0.95},` |
| 60 | Unknown | `Keyboard` | `{'name': 'Keyboard', 'confidence': 0.95},` |
| 60 | Unknown | `confidence` | `{'name': 'Keyboard', 'confidence': 0.95},` |
| 61 | Unknown | `name` | `{'name': 'Coffee Mug', 'confidence': 0.89},` |
| 61 | Unknown | `Coffee Mug` | `{'name': 'Coffee Mug', 'confidence': 0.89},` |
| 61 | Unknown | `confidence` | `{'name': 'Coffee Mug', 'confidence': 0.89},` |
| 64 | Unknown | `PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans` | `'PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans',` |

### [voice_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/voice/presentation/voice_screen.dart)
Path: `lib/features/voice/presentation/voice_screen.dart` | Remaining hardcoded strings: **2**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 56 | Unknown | `/home` | `context.go('/home');` |
| 146 | Unknown | `/home` | `context.go('/home');` |

### [memory.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/models/memory.dart)
Path: `lib/models/memory.dart` | Remaining hardcoded strings: **1**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 18 | Unknown | `medium` | `this.importance = 'medium',` |

### [user.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/models/user.dart)
Path: `lib/models/user.dart` | Remaining hardcoded strings: **8**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 30 | Unknown | `id` | `'id': id,` |
| 31 | Unknown | `email` | `'email': email,` |
| 32 | Unknown | `displayName` | `'displayName': displayName,` |
| 33 | Unknown | `avatarUrl` | `'avatarUrl': avatarUrl,` |
| 39 | Unknown | `id` | `id: map['id'] ?? '',` |
| 40 | Unknown | `email` | `email: map['email'] ?? '',` |
| 41 | Unknown | `displayName` | `displayName: map['displayName'] ?? '',` |
| 42 | Unknown | `avatarUrl` | `avatarUrl: map['avatarUrl'],` |

### [app_router.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/routes/app_router.dart)
Path: `lib/routes/app_router.dart` | Remaining hardcoded strings: **38**

| Line | Context | Hardcoded String | Line Content |
|------|---------|------------------|--------------|
| 32 | Unknown | `splash` | `name: 'splash',` |
| 36 | Unknown | `/onboarding` | `path: '/onboarding',` |
| 37 | Unknown | `onboarding` | `name: 'onboarding',` |
| 41 | Unknown | `/login` | `path: '/login',` |
| 42 | Unknown | `login` | `name: 'login',` |
| 46 | Unknown | `/register` | `path: '/register',` |
| 47 | Unknown | `register` | `name: 'register',` |
| 51 | Unknown | `/forgot-password` | `path: '/forgot-password',` |
| 52 | Unknown | `forgot-password` | `name: 'forgot-password',` |
| 56 | Unknown | `/home` | `path: '/home',` |
| 57 | Unknown | `home` | `name: 'home',` |
| 61 | Unknown | `/chat` | `path: '/chat',` |
| 62 | Unknown | `chat` | `name: 'chat',` |
| 66 | Unknown | `/voice` | `path: '/voice',` |
| 67 | Unknown | `voice` | `name: 'voice',` |
| 71 | Unknown | `/vision` | `path: '/vision',` |
| 72 | Unknown | `vision` | `name: 'vision',` |
| 76 | Unknown | `/profile` | `path: '/profile',` |
| 77 | Unknown | `profile` | `name: 'profile',` |
| 81 | Unknown | `/settings` | `path: '/settings',` |
| 82 | Unknown | `settings` | `name: 'settings',` |
| 86 | Unknown | `/notifications` | `path: '/notifications',` |
| 87 | Unknown | `notifications` | `name: 'notifications',` |
| 91 | Unknown | `/explore` | `path: '/explore',` |
| 92 | Unknown | `explore` | `name: 'explore',` |
| 96 | Unknown | `/documents` | `path: '/documents',` |
| 97 | Unknown | `documents` | `name: 'documents',` |
| 101 | Unknown | `/document-detail` | `path: '/document-detail',` |
| 102 | Unknown | `document-detail` | `name: 'document-detail',` |
| 106 | Unknown | `name` | `name: extra['name'] as String,` |
| 107 | Unknown | `size` | `size: extra['size'] as String,` |
| 108 | Unknown | `type` | `type: extra['type'] as String,` |
| 113 | Unknown | `/calendar` | `path: '/calendar',` |
| 114 | Unknown | `calendar` | `name: 'calendar',` |
| 118 | Unknown | `/create-journal` | `path: '/create-journal',` |
| 119 | Unknown | `create-journal` | `name: 'create-journal',` |
| 123 | Unknown | `/mood-selection` | `path: '/mood-selection',` |
| 124 | Unknown | `mood-selection` | `name: 'mood-selection',` |
