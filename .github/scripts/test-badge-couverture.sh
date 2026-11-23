#!/bin/sh
# Tests de badge-couverture.sh.
S="$(cd "$(dirname "$0")" && pwd)/badge-couverture.sh"
ECHECS=0
verifie() { # nom motif fichier
  if grep -q -- "$2" "$3"; then echo "ok   $1"; else echo "ECHEC $1 : '$2' absent de $3"; ECHECS=$((ECHECS+1)); fi
}
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
"$S" 91.4 "$T/a/a.svg"; verifie "91.4 -> 91% vert" '>91%<' "$T/a/a.svg"; verifie "vert" '#4c1' "$T/a/a.svg"
"$S" 65 "$T/b.svg"; verifie "65 jaune" '#dfb317' "$T/b.svg"
"$S" 12 "$T/c.svg"; verifie "12 rouge" '#e05d44' "$T/c.svg"
"$S" "" "$T/d.svg"; verifie "absent -> n/d" 'n/d' "$T/d.svg"
"$S" abc "$T/e.svg"; verifie "invalide -> n/d" 'n/d' "$T/e.svg"
"$S" 250 "$T/f.svg"; verifie "hors bornes -> n/d" 'n/d' "$T/f.svg"
if command -v python3 >/dev/null; then
  python3 -I -c 'import sys,xml.dom.minidom as m; m.parse(sys.argv[1])' "$T/a/a.svg" && echo "ok   SVG bien formé" || { echo "ECHEC SVG mal formé"; ECHECS=$((ECHECS+1)); }
fi
if [ "$ECHECS" -eq 0 ]; then echo "Tous les tests passent."; else echo "$ECHECS échec(s)."; exit 1; fi
