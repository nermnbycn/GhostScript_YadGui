#!/bin/bash
PDFLER=$(yad --file-selection \
    --multiple \
    --separator="|" \
    --title="Birleştirilecek PDF'leri Seç" \
    --center \
    --width=700 \
    --height=500)
[ -z "$PDFLER" ] && exit 1

OUTPUT=$(yad --entry \
  --title="Çıktı Dosya Adı" \
  --text="<span size='10000' weight='bold' font_family='Sans'>
    Oluşturulacak PDF dosyasının adını giriniz...
    </span>" \
  --entry-text="birlestirilmis.pdf" \
  --center \
  --width=420 \
  --height=120 \
  --button="İptal!gtk-cancel:1" \
  --button="Tamam!gtk-ok:0"


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
    fi)


[ -z "$OUTPUT" ] && exit 1

if [ -f "$OUTPUT" ]; then
    yad --question \
    --title="Uyarı" \
    --image="dialog-question" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
    '$OUTPUT' zaten mevcut.</span>
    <span size='11000' weight='bold' font_family='Sans'>
    Üzerine yazılsın mı?
    </span>" \
    --center \
    --width=470 \
    --height=130 \
    --button="Hayır!gtk-no:1" \
    --button="Evet!gtk-yes:0"
   
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

PDFLER="${PDFLER//|/ }"
gs -dBATCH -dNOPAUSE -q \
   -sDEVICE=pdfwrite \
   -sOutputFile="$OUTPUT" \
   $PDFLER

if [ $? -eq 0 ]; then
    yad --info \
    --title="Başarılı" \
    --width=470 \
    --height=130 \
    --center \
    --button="Tamam!gtk-ok:0" \
    --image="dialog-information" \
    --text="<span  size='10000' weight='bold' font_family='Sans'>
    PDF başarıyla oluşturuldu ==> $OUTPUT
    </span>"
else
    yad --error \
    --title="Hata" \
    --image="dialog-error" \
    --text="<span size='10000' weight='bold' font_family='Sans'>
    PDF birleştirme sırasında hata oluştu.
    </span>" \
    --center \
    --width=450 \
    --height=120 \
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

