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
         Geçersiz PDF dosyası.
    </span>" \
    --button="Tekrar Sec!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    --height="130" \
    --width="400"
  RET=$?

  if [ "$RET" -eq 252 ]; then
    exit 0
  elif [ "$RET" -eq 1 ]; then
    exec "./menu.sh"
  else
    exec "./aralikbol.sh"
  fi
fi

# Sayfa / Aralık al
RANGE=$(yad --entry \
            --title="Sayfa veya Aralık" \
            --text="<span  size='10000' weight='bold' font_family='Sans'>
                  Lütfen sayfa numarasını veya sayfa aralığını giriniz...
              </span>
              <span  size='10000' weight='bold' font_family='Sans'>
                  (Örn: 3 ya da 2-5)
              </span>" \
            --button="Tamam!gtk-ok:0" \
            --button="Menu!go-previous:1" \
            --height="130" \
            --width="500")
            RET=$?
            
    if [ "$RET" -eq 252 ]; then
      exit 0
    elif [ "$RET" -eq 1 ]; then
      exec "./menu.sh"
    fi

# Giriş türünü ayırt et
if [[ "$RANGE" =~ ^[0-9]+$ ]]; then
    START_PAGE="$RANGE"
    END_PAGE="$RANGE"
elif [[ "$RANGE" =~ ^[0-9]+-[0-9]+$ ]]; then
    START_PAGE=${RANGE%-*}
    END_PAGE=${RANGE#*-}
else
    yad --error \
    --title="Hata" \
    --image="dialog-error" \
    --text="<span  size='10000' weight='bold' font_family='Sans'>
    Geçersiz giriş. Lütfen geçerli bir değer giriniz.
    </span>" \
    --button="Tekrar Dene!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    --height="130" \
    --width="400"
    RET=$?
            
    if [ "$RET" -eq 252 ]; then
      exit 0
    elif [ "$RET" -eq 1 ]; then
      exec "./menu.sh"
    else
      exec "./aralikbol.sh"
    fi
    
fi

# Toplam sayfa sayısı
PAGE_COUNT=$(gs -q -dNODISPLAY -dNOSAFER \
    -c "($INPUT) (r) file runpdfbegin pdfpagecount = quit")

# Aralık kontrolü
if [ "$START_PAGE" -lt 1 ] || [ "$END_PAGE" -gt "$PAGE_COUNT" ] || [ "$START_PAGE" -gt "$END_PAGE" ]; then
    yad --error \
    --title="Hata" \
    --image="dialog-error" \
    --text="<span  size='10000' weight='bold' font_family='Sans'>
         Geçersiz sayfa numarası girdiniz!
     </span>" \
    --height="130" \
    --width="600" \
    --button="Tekrar Dene!gtk-ok:0" \
    --button="Menu!go-previous:1" 
    
     RET=$?
            
    if [ "$RET" -eq 252 ]; then
      exit 0
    elif [ "$RET" -eq 1 ]; then
      exec "./menu.sh"
    else 
      exec "./aralikbol.sh"
    fi
fi

# Çıktı dosyası
DIR="$(dirname "$INPUT")"
BASE="$(basename "$INPUT" .pdf)"

if [ "$START_PAGE" -eq "$END_PAGE" ]; then
    OUTPUT="$DIR/${BASE}_page${START_PAGE}.pdf"
else
    OUTPUT="$DIR/${BASE}_${START_PAGE}-${END_PAGE}.pdf"
fi

# Ghostscript
gs -dNOSAFER -sDEVICE=pdfwrite -dBATCH -dNOPAUSE \
   -dFirstPage="$START_PAGE" \
   -dLastPage="$END_PAGE" \
   -sOutputFile="$OUTPUT" \
   "$INPUT"

yad --info \
    --title="Başarılı" \
    --image="dialog-ok" \
    --text="<span  size='10000' weight='bold' font_family='Sans'>
                 PDF olusturuldu --> $OUTPUT
            </span>" \
    --button="Tamam!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    --height="130" \
    --width="600"
    
        RET=$?
            
    if [ "$RET" -eq 252 ]; then
      exit 0
    elif [ "$RET" -eq 1 ]; then
      exec "./menu.sh"
    fi
    





