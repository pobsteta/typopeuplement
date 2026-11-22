"""Variables dendrométriques tirées des arbres d'une placette.

Catégories de diamètre et triangle des structures : les seuils (précomptage, limites
petits / moyens / gros bois) sont propres à chaque SER et viennent de sa
configuration. Le brief rappelle que la limite des gros bois est à 42,5 cm en Savoie et
dans les Pyrénées, à 47,5 cm dans les Vosges (Souchon, 2020).
"""

from __future__ import annotations

import numpy as np
import pandas as pd


def surface_terriere_arbre(diametre_cm: np.ndarray) -> np.ndarray:
    """Surface terrière d'un arbre en m², à partir du diamètre à 1,30 m en cm."""
    d = np.asarray(diametre_cm, dtype=float) / 100.0
    return np.pi * d**2 / 4.0


def variables_placette(
    arbres: pd.DataFrame,
    surface_placette_ha: float,
    seuils: dict,
) -> pd.DataFrame:
    """Agrège les arbres par placette.

    ``arbres`` : colonnes ``placette``, ``diametre_cm``, ``resineux`` (booléen).
    ``seuils`` : ``precomptage_cm``, ``pb_bm_cm``, ``bm_gb_cm``.

    Renvoie, par placette : ``G`` (m²/ha), ``part_resineux``, ``part_pb``,
    ``part_bm``, ``part_gb`` (parts de la surface terrière, entre 0 et 1).
    """
    pre = seuils["precomptage_cm"]
    a = arbres[arbres["diametre_cm"] >= pre].copy()
    a["g"] = surface_terriere_arbre(a["diametre_cm"]) / surface_placette_ha
    d = a["diametre_cm"]
    a["cat"] = np.select(
        [d < seuils["pb_bm_cm"], d < seuils["bm_gb_cm"]], ["pb", "bm"], default="gb"
    )
    G = a.groupby("placette")["g"].sum()
    par_cat = a.pivot_table(index="placette", columns="cat", values="g", aggfunc="sum")
    par_cat = par_cat.reindex(columns=["pb", "bm", "gb"]).fillna(0.0)
    res = a[a["resineux"].astype(bool)].groupby("placette")["g"].sum()
    out = pd.DataFrame(index=arbres["placette"].unique())
    out.index.name = "placette"
    out["G"] = G.reindex(out.index).fillna(0.0)
    with np.errstate(invalid="ignore", divide="ignore"):
        for c in ["pb", "bm", "gb"]:
            out[f"part_{c}"] = par_cat[c].reindex(out.index).fillna(0.0) / out["G"]
        out["part_resineux"] = res.reindex(out.index).fillna(0.0) / out["G"]
    return out
