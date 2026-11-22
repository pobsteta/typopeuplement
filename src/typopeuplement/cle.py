"""Clé de détermination à appartenance floue.

Le brief demande de « remplacer les seuils durs du triangle des structures par des
probabilités d'appartenance, et afficher les pixels entre deux types ».

Une clé est une liste de types ; chaque type est défini par des intervalles sur des
variables continues (part de résineux, parts de petits, moyens et gros bois, surface
terrière, rapport hauteur mesurée / hauteur potentielle...). Une condition dure
``min <= v < max`` devient le produit de deux sigmoïdes dont la pente est réglée par
une « souplesse » propre à la variable, de l'ordre de son erreur de prédiction.
Quand la souplesse tend vers zéro, on retrouve exactement la clé à seuils durs.

Une variable manquante (par exemple la hauteur potentielle jugée trop incertaine)
neutralise la condition qui la porte : la clé s'en tient alors aux autres variables,
et le pixel est signalé.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class Condition:
    variable: str
    min: float | None = None
    max: float | None = None


@dataclass(frozen=True)
class TypePeuplement:
    code: str
    libelle: str
    conditions: tuple[Condition, ...] = field(default_factory=tuple)


@dataclass
class Cle:
    types: list[TypePeuplement]
    souplesse: dict[str, float] = field(default_factory=dict)
    marge_entre_deux: float = 0.15

    @property
    def codes(self) -> list[str]:
        return [t.code for t in self.types]

    @classmethod
    def depuis_dict(cls, d: dict) -> "Cle":
        types = [
            TypePeuplement(
                code=t["code"],
                libelle=t.get("libelle", t["code"]),
                conditions=tuple(
                    Condition(c["variable"], c.get("min"), c.get("max"))
                    for c in t.get("conditions", [])
                ),
            )
            for t in d["types"]
        ]
        return cls(
            types=types,
            souplesse=dict(d.get("souplesse", {})),
            marge_entre_deux=float(d.get("marge_entre_deux", 0.15)),
        )


def _sigmoide(x: np.ndarray) -> np.ndarray:
    return 0.5 * (1.0 + np.tanh(0.5 * x))


def _appartenance_condition(v: np.ndarray, c: Condition, s: float) -> np.ndarray:
    m = np.ones_like(v, dtype=float)
    if s <= 0:
        if c.min is not None:
            m = m * (v >= c.min)
        if c.max is not None:
            m = m * (v < c.max)
    else:
        if c.min is not None:
            m = m * _sigmoide((v - c.min) / s)
        if c.max is not None:
            m = m * _sigmoide((c.max - v) / s)
    # Variable inconnue : condition neutralisée.
    return np.where(np.isnan(v), 1.0, m)


def appartenances(cle: Cle, variables: pd.DataFrame) -> pd.DataFrame:
    """Probabilité d'appartenance de chaque ligne à chaque type (somme à 1)."""
    n = len(variables)
    scores = np.ones((n, len(cle.types)))
    for j, t in enumerate(cle.types):
        for c in t.conditions:
            if c.variable not in variables:
                raise KeyError(f"variable absente pour la clé : {c.variable}")
            v = variables[c.variable].to_numpy(dtype=float)
            s = float(cle.souplesse.get(c.variable, 0.0))
            scores[:, j] *= _appartenance_condition(v, c, s)
    total = scores.sum(axis=1, keepdims=True)
    hors_cle = total[:, 0] <= 1e-12
    with np.errstate(invalid="ignore", divide="ignore"):
        probas = np.where(total > 1e-12, scores / total, 1.0 / len(cle.types))
    df = pd.DataFrame(probas, columns=cle.codes, index=variables.index)
    df.attrs["hors_cle"] = hors_cle
    return df


def decider(probas: pd.DataFrame, marge_entre_deux: float = 0.15) -> pd.DataFrame:
    """Type retenu, sa probabilité, le second type et le drapeau « entre deux types »."""
    p = probas.to_numpy()
    ordre = np.argsort(-p, axis=1)
    codes = np.asarray(probas.columns)
    p1 = p[np.arange(len(p)), ordre[:, 0]]
    if p.shape[1] > 1:
        p2 = p[np.arange(len(p)), ordre[:, 1]]
        second = codes[ordre[:, 1]]
    else:
        p2 = np.zeros(len(p))
        second = np.array([None] * len(p))
    return pd.DataFrame(
        {
            "type": codes[ordre[:, 0]],
            "proba": p1,
            "type_second": second,
            "proba_second": p2,
            "entre_deux": (p1 - p2) < marge_entre_deux,
        },
        index=probas.index,
    )


def classer(cle: Cle, variables: pd.DataFrame) -> pd.DataFrame:
    probas = appartenances(cle, variables)
    dec = decider(probas, cle.marge_entre_deux)
    dec["hors_cle"] = probas.attrs["hors_cle"]
    return pd.concat([dec, probas.add_prefix("p_")], axis=1)
