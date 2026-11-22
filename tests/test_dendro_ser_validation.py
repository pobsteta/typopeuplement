import json

import numpy as np
import pandas as pd
import pytest

from typopeuplement.dendro import surface_terriere_arbre, variables_placette
from typopeuplement.lissage import lisser
from typopeuplement.ser import charger_configuration, niveau_modele, poids_transition, raccorder
from typopeuplement.validation import agreger_grappes, grappes_par_maille, indicateurs, matrice_confusion


def test_surface_terriere():
    assert surface_terriere_arbre([100])[0] == pytest.approx(np.pi / 4)


def test_categories_dependent_du_seuil_de_la_ser():
    arbres = pd.DataFrame(
        {"placette": ["p"] * 3, "diametre_cm": [15.0, 45.0, 45.0], "resineux": [True, True, False]}
    )
    savoie = variables_placette(arbres, 0.0707, {"precomptage_cm": 17.5, "pb_bm_cm": 27.5, "bm_gb_cm": 42.5})
    vosges = variables_placette(arbres, 0.0707, {"precomptage_cm": 17.5, "pb_bm_cm": 27.5, "bm_gb_cm": 47.5})
    assert savoie.loc["p", "part_gb"] == pytest.approx(1.0)  # l'arbre de 15 cm est sous le précomptage
    assert vosges.loc["p", "part_bm"] == pytest.approx(1.0)
    assert savoie.loc["p", "part_resineux"] == pytest.approx(0.5)
    assert savoie.loc["p", "G"] == pytest.approx(2 * np.pi * 0.45**2 / 4 / 0.0707)


def test_configuration_heritee(tmp_path):
    conf = {
        "national": {"a": 1, "seuils": {"gb": 42.5, "pb": 27.5}},
        "grandes_regions": {"vosges": {"seuils": {"gb": 47.5}}},
        "ser": {"s1": {"grande_region": "vosges", "a": 2}},
    }
    f = tmp_path / "c.json"
    f.write_text(json.dumps(conf))
    eff = charger_configuration(f, "s1")
    assert eff["seuils"] == {"gb": 47.5, "pb": 27.5} and eff["a"] == 2 and eff["ser"] == "s1"
    with pytest.raises(KeyError):
        charger_configuration(f, "inconnue")


def test_heritage_quand_un_type_manque_de_placettes():
    assert niveau_modele({"A": 40, "B": 35}, ["A", "B"], 30) == "ser"
    assert niveau_modele({"A": 40, "B": 5}, ["A", "B"], 30) == "grande_region"


def test_transition_sans_rupture():
    w = poids_transition(np.array([-1000, 0, 250, 1000]), 500)
    assert list(w) == [0.5, 0.5, 0.75, 1.0]
    a = pd.DataFrame({"A": [1.0, 1.0]})
    b = pd.DataFrame({"B": [1.0, 1.0]})
    m = raccorder(a, b, np.array([0.5, 1.0]))
    # Sur la limite, chaque modèle compte pour moitié, et les deux côtés voient la même chose.
    assert m.loc[0, "A"] == pytest.approx(0.5) and m.loc[1, "A"] == pytest.approx(1.0)


def test_matrice_et_kappa():
    m = matrice_confusion(["A", "A", "B", "B"], ["A", "B", "B", "B"], ["A", "B"])
    ind = indicateurs(m)
    assert ind["precision_globale"] == pytest.approx(0.75)
    assert ind["kappa"] == pytest.approx(0.5)


def test_grappes_au_demi_hectare():
    g = grappes_par_maille([0, 50, 80], [0, 60, 0])
    assert g[0] == g[1] != g[2]
    probas = pd.DataFrame({"A": [0.6, 0.6, 0.1], "B": [0.4, 0.4, 0.9]})
    r = agreger_grappes(["A", "B", "B"], probas, g)
    assert set(r["predit"]) == {"A", "B"}


def test_lissage_conserve_les_probabilites():
    p = pd.DataFrame({"A": [1.0, 0.0, 0.0, 0.0], "B": [0.0, 1.0, 1.0, 1.0]})
    l = lisser(p, np.array([0, 0, 1, 1]), np.array([0, 1, 0, 1]), 3)
    assert np.allclose(l.sum(axis=1), 1)
    assert np.allclose(l["A"], 0.25)
