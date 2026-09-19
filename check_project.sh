#!/bin/bash

echo "=============================================="
echo "🔍 بدء فحص مشروع Godot قبل الرفع والبناء..."
echo "=============================================="

ERRORS=0
WARNINGS=0

# 1. فحص سلامة ملفات المشاهد .tscn من البتر أو التلف
echo -e "\n📁 [1/4] فحص ملفات المشاهد (.tscn)..."
for file in $(find scenes -name "*.tscn" 2>/dev/null); do
    if grep -q "EOF" "$file" || ! head -n 1 "$file" | grep -q "\[gd_scene"; then
        echo "❌ خطأ قاتل: الملف $file تالف أو يحتوي أسطر ملتصقة!"
        ERRORS=$((ERRORS+1))
    fi
done

# 2. فحص مسارات res:// المذكورة في السكربتات للتأكد من وجود الملفات فعلياً
echo -e "\n🔗 [2/4] فحص المسارات المستدعاة (res://) داخل السكربتات..."
grep -rn "res://" scripts/ 2>/dev/null | grep -o "res://[^\"]*" | sort -u | while read -r path; do
    clean_path=$(echo "$path" | tr -d '";)')
    real_path=${clean_path#res://}
    if [ ! -f "$real_path" ] && [ ! -d "$real_path" ]; then
        echo "⚠️ تحذير: مسار استدعاء غير موجود على القرص: $clean_path"
    fi
done

# 3. فحص السكربتات للتحقق من أخطاء بناء القواعد في GDScript
echo -e "\n💻 [3/4] فحص القواعد الأساسية لملفات GDScript..."
for file in $(find scripts -name "*.gd" 2>/dev/null); do
    # فحص الأسطر المكسورة أو الدوال التي تنقصها النقطتان
    grep -n "^func " "$file" | grep -v ":$" | while read -r line; do
        echo "⚠️ تنبيه بناء دالة في $file: $line"
        WARNINGS=$((WARNINGS+1))
    done
done

# 4. فحص المحرك الشامل (Headless Check) إذا كان أمر godot متوفر في التيرمينال
echo -e "\n⚙️ [4/4] فحص Godot البرمجي الشامل..."
if command -v godot &> /dev/null; then
    godot --headless --check-only --quit 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ فحص المحرك: المشروع خالي من أخطاء الـ Syntax."
    else
        echo "❌ فحص المحرك: تم اكتشاف أخطاء في الكود!"
        ERRORS=$((ERRORS+1))
    fi
else
    echo "ℹ️ أمر محرك godot غير مدمج في خط أسر التيرمينال (سيقوم المحرك بتأكيد الفحص تلقائياً عند الفتح)."
fi

echo -e "\n=============================================="
if [ $ERRORS -eq 0 ]; then
    echo "🎉 التقرير النهائي: جميع الملفات سليمة وجاهزة للبناء والرفع!"
else
    echo "⛔ التقرير النهائي: تم العثور على $ERRORS أخطاء يجب معالجتها."
fi
echo "=============================================="
