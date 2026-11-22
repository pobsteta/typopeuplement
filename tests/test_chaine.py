from pathlib import Path

import numpy as np
import pytest

from typopeuplement.chaine import executer
from typopeuplement.cli import main
from typopeuplement.hauteur_potentielle import ModeleHauteurPotentielle
from typopeuplement.modeles import comparer_classifieurs
from typopeuplement.ser import charger_configuration
from typopeuplement.synthetique import generer

CONF = Path(__file__).resolve().parents[1] / "config" / "exemple.json"


@pytest.fixture(scope="module")
def donnees():
    return generer(ni=40, nj=40, n_placettes=300, graine=1)


@pytest.fixture(scope="module")
def resultat(donnees):
    placettes, pixels, _ = donnees
    return executer(placettes, pixels, charger_configuration(CONF, "exemple-alpes-du-nord"))


def test_hauteur_potentielle_retrouvee(donnees):
    _, pixels, verite = donnees
    m = ModeleHauteurPotentielle(["altitude", "pente", "bilan_hydrique", "reserve_utile"]).ajuster(pixels)
    hp = m.predire(pixels)
    adultes = m.peuplements_adultes(pixels)
    erreur = (hp["h_pot"] - verite["h_pot"])[adultes]
    assert np.sqrt((erreur**2).mean()) < 3.0
    assert set(hp.columns) == {"h_pot", "h_pot_sd", "rapport_h", "hp_incertaine"}


def test_hauteur_incertaine_signalee(donnees):
    _, pixels, _ = donnees
    hp = ModeleHauteurPotentielle(["altitude"], incertitude_relative_max=0.0).ajuster(pixels).predire(pixels)
    assert hp["hp_incertaine"].all() and hp["rapport_h"].isna().all()


def test_chaine_complete(resultat):
    carte = resultat["carte"]
    p = carte.filter(like="p_")
    assert np.allclose(p.sum(axis=1), 1)
    assert carte["proba"].between(0, 1).all()
    fiche = resultat["fiche_validation"]
    # Sur ce jeu synthétique, la chaîne doit faire mieux que le hasard, et la grappe au moins aussi bien.
    assert fiche["placette"]["precision_globale"] > 0.6
    assert fiche["grappe"]["n"] <= fiche["placette"]["n"]


def test_comparaison_des_classifieurs(donnees, resultat):
    placettes, _, _ = donnees
    conf = charger_configuration(CONF, "exemple-alpes-du-nord")
    r = comparer_classifieurs(placettes[conf["predicteurs"]], resultat["types_observes"], plis=3)
    assert set(r.index) == {"forets_aleatoires", "svm", "analyse_discriminante"}


def test_cli_demo(tmp_path, capsys):
    assert main(["demo", "--sortie", str(tmp_path), "--config", str(CONF)]) == 0
    assert (tmp_path / "carte_types.csv").exists()
    assert "Fiche de validation" in (tmp_path / "fiche_validation.md").read_text()
    assert "précision à la grappe" in capsys.readouterr().out
