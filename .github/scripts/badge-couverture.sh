#!/bin/sh
# Génère un badge SVG de couverture, localement, sans service externe.
# Usage : badge-couverture.sh POURCENTAGE [FICHIER_SORTIE]
#   POURCENTAGE : nombre de 0 à 100 (décimales admises) ; absent ou invalide -> badge « n/d ».
#   FICHIER_SORTIE : défaut .github/badges/couverture.svg
PCT="${1:-}"
OUT="${2:-.github/badges/couverture.svg}"
case "$PCT" in
  ''|*[!0-9.]*|*.*.*) TXT="n/d"; COUL="#9f9f9f" ;;
  *)
    ENTIER=$(printf '%.0f' "$PCT")
    if [ "$ENTIER" -gt 100 ]; then TXT="n/d"; COUL="#9f9f9f"
    else
      TXT="${ENTIER}%"
      if   [ "$ENTIER" -ge 80 ]; then COUL="#4c1"
      elif [ "$ENTIER" -ge 60 ]; then COUL="#dfb317"
      else COUL="#e05d44"; fi
    fi ;;
esac
mkdir -p "$(dirname "$OUT")"
cat > "$OUT" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="106" height="20" role="img" aria-label="couverture: $TXT">
  <title>couverture: $TXT</title>
  <rect width="70" height="20" fill="#555"/>
  <rect x="70" width="36" height="20" fill="$COUL"/>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" font-size="11">
    <text x="35" y="14">couverture</text>
    <text x="88" y="14">$TXT</text>
  </g>
</svg>
SVG
