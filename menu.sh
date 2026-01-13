#!/bin/bash

CSS_FILE="$(dirname "$0")/style.css"

CHOICE=$(yad \
    --title="📄 PDF Araçları" \
    --width=520 \
    --height=360 \
    --center \
    --list \
    --separator="" \
    --column="Icon:IMG" \
    --column="İşlem" \
    "document-open"   "PDF Birleştir" \
    "document-split"  "PDF Böl" \
    "document-save"   "PDF Sıkıştır" \
    --button="Çıkış!application-exit":1
)

RET=$?

# Çıkış butonu
if [ "$RET" -ne 0 ]; then
    exit 0
fi

case "$CHOICE" in
    "PDF Birleştir")
        ./pdfbirlestir.sh
        ;;
    "PDF Böl")
        ./pdfbol.sh
        ;;
    "PDF Sıkıştır")
        ./sikistir.sh
        ;;
esac
