# Mission 011 — incertitude locale de la hauteur potentielle

## Mission

**En une phrase (quoi, et pourquoi) :** rendre l'incertitude de la hauteur potentielle
variable selon le lieu, par exemple une RMSE de validation croisée par classe d'altitude ou
par classe de h_pot prédite, ou une forêt de quantiles, pour que le drapeau « hauteur
potentielle incertaine » dise de nouveau « ici le modèle se trompe plus », et non « station
peu fertile ».

## Les trois questions

oui · oui (`R/hauteur_potentielle.R`, relectures de 009) · oui.

**Temps de la main :** donner, avec un plan court d'abord (choix de la méthode), validé par
l'orchestrateur sous délégation, ou par Pascal.

## L'Homme

`dev` · opus.

## Harnais

- **Peut :** `R/hauteur_potentielle.R`, `R/modeles.R`, `man/`, `NAMESPACE`, `tests/testthat/test-dev-*.R`.
- **Ne doit pas :** changer l'enveloppe hors sac de 009.

## Dépend de

012 : les deux missions régénèrent `man/` et `NAMESPACE`. Ordre : 012 → 011.

## Tests

- L'incertitude varie dans l'espace.
- La part « incertaine » et la carte sont comparées à l'option actuelle sur Léoncel.

## Qui tranche

`relecteur`, puis Pascal.
