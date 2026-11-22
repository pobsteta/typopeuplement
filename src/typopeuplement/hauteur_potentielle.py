"""Hauteur potentielle : le milieu en donnée d'entrée.

Démarche du brief :

1. repérer les peuplements adultes fermés et relever leur hauteur dominante ;
2. modéliser cette hauteur en fonction des variables de milieu, par famille d'essences ;
3. appliquer le modèle à toute la SER ;
4. introduire dans la clé le rapport hauteur mesurée / hauteur potentielle.

Là où le modèle reste trop incertain (sol mal connu), la clé s'en tient à la hauteur
mesurée et le signale : le rapport vaut alors NaN et ``hp_incertaine`` est vrai.

Enveloppe haute. Un peuplement adulte n'a pas toujours atteint sa hauteur
potentielle : apprendre la hauteur moyenne des adultes la sous-estime (environ 10 % sur
le jeu synthétique). La prédiction est donc relevée par un facteur, le quantile
``quantile_enveloppe`` du rapport hauteur observée / hauteur prédite (hors échantillon)
chez les adultes. Ce quantile est une valeur provisoire, à mesurer en phase pilote.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import cross_val_predict


@dataclass
class ModeleHauteurPotentielle:
    variables_milieu: list[str]
    couvert_min: float = 0.7
    hauteur_min_m: float = 15.0
    incertitude_relative_max: float = 0.2
    quantile_enveloppe: float = 0.9
    graine: int = 0
    modeles: dict = field(default_factory=dict)
    rmse_cv: dict = field(default_factory=dict)
    facteur: dict = field(default_factory=dict)

    def peuplements_adultes(self, df: pd.DataFrame) -> pd.Series:
        """Masque des pixels retenus pour l'apprentissage (adultes, fermés)."""
        return (df["couvert"] >= self.couvert_min) & (df["h_dom"] >= self.hauteur_min_m)

    def ajuster(self, df: pd.DataFrame, famille: str = "famille") -> "ModeleHauteurPotentielle":
        adultes = df[self.peuplements_adultes(df)]
        groupes = adultes.groupby(famille) if famille in adultes else [("toutes", adultes)]
        for nom, g in groupes:
            if len(g) < 20:
                continue
            X = g[self.variables_milieu].to_numpy(float)
            y = g["h_dom"].to_numpy(float)
            rf = RandomForestRegressor(
                n_estimators=200, min_samples_leaf=5, random_state=self.graine, n_jobs=-1
            )
            pred_cv = cross_val_predict(rf, X, y, cv=5)
            self.facteur[nom] = max(1.0, float(np.quantile(y / pred_cv, self.quantile_enveloppe)))
            self.rmse_cv[nom] = float(np.sqrt(np.mean((pred_cv - y) ** 2)))
            self.modeles[nom] = rf.fit(X, y)
        if not self.modeles:
            raise ValueError("trop peu de peuplements adultes fermés pour ajuster le modèle")
        return self

    def predire(self, df: pd.DataFrame, famille: str = "famille") -> pd.DataFrame:
        """Hauteur potentielle, incertitude par pixel et rapport à la hauteur mesurée."""
        hp = np.full(len(df), np.nan)
        sd = np.full(len(df), np.nan)
        fam = df[famille].to_numpy() if famille in df else np.array(["toutes"] * len(df))
        defaut = next(iter(self.modeles))
        for nom in np.unique(fam):
            m = self.modeles.get(nom, self.modeles[defaut])
            rmse = self.rmse_cv.get(nom, self.rmse_cv[defaut])
            k = self.facteur.get(nom, self.facteur[defaut])
            idx = np.flatnonzero(fam == nom)
            X = df.iloc[idx][self.variables_milieu].to_numpy(float)
            par_arbre = k * np.stack([e.predict(X) for e in m.estimators_])
            hp[idx] = par_arbre.mean(axis=0)
            # Incertitude : dispersion de la forêt et erreur de validation croisée.
            sd[idx] = np.sqrt(par_arbre.std(axis=0) ** 2 + (k * rmse) ** 2)
        incertaine = (sd / hp) > self.incertitude_relative_max
        rapport = np.where(incertaine, np.nan, df["h_dom"].to_numpy(float) / hp)
        return pd.DataFrame(
            {"h_pot": hp, "h_pot_sd": sd, "rapport_h": rapport, "hp_incertaine": incertaine},
            index=df.index,
        )
