import json
import os
import time
import urllib.parse
import urllib.request
import sys
import io

# Set stdout to UTF-8 to prevent encoding errors on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Ensure directories
os.makedirs("assets/data/quotes/en", exist_ok=True)
os.makedirs("assets/data/quotes/es", exist_ok=True)
os.makedirs("assets/data/quotes/fr", exist_ok=True)
os.makedirs("assets/data/quotes/de", exist_ok=True)
os.makedirs("assets/data/quotes/hi", exist_ok=True)

# Subtitles mapping in English
english_subtitles = {
    "Morning": "Start your day with intent",
    "Afternoon": "Keep your momentum strong",
    "Evening": "Reflect and find comfort",
    "Night": "Rest and prepare for tomorrow"
}

# Pre-baked translations for subtitles to guarantee accuracy
subtitles_db = {
    "en": english_subtitles,
    "es": {
        "Morning": "Comienza tu día con intención",
        "Afternoon": "Mantén tu impulso.",
        "Evening": "Reflexiona y encuentra consuelo",
        "Night": "Descansa y prepárate para el mañana"
    },
    "fr": {
        "Morning": "Commencez votre journée avec intention",
        "Afternoon": "Gardez votre élan.",
        "Evening": "Réfléchissez et trouvez le réconfort",
        "Night": "Reposez-vous et préparez-vous pour demain"
    },
    "de": {
        "Morning": "Beginnen Sie Ihren Tag mit Absicht",
        "Afternoon": "Bleiben Sie in Ihrem Rhythmus.",
        "Evening": "Reflektieren Sie und finden Sie Trost",
        "Night": "Ruhen Sie sich aus und bereiten Sie sich auf morgen vor"
    },
    "hi": {
        "Morning": "इरादे के साथ अपने दिन की शुरुआत करें",
        "Afternoon": "अपनी गति मजबूत रखें",
        "Evening": "विचार करें और आराम पाएं",
        "Night": "आराम करें और कल के लिए तैयारी करें"
    }
}

# Themes list
themes = ["Happy", "Calm", "Motivated", "Relaxed", "Reflective", "Focused", "Tired", "Inspired"]

# Let's load english raw database
with open("assets/data/quotes/en.json", "r", encoding="utf-8") as f:
    en_db = json.load(f)

# Let's load spanish raw database to use high-quality translations
with open("assets/data/quotes/es.json", "r", encoding="utf-8") as f:
    es_db = json.load(f)

def translate_text(text, target_lang):
    if target_lang == "en":
        return text
    # Call free Google Translate API
    try:
        url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" + target_lang + "&dt=t&q=" + urllib.parse.quote(text)
        req = urllib.request.Request(
            url, 
            headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        )
        with urllib.request.urlopen(req) as response:
            res_json = json.loads(response.read().decode('utf-8'))
            translated = "".join([part[0] for part in res_json[0] if part[0]])
            return translated.strip()
    except Exception as e:
        print(f"Translation failed for '{text}' to {target_lang}: {e}")
        return text

# Map of translated databases
dbs = {
    "en": en_db,
    "es": es_db,
    "fr": {},
    "de": {},
    "hi": {}
}

# Translate to FR, DE, HI
for lang in ["fr", "de", "hi"]:
    print(f"Translating to {lang}...")
    for theme in themes:
        dbs[lang][theme] = {}
        for time_period in ["Morning", "Afternoon", "Evening", "Night"]:
            dbs[lang][theme][time_period] = []
            quotes = en_db[theme][time_period]
            for quote in quotes:
                translated = translate_text(quote, lang)
                dbs[lang][theme][time_period].append(translated)
                print(f"  [{theme}][{time_period}] {quote[:30]}... -> {translated[:30]}...")
                time.sleep(0.1) # Small throttle to be nice to API

# Now let's split the databases into separate files under assets/data/quotes/<lang>/<theme>.json
for lang in ["en", "es", "fr", "de", "hi"]:
    for theme in themes:
        # Theme key in file name should be lowercase
        file_path = f"assets/data/quotes/{lang}/{theme.lower()}.json"
        
        # Build the structured theme JSON
        theme_json = {}
        for time_period in ["Morning", "Afternoon", "Evening", "Night"]:
            # Retrieve quotes list
            quotes_list = dbs[lang][theme][time_period]
            # Retrieve localized subtitle
            subtitle = subtitles_db[lang][time_period]
            
            theme_json[time_period] = {
                "subtitle": subtitle,
                "quotes": quotes_list
            }
        
        with open(file_path, "w", encoding="utf-8") as out_f:
            json.dump(theme_json, out_f, ensure_ascii=False, indent=2)

print("Quotes splitting completed successfully!")
