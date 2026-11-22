"""Ligne de commande : ``python -m typopeuplement``.

- ``demo`` : fait tourner la chaîne sur un jeu synthétique et écrit les livrables ;
- ``executer`` : fait tourner la chaîne sur des tableaux CSV (placettes, pixels) ;
- ``comparer`` : compare forêts aléatoires, SVM et analyse discriminante.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd

from .chaine import executer, types_observes
from .cle import Cle
from .modeles import comparer_classifieurs
from .ser import charger_configuration
from .synthetique import generer
from .validation import fiche_en_markdown

CONF_EXEMPLE = Path(__file__).resolve().parents[2] / "config" / "exemple.json"


def _ecrire(res: dict, sortie: Path) -> None:
    sortie.mkdir(parents=True, exist_ok=True)
    res["carte"].to_csv(sortie / "carte_types.csv", index=False)
    res["erreurs_variables"].to_csv(sortie / "erreurs_variables.csv")
    (sortie / "fiche_validation.md").write_text(fiche_en_markdown(res["fiche_validation"]), encoding="utf-8")
    (sortie / "rmse_hauteur_potentielle.json").write_text(
        json.dumps(res["rmse_hauteur_potentielle"], indent=2), encoding="utf-8"
    )


def _resume(res: dict) -> str:
    f = res["fiche_validation"]
    c = res["carte"]
    return (
        f"SER {f['ser']} : {len(c)} pixels classés\n"
        f"  précision à la placette : {f['placette']['precision_globale']:.1%} (kappa {f['placette']['kappa']:.2f})\n"
        f"  précision à la grappe   : {f['grappe']['precision_globale']:.1%} (kappa {f['grappe']['kappa']:.2f})\n"
        f"  pixels entre deux types : {c['entre_deux'].mean():.1%}\n"
        f"  hauteur potentielle incertaine : {c['hp_incertaine'].mean():.1%}"
    )


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="typopeuplement")
    sub = ap.add_subparsers(dest="commande", required=True)

    d = sub.add_parser("demo", help="chaîne complète sur données synthétiques")
    d.add_argument("--config", default=str(CONF_EXEMPLE))
    d.add_argument("--ser", default="exemple-alpes-du-nord")
    d.add_argument("--sortie", default="sorties/demo")
    d.add_argument("--graine", type=int, default=0)

    e = sub.add_parser("executer", help="chaîne complète sur CSV")
    e.add_argument("--config", required=True)
    e.add_argument("--ser", required=True)
    e.add_argument("--placettes", required=True)
    e.add_argument("--pixels", required=True)
    e.add_argument("--sortie", required=True)

    c = sub.add_parser("comparer", help="comparer les classifieurs sur des placettes CSV")
    c.add_argument("--config", required=True)
    c.add_argument("--ser", required=True)
    c.add_argument("--placettes", required=True)

    a = ap.parse_args(argv)
    conf = charger_configuration(a.config, a.ser)
    if a.commande == "demo":
        conf["graine"] = a.graine
        placettes, pixels, _ = generer(graine=a.graine)
        res = executer(placettes, pixels, conf)
        _ecrire(res, Path(a.sortie))
        print(_resume(res))
    elif a.commande == "executer":
        res = executer(pd.read_csv(a.placettes), pd.read_csv(a.pixels), conf)
        _ecrire(res, Path(a.sortie))
        print(_resume(res))
    else:
        plac = pd.read_csv(a.placettes)
        cle = Cle.depuis_dict(conf["cle"])
        mesures = plac[conf["variables_cibles"]].copy()
        mesures["rapport_h"] = plac["rapport_h"] if "rapport_h" in plac else float("nan")
        y = types_observes(cle, mesures)
        print(comparer_classifieurs(plac[conf["predicteurs"]], y, graine=conf.get("graine", 0)))
    return 0
