#!/bin/bash

# PDF seçtir
INPUT=$(yad --file \
    --title="PDF Dosyası Seç" \
    --center \
    --width=700 \
    --height=500)

# PDF kontrolü
if [[ "${INPUT,,}" != *.pdf ]]; then
    yad --error \
        --title="Hata" \
        --image="dialog-error" \
        --text="<span size='10000' weight='bold' font_family='Sans'>
        Lütfen bir PDF dosyası seçiniz.
        </span>" \
        --button="Tekrar Sec!gtk-ok:0" \
        --button="Menu!go-previous:1" \
        --width="470" \
        --height="130"
  RET=$?

      if [ "$RET" -eq 252 ]; then
        exit 0
      elif [ "$RET" -eq 1 ]; then
        exec "./menu.sh"
      elif [ "$RET" -eq 0 ]; then
        exec "./sikistir.sh"
      else
        exit 0
      fi

fi


BASE="$(basename "$INPUT" .pdf)"
DIR="$(dirname "$INPUT")"
OUTPUT="$DIR/${BASE}_sikistirilmis.pdf"

# Çıktı dosyası varsa sor
if [ -f "$OUTPUT" ]; then
    yad --question \
        --title="Dosya Mevcut" \
        --image="dialog-warning" \
        --text="<span size='10000' weight='bold' font_family='Sans'>
        ${BASE}_sikistirilmis.pdf dosyası zaten mevcut.
        </span>
        <span size='10000' weight='bold' font_family='Sans'>
         Üzerine yazılsın mı?  
        </span>" \
        --button="İptal!gtk-cancel:1" \
        --button="Tamam!gtk-ok:0" \
        --width="470" \
        --height="130"

    if [ $? -ne 0 ]; then
        yad --info \
            --title="Hata" \
            --image="process-stop" \
            --text="<span size='10000' weight='bold' font_family='Sans'>  
               İşlem iptal edildi.
            </span>" \
            --width="470" \
            --height="130" \
            --button="Tamam!gtk-ok:0" \
            --button="Menu!go-previous:1"
  RET=$?
      if [ "$RET" -eq 252 ]; then
        exit 0
      elif [ "$RET" -eq 1 ]; then
        exec "./menu.sh"
      else
        exit 0
      fi
    fi
fi

# PDF türünü belirle
PDF_TYPE=$(python3 pdfturu.py "$INPUT")

if [ "$PDF_TYPE" = "text" ]; then
    MSG="<span size='10000' weight='bold'>
        PDF belgesi metin ağırlıklı.
    </span>
         <span size='10000' weight='bold'> 
        Dengeli sıkıştırma uygulanacak. 
    </span>"
elif [ "$PDF_TYPE" = "image" ]; then
    MSG="<span size='10000' weight='bold'>
         PDF belgesi görsel ağırlıklı.
   </span>
   <span size='10000' weight='bold'> 
         Yüksek sıkıştırma uygulanacak.
   </span>"
else
    MSG="<span size='10000' weight='bold'> 
         PDF türü tespit edilemedi.
    </span>
         <span size='10000' weight='bold'>
         Varsayılan ayar kullanılacak.
    </span>"
fi

# Analiz sonucu göster
yad --info \
    --title="PDF Analizi" \
    --image="dialog-information" \
    --text="$MSG" \
    --width=470 \
    --height=130 \
    --button="İptal!gtk-cancel:1" \
    --button="Tamam!gtk-ok:0"

if [ $? -ne 0 ]; then
    yad --info \
        --image="process-stop" \
        --title="Hata" \
        --text="<span size='10000' weight='bold'>
           İşlem iptal edildi.
        </span>" \
        --width="470" \
        --height="130" \
        --button="Tamam!gtk-ok:0" \
        --button="Menu!go-previous:1"
 RET=$?
      if [ "$RET" -eq 252 ]; then
        exit 0
      elif [ "$RET" -eq 1 ]; then
        exec "./menu.sh"
      else
        exit 0
      fi
fi

# Ghostscript kalite ayarı
if [ "$PDF_TYPE" = "image" ]; then
    GS_QUALITY="/screen"
elif [ "$PDF_TYPE" = "text" ]; then
    GS_QUALITY="/ebook"
else
    GS_QUALITY="/printer"
fi

# Progress
yad --progress \
    --title="PDF Sıkıştırılıyor" \
    --pulsate \
    --auto-close \
    --no-cancel \
    --text="<span size='10000' weight='bold'>
    PDF dosyası sıkıştırılıyor…
    </span>" &

PROGRESS_PID=$!

# Sıkıştırma
gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=$GS_QUALITY \
   -dNOPAUSE -dBATCH -dQUIET \
   -sOutputFile="$OUTPUT" \
   "$INPUT"

GS_STATUS=$?

# Progress kapat
kill "$PROGRESS_PID" 2>/dev/null

# Sonuç
if [ $GS_STATUS -eq 0 ]; then
    yad --info \
        --title="Başarılı" \
        --image="dialog-information" \
        --text="<span size='10000' weight='bold'>
        Sıkıştırma tamamlandı.
        </span>
        <span size='10000' weight='bold'>
        Çıktı: $OUTPUT
        </span>" \
        --width=420 \
        --height=130 \
        --button="Tamam!gtk-ok:0" \
        --button="Menu!go-previous:1"
  RET=$?
      if [ "$RET" -eq 252 ]; then
        exit 0
      elif [ "$RET" -eq 1 ]; then
        exec "./menu.sh"
      else
        exit 0
      fi

else
    yad --error \
        --title="Hata" \
        --image="dialog-error" \
        --text="<span></span>
        <span size='10000' weight='bold'>
        Sıkıştırma sırasında hata oluştu.
        </span>" \
        --width="300" \
        --height="130" \
        --button="Tamam!gtk-ok:0" \
        --button="Menu!go-previous:1"
  RET=$?
      if [ "$RET" -eq 252 ]; then
        exit 0
      elif [ "$RET" -eq 1 ]; then
        exec "./menu.sh"
      else
        exit 0
      fi

fi


