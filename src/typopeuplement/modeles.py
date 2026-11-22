"""Modèles : variables continues d'abord, types ensuite.

La chaîne prédit d'abord les variables dendrométriques continues (surface terrière,
parts de petits, moyens et gros bois, part de résineux), souvent plus utiles au
gestionnaire que le type lui-même ; la clé en déduit ensuite les types.

Le brief demande aussi de comparer plusieurs classifieurs (forêts aléatoires, SVM,
analyse discriminante), ce que le rapport de 2020 n'a pas eu le temps de faire :
``comparer_classifieurs`` le fait en validation croisée stratifiée.
"""

from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.metrics import accuracy_score, cohen_kappa_score
from sklearn.model_selection import KFold, StratifiedKFold, cross_val_predict
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC

PARTS_CATEGORIES = ["part_pb", "part_bm", "part_gb"]


def _foret(graine: int) -> RandomForestRegressor:
    return RandomForestRegressor(n_estimators=150, min_samples_leaf=3, random_state=graine, n_jobs=-1)


def _normaliser_parts(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for c in df.columns:
        if c.startswith("part_"):
            df[c] = df[c].clip(0.0, 1.0)
    presentes = [c for c in PARTS_CATEGORIES if c in df]
    if len(presentes) == len(PARTS_CATEGORIES):
        s = df[presentes].sum(axis=1).replace(0, np.nan)
        df[presentes] = df[presentes].div(s, axis=0).fillna(1.0 / len(presentes))
    return df


class ModelesDendro:
    """Une forêt aléatoire par variable cible."""

    def __init__(self, predicteurs: list[str], cibles: list[str], graine: int = 0):
        self.predicteurs = predicteurs
        self.cibles = cibles
        self.graine = graine
        self.modeles: dict[str, RandomForestRegressor] = {}

    def ajuster(self, placettes: pd.DataFrame) -> "ModelesDendro":
        X = placettes[self.predicteurs].to_numpy(float)
        for c in self.cibles:
            self.modeles[c] = _foret(self.graine).fit(X, placettes[c].to_numpy(float))
        return self

    def predire(self, df: pd.DataFrame) -> pd.DataFrame:
        X = df[self.predicteurs].to_numpy(float)
        out = pd.DataFrame({c: m.predict(X) for c, m in self.modeles.items()}, index=df.index)
        return _normaliser_parts(out)

    def predire_validation_croisee(self, placettes: pd.DataFrame, plis: int = 5) -> pd.DataFrame:
        """Prédictions hors échantillon pour chaque placette (validation)."""
        X = placettes[self.predicteurs].to_numpy(float)
        cv = KFold(plis, shuffle=True, random_state=self.graine)
        out = pd.DataFrame(index=placettes.index)
        for c in self.cibles:
            out[c] = cross_val_predict(_foret(self.graine), X, placettes[c].to_numpy(float), cv=cv)
        return _normaliser_parts(out)

    def erreurs(self, placettes: pd.DataFrame, plis: int = 5) -> pd.DataFrame:
        pred = self.predire_validation_croisee(placettes, plis)
        lignes = []
        for c in self.cibles:
            e = pred[c] - placettes[c]
            lignes.append({"variable": c, "biais": e.mean(), "rmse": float(np.sqrt((e**2).mean()))})
        return pd.DataFrame(lignes).set_index("variable")


def classifieurs(graine: int = 0) -> dict:
    return {
        "forets_aleatoires": RandomForestClassifier(n_estimators=300, random_state=graine, n_jobs=-1),
        "svm": make_pipeline(StandardScaler(), SVC(C=1.0, gamma="scale", random_state=graine)),
        "analyse_discriminante": make_pipeline(StandardScaler(), LinearDiscriminantAnalysis()),
    }


def comparer_classifieurs(X: pd.DataFrame, y, plis: int = 5, graine: int = 0) -> pd.DataFrame:
    y = np.asarray(y)
    classes, effectifs = np.unique(y, return_counts=True)
    # Un type trop rare pour la validation croisée est écarté, et on le dit.
    rares = classes[effectifs < 2]
    if len(rares):
        garde = ~np.isin(y, rares)
        X, y = X[garde], y[garde]
        effectifs = effectifs[effectifs >= 2]
    plis = max(2, min(plis, int(effectifs.min())))
    cv = StratifiedKFold(plis, shuffle=True, random_state=graine)
    lignes = []
    for nom, clf in classifieurs(graine).items():
        pred = cross_val_predict(clf, X.to_numpy(float), y, cv=cv)
        lignes.append(
            {"classifieur": nom, "precision_globale": accuracy_score(y, pred), "kappa": cohen_kappa_score(y, pred)}
        )
    out = pd.DataFrame(lignes).set_index("classifieur").sort_values("kappa", ascending=False)
    out.attrs["types_ecartes"] = rares.tolist()
    return out
