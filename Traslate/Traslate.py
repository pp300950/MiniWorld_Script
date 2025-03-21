from googletrans import Translator

# สร้างตัวแปลภาษา
translator = Translator()

# ฟังก์ชันสำหรับแปลข้อความ
def translate_text(text, target_languages):
    translations = {}  # สร้าง dictionary สำหรับเก็บผลการแปล
    try:
        for lang in target_languages:
            # แปลข้อความไปยังภาษาที่กำหนด
            translated = translator.translate(text, dest=lang)
            translations[lang] = translated.text  # เก็บการแปลใน dictionary
        return translations
    except Exception as e:
        # หากเกิดข้อผิดพลาดใดๆ ให้ส่งคืนข้อความแสดงข้อผิดพลาด
        return {"error": str(e)}

# ฟังก์ชันสำหรับแสดงผลการแปล
def print_translations(text, translations):
    if "error" in translations:
        # ถ้ามีข้อผิดพลาด ให้แสดงข้อความข้อผิดพลาด
        print(f"Error: {translations['error']}")
    else:
        print(f"Original Text: {text}")
        for lang, translated_text in translations.items():
            print(f"Translated to {lang}: {translated_text}")

# ตัวอย่างการใช้
if __name__ == "__main__":
    # ข้อความที่ต้องการแปล
    text = "รักนะสาวน้อย"
    
    # ภาษาเป้าหมายที่ต้องการแปล (จาก codeLang ที่ผู้ใช้กรอก)
    codeLang = ["en", "zh-CN", "zh-TW", "th", "ja"]
    
    # แปลข้อความไปยังทุกภาษาที่ผู้ใช้กำหนด
    translations = translate_text(text, codeLang)
    
    # แสดงผลการแปล
    print_translations(text, translations)

    # หากต้องการแสดงผลลัพธ์ในรูปแบบ array (dictionary)
    print("\nTranslations as array:")
    print(translations)
