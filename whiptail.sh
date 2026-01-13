#!/bin/bash

#################################
# ORTAK FONKSİYONLAR
#################################

select_pdf() {
    FILE=$(whiptail --inputbox "PDF dosyasının TAM yolunu giriniz:" 10 70 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return 1

    if [[ "${FILE,,}" != *.pdf ]] || [ ! -f "$FILE" ]; then
        whiptail --msgbox "Geçerli bir PDF dosyası giriniz!" 8 50
        return 1
    fi
    echo "$FILE"
}

info() {
    whiptail --msgbox "$1" 10 60
}

#################################
# PDF SIKISTIR
#################################
pdf_sikistir() {
    INPUT=$(select_pdf) || return
    BASE=$(basename "$INPUT" .pdf)
    DIR=$(dirname "$INPUT")
    OUTPUT="$DIR/${BASE}_sikistirilmis.pdf"

    TYPE=$(python3 pdfturu.py "$INPUT" 2>/dev/null)

    case "$TYPE" in
        image) QUALITY="/screen" ;;
        text)  QUALITY="/ebook" ;;
        *)     QUALITY="/printer" ;;
    esac

    info "PDF analiz edildi.\nTür: $TYPE\nSıkıştırma başlatılıyor..."

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
       -dPDFSETTINGS=$QUALITY -dNOPAUSE -dBATCH -dQUIET \
       -sOutputFile="$OUTPUT" "$INPUT"

    if [ $? -eq 0 ]; then
        info "Sıkıştırma tamamlandı.\nÇıktı:\n$OUTPUT"
    else
        info "Sıkıştırma sırasında hata oluştu!"
    fi
}

#################################
# PDF BİRLEŞTİR
#################################
pdf_birlestir() {

    FILES=$(whiptail --inputbox \
"Birleştirilecek PDF dosyalarının TAM yollarını
aralarında BOŞLUK olacak şekilde giriniz:

Örnek:
/home/user/a.pdf /home/user/b.pdf" \
15 70 3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && return

    OUTPUT=$(whiptail --inputbox \
"Oluşturulacak PDF dosyasının TAM yolunu giriniz:" \
10 70 3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && return

    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite \
       -sOutputFile="$OUTPUT" $FILES

    if [ $? -eq 0 ]; then
        info "PDF dosyaları başarıyla birleştirildi.\n\nÇıktı:\n$OUTPUT"
    else
        info "PDF birleştirme sırasında hata oluştu!"
    fi
}

#################################
# PDF TEK SAYFA BÖL
#################################
pdf_teksayfa() {
    INPUT=$(select_pdf) || return
    DIR=$(dirname "$INPUT")
    BASE=$(basename "$INPUT" .pdf)

    PAGES=$(gs -q -dNODISPLAY -dNOSAFER \
        -c "($INPUT) (r) file runpdfbegin pdfpagecount = quit")

    if [ "$PAGES" -le 1 ]; then
        info "PDF yalnızca 1 sayfa içeriyor."
        return
    fi

    OUT="$DIR/${BASE}_pages"
    mkdir -p "$OUT"

    for ((i=1;i<=PAGES;i++)); do
        gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH \
           -dFirstPage=$i -dLastPage=$i \
           -sOutputFile="$OUT/page$(printf %02d $i).pdf" "$INPUT"
    done

    info "PDF sayfa sayfa bölündü.\nÇıktı:\n$OUT"
}

#################################
# PDF HER N SAYFADA BÖL
#################################
pdf_n_bol() {
    INPUT=$(select_pdf) || return

    N=$(whiptail --inputbox "Kaç sayfada bir bölünsün?" 8 50 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    DIR=$(dirname "$INPUT")
    BASE=$(basename "$INPUT" .pdf)
    OUT="$DIR/${BASE}_bolunmus"
    mkdir -p "$OUT"

    PAGES=$(gs -q -dNODISPLAY -dNOSAFER \
        -c "($INPUT) (r) file runpdfbegin pdfpagecount = quit")

    part=1
    for ((i=1;i<=PAGES;i+=N)); do
        end=$((i+N-1))
        gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH \
           -dFirstPage=$i -dLastPage=$end \
           -sOutputFile="$OUT/part$part.pdf" "$INPUT"
        ((part++))
    done

    info "PDF $N sayfada bir bölündü.\nÇıktı:\n$OUT"
}

#################################
# PDF ARALIK BÖL
#################################
pdf_aralik() {
    INPUT=$(select_pdf) || return

    RANGE=$(whiptail --inputbox "Sayfa aralığı giriniz (örn: 3-7)" 8 50 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    FIRST=${RANGE%-*}
    LAST=${RANGE#*-}

    DIR=$(dirname "$INPUT")
    BASE=$(basename "$INPUT" .pdf)
    OUT="$DIR/${BASE}_${FIRST}_${LAST}.pdf"

    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH \
       -dFirstPage=$FIRST -dLastPage=$LAST \
       -sOutputFile="$OUT" "$INPUT"

    info "Belirtilen aralık çıkarıldı.\nÇıktı:\n$OUT"
}

#################################
# ANA MENÜ
#################################
while true; do
    CHOICE=$(whiptail --title "PDF ARAÇ SETİ" --menu "Bir işlem seçiniz:" 15 60 6 \
        "1" "PDF Sıkıştır" \
        "2" "PDF Birleştir" \
        "3" "PDF Böl - Tek Sayfa" \
        "4" "PDF Böl - Her N Sayfa" \
        "5" "PDF Böl - Aralık" \
        "0" "Çıkış" 3>&1 1>&2 2>&3)

    case "$CHOICE" in
        1) pdf_sikistir ;;
        2) pdf_birlestir ;;
        3) pdf_teksayfa ;;
        4) pdf_n_bol ;;
        5) pdf_aralik ;;
        0|*) exit 0 ;;
    esac
done

