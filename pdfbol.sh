#!/bin/bash
# PDF Bölme Menüsü
CHOICE=$(yad --title="PDF Bölme Seçenekleri" \
    --window-icon="x-office-document" \
    --list \
    --column="Seçenek" \
    "Tek sayfa böl" \
    "Her N sayfada böl" \
    "Belirli aralık ile böl" \
    --height=200 \
    --width=300 \
    --center \
    --width="470" \
    --height="130" \
    --button="Geri!go-previous:1")
    
if [ $? -eq 1 ]; then
    exec ./menu.sh
    exit 0
fi

# Temizleme
CHOICE=$(echo "$CHOICE" | tr -d '"')   # tırnakları kaldır
CHOICE=${CHOICE%"|"}                    # sondaki | işaretini kaldır



case "$CHOICE" in
    "Tek sayfa böl")
        ./teksayfa.sh "$INPUT"
        ;;
    "Her N sayfada böl")
        ./nsayfabol.sh "$INPUT" 
        ;;
    "Belirli aralık ile böl")
        ./aralikbol.sh "$INPUT"
        ;;
    *)
       
esac

