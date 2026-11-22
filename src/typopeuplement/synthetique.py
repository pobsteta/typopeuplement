"""Jeu de données synthétique, pour les tests et la démonstration.

Il n'imite aucune forêt réelle : il sert à vérifier que la chaîne tourne de bout en
bout et qu'elle retrouve une structure connue. Les vraies données (LiDAR HD,
Sentinel-2, BD Forêt v3, placettes) entrent par les mêmes colonnes.
"""

from __future__ import annotations

import numpy as np
import pandas as pd
from scipy.ndimage import gaussian_filter

TAILLE_PIXEL_M = 25.0


def _champ(rng, forme, echelle, bas, haut):
    z = gaussian_filter(rng.normal(size=forme), echelle)
    z = (z - z.min()) / (z.max() - z.min() + 1e-12)
    return bas + z * (haut - bas)


def _uniforme(z, bas, haut):
    """Étire un champ pour que ses valeurs couvrent [bas, haut] uniformément (par rangs)."""
    r = z.ravel().argsort().argsort().reshape(z.shape) / (z.size - 1)
    return bas + r * (haut - bas)


def generer(ni: int = 60, nj: int = 60, n_placettes: int = 400, graine: int = 0):
    rng = np.random.default_rng(graine)
    forme = (ni, nj)
    altitude = _champ(rng, forme, 8, 400, 1800)
    bilan_hydrique = _champ(rng, forme, 6, -250, 150)
    reserve_utile = _champ(rng, forme, 4, 40, 180)
    pente = _champ(rng, forme, 3, 0, 40)
    # Hauteur atteignable : meilleure en basse altitude, sur sol profond et bien alimenté.
    h_pot = (
        38.0
        - 0.008 * (altitude - 400)
        + 0.03 * bilan_hydrique
        + 0.04 * (reserve_utile - 100)
    )
    h_pot = np.clip(h_pot, 10, 45)
    age = _uniforme(_champ(rng, forme, 2, 0, 1), 10, 160)
    h_dom = h_pot * (1 - np.exp(-age / 45.0)) + rng.normal(0, 0.8, forme)
    part_resineux = np.clip(_champ(rng, forme, 5, -0.3, 1.3), 0, 1)
    irregularite = _champ(rng, forme, 3, 0, 0.6)

    # Parts de petits, moyens, gros bois : l'âge fait passer des PB aux GB, l'irrégularité mélange.
    t = np.clip(age / 160.0, 0, 1)
    pb = (1 - t) ** 2
    gb = t**2
    bm = 2 * t * (1 - t)
    parts = np.stack([pb, bm, gb])
    parts = (1 - irregularite) * parts + irregularite * (1 / 3)
    parts = parts / parts.sum(axis=0)
    G = np.clip(8 + 30 * t * (h_pot / 35) + rng.normal(0, 2, forme), 2, 60)
    couvert = np.clip(0.4 + 0.5 * t + rng.normal(0, 0.05, forme), 0, 1)

    ii, jj = np.meshgrid(np.arange(ni), np.arange(nj), indexing="ij")
    pixels = pd.DataFrame(
        {
            "i": ii.ravel(),
            "j": jj.ravel(),
            "altitude": altitude.ravel(),
            "pente": pente.ravel(),
            "bilan_hydrique": bilan_hydrique.ravel(),
            "reserve_utile": reserve_utile.ravel(),
            "h_dom": h_dom.ravel(),
            "couvert": couvert.ravel(),
            "famille": np.where(part_resineux.ravel() >= 0.5, "resineux", "feuillus"),
            # Prédicteurs simulés (métriques LiDAR, indices Sentinel-2).
            "lidar_h95": (h_dom + rng.normal(0, 1.0, forme)).ravel(),
            "lidar_h50": (h_dom * (0.75 - 0.25 * irregularite) + rng.normal(0, 1.0, forme)).ravel(),
            "lidar_cv_h": (0.15 + 0.5 * irregularite + rng.normal(0, 0.04, forme)).ravel(),
            "lidar_couvert": (couvert + rng.normal(0, 0.03, forme)).ravel(),
            "lidar_sous_etage": (pb * 0.6 + 0.4 * irregularite + rng.normal(0, 0.05, forme)).ravel(),
            "s2_ndvi_hiver": (0.2 + 0.6 * part_resineux + rng.normal(0, 0.05, forme)).ravel(),
            "s2_amplitude_ndvi": (0.6 - 0.45 * part_resineux + rng.normal(0, 0.05, forme)).ravel(),
        }
    )
    verite = pd.DataFrame(
        {
            "G": G.ravel(),
            "part_resineux": part_resineux.ravel(),
            "part_pb": parts[0].ravel(),
            "part_bm": parts[1].ravel(),
            "part_gb": parts[2].ravel(),
            "h_pot": h_pot.ravel(),
        }
    )
    idx = rng.choice(len(pixels), size=n_placettes, replace=False)
    placettes = pixels.iloc[idx].reset_index(drop=True).copy()
    mes = verite.iloc[idx].reset_index(drop=True)
    for c in ["G", "part_resineux", "part_pb", "part_bm", "part_gb"]:
        bruit = rng.normal(0, 0.03 if c.startswith("part") else 1.0, len(mes))
        placettes[c] = mes[c] + bruit
    placettes[["part_resineux", "part_pb", "part_bm", "part_gb"]] = placettes[
        ["part_resineux", "part_pb", "part_bm", "part_gb"]
    ].clip(0, 1)
    s = placettes[["part_pb", "part_bm", "part_gb"]].sum(axis=1)
    placettes[["part_pb", "part_bm", "part_gb"]] = placettes[["part_pb", "part_bm", "part_gb"]].div(s, axis=0)
    placettes["x"] = placettes["i"] * TAILLE_PIXEL_M
    placettes["y"] = placettes["j"] * TAILLE_PIXEL_M
    placettes.insert(0, "placette", [f"P{k:04d}" for k in range(len(placettes))])
    return placettes, pixels, verite
