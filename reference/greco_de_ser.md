# Grande région écologique (GRECO) d'une SER

La GRECO est la première lettre du code SER (référentiel GeoData INRAE :
86 SER principales, GRECO A à K, et 5 SER d'alluvions récentes, GRECO
L). Un code absent du référentiel (`inst/extdata/ser/ser_codes.csv`) est
refusé : on n'invente pas de GRECO.

## Usage

``` r
greco_de_ser(code_ser)
```

## Arguments

- code_ser:

  Codes SER (par exemple `"H10"`).

## Value

Vecteur de codes GRECO, nommé par code SER.

## Examples

``` r
greco_de_ser(c("H10", "L5"))
#> H10  L5 
#> "H" "L" 
```
