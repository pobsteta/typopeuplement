"""Lissage à l'échelle de lecture.

Résolution de travail de l'ordre de 25 m, lecture au quart ou au demi-hectare : on
moyenne les probabilités sur une fenêtre carrée de pixels (3 × 3 pixels de 25 m font
0,56 ha). Les pixels absents (hors forêt) ne comptent pas dans la moyenne.
"""

from __future__ import annotations

import numpy as np
import pandas as pd
from scipy.ndimage import uniform_filter


def lisser(probas: pd.DataFrame, i: np.ndarray, j: np.ndarray, fenetre: int = 3) -> pd.DataFrame:
    if fenetre <= 1:
        return probas.copy()
    i = np.asarray(i, int)
    j = np.asarray(j, int)
    i0, j0 = i - i.min(), j - j.min()
    forme = (i0.max() + 1, j0.max() + 1)
    presence = np.zeros(forme)
    presence[i0, j0] = 1.0
    n = uniform_filter(presence, size=fenetre, mode="constant")
    out = np.empty(probas.shape)
    for k, c in enumerate(probas.columns):
        grille = np.zeros(forme)
        grille[i0, j0] = probas[c].to_numpy(float)
        s = uniform_filter(grille, size=fenetre, mode="constant")
        out[:, k] = s[i0, j0] / n[i0, j0]
    out = out / out.sum(axis=1, keepdims=True)
    return pd.DataFrame(out, columns=probas.columns, index=probas.index)
