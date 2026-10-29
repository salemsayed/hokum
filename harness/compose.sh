#!/bin/sh
# compose.sh <distro> <title>: before | after of the cards and of the Applications list.
set -eu
cd "$(dirname "$0")/out"
d=$1 title=$2
for b in before after; do
  magick $d-$b.png -crop 560x1000+940+0 +repage -fuzz 1% -fill '#c9d6e3' -draw 'color 0,999 floodfill' -trim +repage -bordercolor '#c9d6e3' -border 20 $d-$b-cards.png
done
h=$(magick identify -format '%h\n' $d-before-cards.png $d-after-cards.png | sort -n | tail -1)
for b in before after; do
  label=$( [ $b = before ] && echo "Before (upstream dev)" || echo "After (this change)" )
  magick $d-$b-cards.png -background '#c9d6e3' -gravity north -extent x$h \
    \( -size "$(magick identify -format %w $d-$b-cards.png)"x44 xc:'#c9d6e3' -font DejaVu-Sans -pointsize 20 -fill '#223' -gravity center -annotate 0 "$label" \) \
    +swap -append $d-$b-labelled.png
done
magick $d-before-labelled.png $d-after-labelled.png +append $d-pair.png
w=$(magick identify -format %w $d-pair.png)
magick \( -size ${w}x56 xc:'#e8eef4' -font DejaVu-Sans-Bold -pointsize 22 -fill '#112' -gravity center -annotate 0 "$title" \) $d-pair.png -append $d-compare.png
rm -f $d-pair.png
if [ -s $d-before-apps.png ] && [ -s $d-after-apps.png ]; then
  magick $d-before-apps.png $d-after-apps.png -resize 50% +append $d-apps-compare.png
fi
echo out/$d-compare.png
