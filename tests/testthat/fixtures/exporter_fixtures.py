"""Exporte en CSV le jeu synthetique du prototype Python et ses valeurs de reference.

Mission 004. A lancer depuis la racine du projet :

    PYTHONPATH=src python3 tests/testthat/fixtures/exporter_fixtures.py

Jeu : 30 x 30 pixels, 200 placettes, graine 1, configuration d'exemple
(config/exemple.json, SER exemple-alpes-du-nord). Fichiers ecrits a cote du script :

- placettes.csv, pixels.csv : entrees de la chaine (memes colonnes que le prototype) ;
- verite.csv : h_pot reelle du generateur (i, j, h_pot), pour juger la hauteur potentielle ;
- cle_reference.csv : probabilites de la cle floue sur des lignes fixees (deterministe) ;
- lissage_reference.csv : lissage 3 x 3 d'une petite grille avec un trou ;
- references_prototype.csv : chiffres de la demonstration (precision, kappa, RMSE...).

Les valeurs sont celles du prototype tel qu'il est le jour de l'export ; elles ne sont pas
une verite, seulement le point de comparaison du portage R.
"""

from pathlib import Path

import numpy as np
import pandas as pd

from typopeuplement.chaine import executer, types_observes
from typopeuplement.hauteur_potentielle import ModeleHauteurPotentielle
from typopeuplement.cle import Cle, appartenances, classer
from typopeuplement.lissage import lisser
from typopeuplement.modeles import comparer_classifieurs
from typopeuplement.ser import charger_configuration
from typopeuplement.synthetique import generer

ICI = Path(__file__).resolve().parent
RACINE = ICI.parents[2]
SER = "exemple-alpes-du-nord"


def main() -> None:
    conf = charger_configuration(RACINE / "config" / "exemple.json", SER)
    placettes, pixels, verite = generer(ni=30, nj=30, n_placettes=200, graine=1)

    placettes.to_csv(ICI / "placettes.csv", index=False, float_format="%.10g")
    pixels.to_csv(ICI / "pixels.csv", index=False, float_format="%.10g")
    pd.concat([pixels[["i", "j"]], verite[["h_pot"]]], axis=1).to_csv(
        ICI / "verite.csv", index=False, float_format="%.10g"
    )

    # --- cle floue : lignes fixees, dont des valeurs pile sur les seuils et des NaN.
    cle = Cle.depuis_dict(conf["cle"])
    lignes = [
        # part_resineux, part_pb, part_bm, part_gb, rapport_h
        (0.00, 0.3, 0.4, 0.3, 0.50),
        (0.35, 0.3, 0.4, 0.3, 0.50),   # pile sur le seuil F / M
        (0.50, 0.3, 0.4, 0.3, 0.50),
        (0.65, 0.6, 0.3, 0.1, 0.30),   # pile sur le seuil M / resineux
        (0.90, 0.6, 0.3, 0.1, 0.30),
        (0.90, 0.6, 0.3, 0.1, 0.60),   # pile sur le seuil rapport_h
        (0.90, 0.6, 0.3, 0.1, 0.90),
        (0.90, 0.6, 0.3, 0.1, np.nan),  # hauteur potentielle incertaine
        (0.90, 0.1, 0.3, 0.6, 0.80),
        (0.90, 0.3, 0.4, 0.3, np.nan),
        (0.90, 0.5, 0.0, 0.5, 0.20),
        (1.00, 0.0, 1.0, 0.0, 0.70),
    ]
    rng = np.random.default_rng(1)
    for _ in range(8):
        pb, bm = rng.dirichlet([1, 1, 1])[:2]
        rh = np.nan if rng.random() < 0.25 else rng.uniform(0.2, 1.0)
        lignes.append((rng.uniform(0, 1), pb, bm, 1 - pb - bm, rh))
    var = pd.DataFrame(lignes, columns=["part_resineux", "part_pb", "part_bm", "part_gb", "rapport_h"])
    cl = classer(cle, var)
    dur = types_observes(cle, var)
    ref = pd.concat([var, cl, dur.rename("type_dur")], axis=1)
    ref.to_csv(ICI / "cle_reference.csv", index=False, float_format="%.12g")

    # --- lissage : grille 4 x 5 avec un trou en (1, 2).
    r = np.random.default_rng(2)
    ii, jj = np.meshgrid(np.arange(4), np.arange(5), indexing="ij")
    g = pd.DataFrame({"i": ii.ravel(), "j": jj.ravel()})
    g = g[~((g.i == 1) & (g.j == 2))].reset_index(drop=True)
    p = pd.DataFrame(r.dirichlet([1, 1, 1], len(g)), columns=["A", "B", "C"])
    lis = lisser(p, g["i"], g["j"], 3)
    pd.concat([g, p.add_prefix("p_"), lis.add_prefix("l_")], axis=1).to_csv(
        ICI / "lissage_reference.csv", index=False, float_format="%.12g"
    )

    # --- chiffres de la demonstration.
    res = executer(placettes, pixels, conf)
    f = res["fiche_validation"]
    c = res["carte"]
    obs = res["types_observes"]
    err = res["erreurs_variables"]
    comp = comparer_classifieurs(placettes[conf["predicteurs"]], obs, plis=3)
    mesures = []

    def ajouter(grandeur, valeur):
        mesures.append({"grandeur": grandeur, "valeur": float(valeur)})

    ajouter("n_placettes", len(placettes))
    ajouter("n_pixels", len(pixels))
    for niveau in ("placette", "grappe"):
        ajouter(f"{niveau}_n", f[niveau]["n"])
        ajouter(f"{niveau}_precision_globale", f[niveau]["precision_globale"])
        ajouter(f"{niveau}_kappa", f[niveau]["kappa"])
    ajouter("pct_entre_deux", c["entre_deux"].mean())
    ajouter("pct_hp_incertaine", c["hp_incertaine"].mean())
    for fam, v in res["rmse_hauteur_potentielle"].items():
        ajouter(f"rmse_hp_{fam}", v)
    # Hauteur potentielle contre la verite du generateur, sur les peuplements adultes fermes.
    m = ModeleHauteurPotentielle(conf["variables_milieu"], graine=conf.get("graine", 0)).ajuster(pixels)
    hp = m.predire(pixels)
    adultes = m.peuplements_adultes(pixels)
    ajouter("n_adultes", adultes.sum())
    ajouter("rmse_hp_vs_verite_adultes", np.sqrt(((hp["h_pot"] - verite["h_pot"])[adultes] ** 2).mean()))
    for var_, row in err.iterrows():
        ajouter(f"rmse_{var_}", row["rmse"])
    for code in conf["cle"]["types"]:
        ajouter(f"n_observe_{code['code']}", (obs == code["code"]).sum())
        ajouter(f"n_carte_{code['code']}", (c["type"] == code["code"]).sum())
    for nom, row in comp.iterrows():
        ajouter(f"kappa_{nom}", row["kappa"])
    pd.DataFrame(mesures).to_csv(ICI / "references_prototype.csv", index=False, float_format="%.10g")
    print(pd.DataFrame(mesures).to_string())


if __name__ == "__main__":
    main()
