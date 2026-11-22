"""Déclinaison par sylvoécorégion : un socle national, une calibration locale.

- Une SER reçoit son propre modèle quand elle a assez de placettes pour chaque type ;
  sinon elle hérite du modèle de sa grande région écologique (GRECO). Le seuil reste à
  fixer en phase pilote : il est un paramètre, provisoire.
- Les limites de SER ne doivent pas créer de ruptures : dans une bande de transition,
  les probabilités des deux modèles sont pondérées selon la distance à la limite.
"""

from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path

import numpy as np
import pandas as pd


def _fusion(base: dict, dessus: dict) -> dict:
    out = deepcopy(base)
    for k, v in dessus.items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = _fusion(out[k], v)
        else:
            out[k] = deepcopy(v)
    return out


def charger_configuration(chemin: str | Path, ser: str) -> dict:
    """Configuration effective d'une SER : national, puis grande région, puis SER."""
    conf = json.loads(Path(chemin).read_text(encoding="utf-8"))
    if ser not in conf.get("ser", {}):
        raise KeyError(f"SER inconnue dans la configuration : {ser}")
    s = conf["ser"][ser]
    greco = conf.get("grandes_regions", {}).get(s.get("grande_region"), {})
    eff = _fusion(_fusion(conf.get("national", {}), greco), s)
    eff["ser"] = ser
    return eff


def niveau_modele(effectifs_par_type: dict[str, int], codes: list[str], minimum: int) -> str:
    """« ser » si chaque type a au moins ``minimum`` placettes, sinon « grande_region »."""
    if all(effectifs_par_type.get(c, 0) >= minimum for c in codes):
        return "ser"
    return "grande_region"


def poids_transition(distance_m: np.ndarray, demi_largeur_m: float) -> np.ndarray:
    """Poids du modèle de la SER du pixel, selon la distance signée à la limite.

    ``distance_m`` > 0 à l'intérieur de la SER du pixel. Au-delà de la demi-largeur de
    bande, le poids vaut 1 ; sur la limite, 0,5 ; la variation est linéaire.
    """
    d = np.asarray(distance_m, float)
    if demi_largeur_m <= 0:
        return np.ones_like(d)
    return np.clip(0.5 + d / (2.0 * demi_largeur_m), 0.5, 1.0)


def raccorder(p_ser: pd.DataFrame, p_voisine: pd.DataFrame, poids: np.ndarray) -> pd.DataFrame:
    """Mélange des probabilités de deux modèles ; les types absents d'un côté valent 0."""
    codes = list(dict.fromkeys(list(p_ser.columns) + list(p_voisine.columns)))
    a = p_ser.reindex(columns=codes, fill_value=0.0).to_numpy()
    b = p_voisine.reindex(columns=codes, fill_value=0.0).to_numpy()
    w = np.asarray(poids, float)[:, None]
    m = w * a + (1 - w) * b
    m = m / m.sum(axis=1, keepdims=True)
    return pd.DataFrame(m, columns=codes, index=p_ser.index)
