import numpy as np
import pandas as pd
import pytest

from typopeuplement.cle import Cle, appartenances, classer

CLE = {
    "marge_entre_deux": 0.2,
    "souplesse": {"x": 0.05},
    "types": [
        {"code": "A", "conditions": [{"variable": "x", "max": 0.5}]},
        {"code": "B", "conditions": [{"variable": "x", "min": 0.5}]},
    ],
}


def test_souplesse_nulle_redonne_la_cle_dure():
    cle = Cle.depuis_dict({**CLE, "souplesse": {}})
    p = appartenances(cle, pd.DataFrame({"x": [0.1, 0.49, 0.5, 0.9]}))
    assert list(p.idxmax(axis=1)) == ["A", "A", "B", "B"]
    assert set(np.unique(p.to_numpy())) <= {0.0, 1.0}


def test_probabilites_sommees_a_un_et_pixel_entre_deux():
    cle = Cle.depuis_dict(CLE)
    r = classer(cle, pd.DataFrame({"x": [0.05, 0.5, 0.95]}))
    assert np.allclose(r[["p_A", "p_B"]].sum(axis=1), 1)
    assert list(r["entre_deux"]) == [False, True, False]
    assert r.loc[1, "proba"] == pytest.approx(0.5)


def test_variable_inconnue_neutralise_la_condition():
    cle = Cle.depuis_dict(
        {
            "types": [
                {"code": "J", "conditions": [{"variable": "pb", "min": 0.5}, {"variable": "rh", "max": 0.6}]},
                {"code": "C", "conditions": [{"variable": "pb", "min": 0.5}, {"variable": "rh", "min": 0.6}]},
                {"code": "X", "conditions": [{"variable": "pb", "max": 0.5}]},
            ]
        }
    )
    r = classer(cle, pd.DataFrame({"pb": [0.8, 0.8, 0.2], "rh": [0.3, np.nan, np.nan]}))
    assert r.loc[0, "type"] == "J"
    # Sans hauteur potentielle, J et C restent à égalité : le pixel est signalé.
    assert r.loc[1, "p_J"] == pytest.approx(0.5) and r.loc[1, "entre_deux"]
    assert r.loc[2, "type"] == "X"


def test_variable_absente_leve_une_erreur():
    with pytest.raises(KeyError):
        appartenances(Cle.depuis_dict(CLE), pd.DataFrame({"y": [1.0]}))
