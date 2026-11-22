"""Validation à l'échelle de lecture réelle.

Le brief demande de valider sur des grappes de placettes couvrant un quart à un demi-
hectare, pas seulement à la placette, et de publier par SER une fiche de validation :
matrices de confusion, erreurs, domaine de validité.
"""

from __future__ import annotations

import numpy as np
import pandas as pd


def matrice_confusion(observe, predit, codes: list[str] | None = None) -> pd.DataFrame:
    observe = pd.Series(observe, dtype=object).reset_index(drop=True)
    predit = pd.Series(predit, dtype=object).reset_index(drop=True)
    if codes is None:
        codes = sorted(set(observe) | set(predit))
    m = pd.crosstab(
        pd.Categorical(observe, categories=codes),
        pd.Categorical(predit, categories=codes),
        dropna=False,
    )
    m.index.name, m.columns.name = "observé", "prédit"
    return m


def indicateurs(matrice: pd.DataFrame) -> dict:
    m = matrice.to_numpy(float)
    n = m.sum()
    if n == 0:
        return {"n": 0, "precision_globale": float("nan"), "kappa": float("nan")}
    po = np.trace(m) / n
    pe = (m.sum(0) * m.sum(1)).sum() / n**2
    kappa = (po - pe) / (1 - pe) if pe < 1 else float("nan")
    with np.errstate(invalid="ignore", divide="ignore"):
        rappel = np.diag(m) / m.sum(1)
        precision = np.diag(m) / m.sum(0)
    codes = list(matrice.index)
    return {
        "n": int(n),
        "precision_globale": float(po),
        "kappa": float(kappa),
        "rappel_par_type": dict(zip(codes, rappel.tolist())),
        "precision_par_type": dict(zip(codes, precision.tolist())),
    }


def grappes_par_maille(x: np.ndarray, y: np.ndarray, cote_m: float = 70.7) -> np.ndarray:
    """Identifiant de grappe : maille carrée de ``cote_m`` (70,7 m ≈ 0,5 ha)."""
    i = np.floor(np.asarray(x, float) / cote_m).astype(np.int64)
    j = np.floor(np.asarray(y, float) / cote_m).astype(np.int64)
    return np.array([f"{a}_{b}" for a, b in zip(i, j)])


def agreger_grappes(observe, probas: pd.DataFrame, grappe) -> pd.DataFrame:
    """Type observé majoritaire et type prédit par probabilités moyennes, par grappe."""
    df = probas.copy()
    df["_g"] = np.asarray(grappe)
    p_moy = df.groupby("_g").mean()
    pred = p_moy.idxmax(axis=1)
    obs = pd.Series(np.asarray(observe), index=df.index).groupby(df["_g"]).agg(
        lambda s: s.value_counts().index[0]
    )
    return pd.DataFrame({"observe": obs, "predit": pred.reindex(obs.index)})


def fiche_validation(observe, probas: pd.DataFrame, grappe, ser: str = "") -> dict:
    codes = list(probas.columns)
    pred = probas.idxmax(axis=1)
    m_plac = matrice_confusion(observe, pred, codes)
    g = agreger_grappes(observe, probas, grappe)
    m_grap = matrice_confusion(g["observe"], g["predit"], codes)
    return {
        "ser": ser,
        "placette": {"matrice": m_plac, **indicateurs(m_plac)},
        "grappe": {"matrice": m_grap, **indicateurs(m_grap)},
    }


def fiche_en_markdown(fiche: dict) -> str:
    lignes = [f"# Fiche de validation — SER {fiche['ser']}", ""]
    for niveau in ("placette", "grappe"):
        f = fiche[niveau]
        lignes += [
            f"## À la {niveau}",
            "",
            f"- Effectif : {f['n']}",
            f"- Précision globale : {f['precision_globale']:.1%}",
            f"- Kappa : {f['kappa']:.2f}",
            "",
            "Matrice de confusion (lignes : observé, colonnes : prédit)",
            "",
        ]
        m = f["matrice"]
        lignes.append("| observé \\ prédit | " + " | ".join(map(str, m.columns)) + " |")
        lignes.append("|---" * (len(m.columns) + 1) + "|")
        for code, row in m.iterrows():
            lignes.append(f"| {code} | " + " | ".join(str(int(v)) for v in row) + " |")
        lignes.append("")
    return "\n".join(lignes)
