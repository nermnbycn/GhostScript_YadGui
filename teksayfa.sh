#!/bin/bash

# PDF seçtir
INPUT=$(yad --file \
    --title="PDF Dosyası Seç" \
    --center \
    --width=700 \
    --height=500)
    
    
# Seçilen dosya PDF mi
if [[ "${INPUT,,}" != *.pdf ]]; then
    yad --error \
     --title="Hata" \
    --image="dialog-error" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
         Lütfen bir PDF dosyası seçiniz.
    </span>" \
    --button="Tekrar Sec!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    --height="130" \
    --width="470"
  RET=$?

  if [ "$RET" -eq 252 ]; then
    exit 0
  elif [ "$RET" -eq 1 ]; then
    exec "./menu.sh"
  else
    exec "./teksayfa.sh"
  fi
fi

# PDF dosyasının bulunduğu dizin ve adı
DIRNAME=$(dirname "$INPUT")
BASENAME=$(basename "$INPUT" .pdf)

# Toplam sayfa sayısını alma (NOSAFER mod, sessiz)
PAGE_COUNT=$(gs -q -dNODISPLAY -dNOSAFER -c "($INPUT) (r) file runpdfbegin pdfpagecount = quit")

# Eğer sayfa sayısı 1 ise kullanıcıya bilgi ver
if [ "$PAGE_COUNT" -eq 1 ]; then
    yad --error \
    --image="dialog-error" \
    --title="Hata" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
    Seçilen PDF sadece 1 sayfa içeriyor.
    </span>
    <span size='10000' weight='bold' font_family='Sans'>
    Lütfen başka bir PDF seçin!
    </span>" \
    --button="Tekrar Sec!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    --height="130" \
    --width="470"
    
    RET=$?
    
   if [ "$RET" -eq 252 ]; then
     exit 0
   elif [ $RET -eq 1 ]; then
     exec "./menu.sh"
   else
     exec "./teksayfa.sh"
   fi
fi

# Çıktı klasörü oluştur (örneğin: ornek_pages)
OUTPUT_DIR="$DIRNAME/${BASENAME}_pages"
mkdir -p "$OUTPUT_DIR"

# Sayfa sayfa bölme
for ((i=1; i<=PAGE_COUNT; i++)); do
    PAGE_NUM=$(printf "%02d" $i)
    gs -dNOSAFER -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -dFirstPage=$i -dLastPage=$i \
       -sOutputFile="$OUTPUT_DIR/page$PAGE_NUM.pdf" "$INPUT"
done

yad --info \
    --title="Başarılı" \
    --image="dialog-information" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
      PDF başarıyla sayfa sayfa ayrıldı!
   </span>
   <span size='10000' weight='bold' font_family='Sans'>
      Çıktı dizini ==> $OUTPUT_DIR
   </span>" \
    --button="Tamam!gtk-ok:0" \
    --button="Menu!go-previous:1" \
   --width="470" \
   --height="130" \

RET=$?
 
   if [ "$RET" -eq 252 ]; then
     exit 0
   elif [ $RET -eq 1 ]; then
     exec "./menu.sh"
   else
     exit 0
   fi
fi
