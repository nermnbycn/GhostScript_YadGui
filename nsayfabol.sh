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
    exec "./nsayfabol.sh"
  fi
fi
    
PAGE_COUNT=$(gs -q -dNODISPLAY -dNOSAFER \
    -c "($INPUT) (r) file runpdfbegin pdfpagecount = quit")
if [ "$PAGE_COUNT" -eq 1 ]; then
    yad --error \
    --image="dialog-error" \
    --title="Hata" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
             PDF zaten tek sayfa içeriyor.
    </span>" \
    --button="PDF Seç!gtk-ok:0" \
    --button="Menu!go-previous:1" \
     --width="300" \
    --height="130"
    
  RET=$?
    
  if [ "$RET" -eq 252 ]; then
    exit 0
  elif [ "$RET" -eq 1 ]; then
    exec "./menu.sh"
  else
    exec "./nsayfabol.sh"
  fi
    
fi
N=$(yad --entry \
        --title="Her N Sayfada Böl" \
        --text="<span size='10000' weight='bold' font_family='Sans'>
             Kaç sayfada bir bölünsün?
        </span>")
[ -z "$N" ] && exit 1
if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -lt 1 ]; then
    yad --error \
    --title="Hata" \
    --image="dialog-error" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
             Lütfen geçerli bir sayı girin!
        </span>"
    --button="Sayi Gir!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    --width="300" \
    --height="130"
    
  RET=$?
    
  if [ "$RET" -eq 252 ]; then
    exit 0
  elif [ "$RET" -eq 1 ]; then
    exec "./menu.sh"
  else
    exec "./nsayfabol.sh"
  fi
   
fi


# Çıktı dizini
DIR="$(dirname "$INPUT")"
BASE="$(basename "$INPUT" .pdf)"
OUTPUT_DIR="$DIR/${BASE}_parts"
mkdir -p "$OUTPUT_DIR"

PART=1
START=1

while [ "$START" -le "$PAGE_COUNT" ]; do
    END=$((START + N - 1))
    if [ "$END" -gt "$PAGE_COUNT" ]; then
        END="$PAGE_COUNT"
    fi

    PART_NUM=$(printf "%02d" "$PART")
    OUTPUT="$OUTPUT_DIR/${BASE}_part${PART_NUM}.pdf"

    gs -dNOSAFER -sDEVICE=pdfwrite -dBATCH -dNOPAUSE \
       -dFirstPage="$START" \
       -dLastPage="$END" \
       -sOutputFile="$OUTPUT" \
       "$INPUT"

    PART=$((PART + 1))
    START=$((END + 1))
done

 yad --info \
    --title="Başarılı" \
    --image="dialog-ok" \
    --text="<span  size='10000' weight='bold' font_family='Sans'>
    PDF başarıyla bölündü
    </span>
    <span  size='10000' weight='bold' font_family='Sans'>
    Çıktı dizini : $OUTPUT_DIR
    </span>" \
    --center \
    --width=420 \
    --height=120 \
    --button="Tamam!gtk-ok:0" \
    --button="Menu!go-previous:1" \
    
    if [ "$RET" -eq 252 ]; then
      exit 0
    elif [ "$RET" -eq 1 ]; then
      exec "./menu.sh"
    else
      exit 0
    fi

