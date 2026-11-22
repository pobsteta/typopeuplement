"""La chaîne de traitement, rejouable à chaque nouvelle donnée.

    placettes + pixels ──► variables dendrométriques (modèles)
    pixels (milieu)    ──► hauteur potentielle ──► rapport hauteur mesurée / potentielle
                                     │
                                     ▼
                       clé floue par SER ──► lissage ──► type, probabilité, drapeaux

Entrées (tableaux, une ligne par placette ou par pixel de la grille) :

- les ``predicteurs`` (métriques LiDAR HD, indices Sentinel, BD Forêt v3...), calculés en
  amont et rangés dans la configuration ;
- les ``variables_milieu`` (topographie, climat, sol) ;
- ``h_dom`` (hauteur dominante mesurée par LiDAR), ``couvert``, ``famille`` ;
- pour les pixels : ``i``, ``j`` (indices de grille) ;
- pour les placettes : les variables mesurées (``G``, parts) et ``x``, ``y`` (m).
"""

from __future__ import annotations

from dataclasses import replace

import pandas as pd

from .cle import Cle, appartenances, classer, decider
from .hauteur_potentielle import ModeleHauteurPotentielle
from .lissage import lisser
from .modeles import ModelesDendro
from .validation import fiche_validation, grappes_par_maille


def _modele_hp(conf: dict) -> ModeleHauteurPotentielle:
    hp = conf.get("hauteur_potentielle", {})
    return ModeleHauteurPotentielle(
        variables_milieu=conf["variables_milieu"],
        couvert_min=hp.get("couvert_min", 0.7),
        hauteur_min_m=hp.get("hauteur_min_m", 15.0),
        incertitude_relative_max=hp.get("incertitude_relative_max", 0.2),
        quantile_enveloppe=hp.get("quantile_enveloppe", 0.9),
        graine=conf.get("graine", 0),
    )


def types_observes(cle: Cle, mesures: pd.DataFrame) -> pd.Series:
    """Type de chaque placette par la clé à seuils durs appliquée aux mesures.

    Le rapport de 2020 constate que le type relevé « à dire d'expert » n'est pas une
    vérité terrain fiable : la référence est la clé appliquée aux mesures.
    """
    dure = replace(cle, souplesse={})
    return decider(appartenances(dure, mesures))["type"]


def executer(placettes: pd.DataFrame, pixels: pd.DataFrame, conf: dict) -> dict:
    cle = Cle.depuis_dict(conf["cle"])
    graine = conf.get("graine", 0)

    # 1. Variables dendrométriques.
    dendro = ModelesDendro(conf["predicteurs"], conf["variables_cibles"], graine).ajuster(placettes)
    var_pix = dendro.predire(pixels)

    # 2. Hauteur potentielle, apprise sur les peuplements adultes fermés des pixels.
    mhp = _modele_hp(conf).ajuster(pixels)
    hp_pix = mhp.predire(pixels)
    hp_plac = mhp.predire(placettes)

    # 3. Clé floue, lissage, décision.
    entree = pd.concat([var_pix, hp_pix[["rapport_h"]]], axis=1)
    probas = appartenances(cle, entree)
    hors_cle = probas.attrs["hors_cle"]
    probas = lisser(probas, pixels["i"], pixels["j"], conf.get("lissage_fenetre", 3))
    carte = decider(probas, cle.marge_entre_deux)
    carte["hors_cle"] = hors_cle
    carte = pd.concat([pixels[["i", "j"]], carte, var_pix, hp_pix, probas.add_prefix("p_")], axis=1)

    # 4. Validation indépendante sur les placettes (prédictions hors échantillon).
    mesures = pd.concat([placettes[conf["variables_cibles"]], hp_plac[["rapport_h"]]], axis=1)
    obs = types_observes(cle, mesures)
    var_cv = dendro.predire_validation_croisee(placettes)
    p_cv = appartenances(cle, pd.concat([var_cv, hp_plac[["rapport_h"]]], axis=1))
    grappe = grappes_par_maille(placettes["x"], placettes["y"], conf.get("grappe_cote_m", 70.7))
    fiche = fiche_validation(obs, p_cv, grappe, ser=conf.get("ser", ""))

    return {
        "carte": carte,
        "fiche_validation": fiche,
        "erreurs_variables": dendro.erreurs(placettes),
        "rmse_hauteur_potentielle": mhp.rmse_cv,
        "types_observes": obs,
    }


def classer_placettes(conf: dict, mesures: pd.DataFrame) -> pd.DataFrame:
    """Applique la clé floue d'une SER à des mesures (outil de contrôle)."""
    return classer(Cle.depuis_dict(conf["cle"]), mesures)


__all__ = ["executer", "types_observes", "classer_placettes"]
