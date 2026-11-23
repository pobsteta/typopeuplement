# Variables de relief calculées par [`calculer_relief()`](https://pobsteta.github.io/typopeuplement/reference/calculer_relief.md)

|  |  |  |
|----|----|----|
| variable | unité | définition |
| `altitude` | m | moyenne du MNT sur le pixel |
| `pente` | degrés | pente du MNT ramené sur la grille (voisinage 3 × 3, méthode de Horn, [`terra::terrain()`](https://rspatial.github.io/terra/reference/terrain.html)) |
| `expo_sin` | sans unité, -1 à 1 | sinus de l'exposition (1 : versant est) ; 0 en terrain plat |
| `expo_cos` | sans unité, -1 à 1 | cosinus de l'exposition (1 : versant nord) ; 0 en terrain plat |
| `position_topo` | m | altitude moins l'altitude moyenne dans un disque de rayon `rayon_tpi_m` (négatif : creux, bas de versant ; positif : croupe, crête) |

## Usage

``` r
variables_relief()
```

## Value

Vecteur de caractères des noms de variables.

## See also

[`calculer_relief()`](https://pobsteta.github.io/typopeuplement/reference/calculer_relief.md),
[`milieu_pixels()`](https://pobsteta.github.io/typopeuplement/reference/milieu_pixels.md)
