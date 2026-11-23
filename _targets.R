# Pipeline du rapport de l'AOI (mission 015), sur le modele de sylvostation.
#
# Mode demonstration (defaut) : jeu synthetique de la chaine, SANS RESEAU ; le rapport dit
# que rien n'y vaut sur donnees reelles.
#   Rscript -e 'targets::tar_make(callr_function = NULL)'
# Mode reel : chemin des livrables d'une AOI DEJA CALCULEE (types.tif, confiance.tif, ...) ;
# aucun calcul LiDAR n'est lance ici.
#   TYPO_AOI=/chemin/livrables TYPO_TITRE="Leoncel" Rscript -e 'targets::tar_make(callr_function = NULL)'
# Variables : TYPO_AOI, TYPO_TITRE, TYPO_SORTIE (defaut sorties/rapport), TYPO_CONFIG (JSON),
# TYPO_SER (defaut H10). Le paquet doit etre installe ou charge par pkgload::load_all().

library(targets)

aoi <- Sys.getenv("TYPO_AOI", unset = "")
aoi <- if (nzchar(aoi)) aoi else NULL
config <- Sys.getenv("TYPO_CONFIG", unset = "")

args <- list(
  aoi = aoi,
  sortie = Sys.getenv("TYPO_SORTIE", unset = "sorties/rapport"),
  configuration = if (nzchar(config)) config else NULL,
  ser = Sys.getenv("TYPO_SER", unset = "H10")
)
titre <- Sys.getenv("TYPO_TITRE", unset = "")
if (nzchar(titre)) args$titre_aoi <- titre

do.call(typopeuplement::cibles_rapport, args)
