MBI ROH
=======

Celem projektu jest stworzenie aplikacji w języku `R`, wykorzystującej framework `shiny`. Zadaniem aplikacji będzie udostępnianie interfejsu do wizualizacji i przeglądania wyników kilku algorytmów do wykrywania braku heterozygotyczności.

Skrócony opis algorytmu:
------------------------

Wejściem programu są pliki `.vcf.gz` oraz `.vcf.gz.tbi`.
Zgodnie z zadanymi przez użytkownika parametrami, plik vcf jest przycinany: do odpowiedniego chromosomu, do odpowiedniego zakresu indeksów, do odpowiedniego osobnika.
Aplikacja wykorzystuje dwa popularne narzędzia: `BCFTools` oraz `Plink` do wykrywania regionów braku heterozygotyczności.
Z wybranego fragmentu, oprócz oceny homozygotyczności tworzona jest lista wartości `BAF`.
Wyniki są prezentowane użytkownikowi poprzez interfejs graficzny.

Pełny opis algorytmu:
---------------------

- Przygotowanie zadania przez użytkownika
  - Program rozpoczyna się od przygotowania przez użytkownika pliku `.vcf.gz` + `.vcf.gz.tbi` mogącego potencjalnie zawierać dane dla wielu chromosomów, wielu regionów i wielu próbek
  - Użytkownik musi zdecydować z którego chromosomu, dla którego regionu i której próbki chce wygenerować zadanie. W tym celu użytkownik tworzy strukturę `task`, opisaną w `roh.R`
- Przygotowanie danych dla algorytmów
  - W kolejnym kroku pakiet `subsetter.R` w metodzie `subsetter.prepare` przygotowuje okrojony (dla danych podanych przez `task`) zestaw danych. Z głównego pliku `.vcf.gz` tworzony jest ograniczony, tymczasowy plik `.vcf` przy wykorzystaniu metody `bcftools.view.buildparams` + `bcftools.view.run`.
  - Zostaje on skompresowany przez `samtools.bgzip` do `.vcf.gz`
  - W kolejnym kroku `samtools.tabix` dodaje indeksy do przygotowanego pliku.
  - W tym miejscu istnieje gotowy, ograniczony plik `.vcf.gz` + `.vcf.gz.tbi` który może zostać podany na wejście algorytmów.
- W następnym kroku aplikacja uruchamia `BCFTools ROH`
  - Parametry algorytmu są dostarczane przez użytkownika do metody `bcftools.roh.buildparams`
  - Gotowy wiersz polecenia przekazywany jest do metody `bcftools.roh.run` która uruchamia program.
  - Pliki z wynikami są parsowane przez funkcję `bcftools.roh.table.to.regions` i zamieniane na format `roh` opisany w `roh.R`
  - Tymczasowe pliki są czyszczone, a wynik zwracany
- Następny krok uruchamia zadanie w pakiecie `Plink ROH`
  - W pierwszym kroku parametry dostarczone przez użytkownika są zamieniane na wiersz polecenia w metodzie `plink.roh.buildparams`
  - Zbudowane polecenie jest uruchamiane poprzez `plink.roh.run`
  - Ta metoda odczytuje wyniki działania programu i z pomocą `plink.roh.table.to.regions` konwertuje je na format `roh` opisany w `roh.R`
  - Tymczasowe pliki są czyszczone, a wynik zwracany
- Ostatni krok analityczny dotyczy wygenerowania danych BAF
  - W tym celu wejściowy plik podawany jest do metod `vcfr.R`
  - Metoda `vcfr.baf.from.file` odczytuje plik i podaje zdekodowaną strukturę do `vcfr.baf.from.struct`
  - Ta metoda sprawdza poprawność danych, przy użyciu metody `vcfr.baf.from.genotypes` wyciąga wartości BAF.
  - Wynikowa struktura jest zwracana
- Ostatni krok programu dotyczy prezentacji wyników użytkownikowi
  - Gotowe struktury są wysyłane na interfejs


Instalacja:
----------
Do działania, konieczna jest instalacja (wystarczy zbudowanie):

- `htslib`:
  - `https://github.com/samtools/htslib.git`
  - `make` zgodnie z instrukcją
- `samtools`:
  - `https://github.com/samtools/tabix`
  - `make` zgodnie z instrukcją
  - ustawienie ścieżki do `bgzip` i `tabix` w `samtools.R`
- `BCFTools`:
  - `git clone https://github.com/samtools/BCFtools`
  - `make` zgodnie z instrukcją
  - ustawienie ścieżki do `BCFTools/bcftools` w `bcftools.R`
- `Plink`:
  - Pobranie lub zbudowanie ze źródeł ze strony https://www.cog-genomics.org/plink2
  - Ustawienie ścieżki w `plink.R`

Wymagane biblioteki `R`:

 - RUnit ( `install.packages('RUnit')`)
 - vcfR ( `install.packages('vcfR')`)


Opis plików projektu:
---------------------
- `roh.R` - zawiera definicje podstawowych struktur danych - `task` oraz `roh`. Oprócz definicji zawiera pomocnicze metody wspólne dla wszystkich algorytmów
- `runit.roh.R` - zawiera testy jednostkowe funkcji dostępnych w pakiecie `roh.R`

- `samtools.R` - zawiera wrappery dla programów z pakietu `samtools`: `bgzip` oraz `tabix`
- `runit.samtools.R` - zawiera testy jednostkowe dla funkcji z pakietu `samtools.R`

- `bcftools.R` - zawiera wrappery dla funkcji z pakietu `BCFTools`: `roh` (do wykrywania homozygotyczności) oraz `view` do przycinania plików
- `runit.bcftools.R` - zawiera testy jednostkowe dla funkcji z pakietu `bcftools.R`

- `plink.R` - zawiera wrapper dla funkcji `homozyg` z pakietu `Plink`. Pozwala na uruchamianie funkcji z zadanymi parametrami
- `runit.plink.R` - zawiera testy jednostkowe dla funkcji z pakietu `plink.R`

- `subsetter.R` - zawiera metody wycinające (ograniczające) zbiór danych na których operuje program
- `runit.subsetter.R` - zawiera testy jednostkowe dla `subsetter.R`

- `vcfr.R` - zawiera wrappery metod z pakietu `vcfR`
- `runir.vcfr.R` - zawiera testy jednostkowe dla `runir.vcfr.R`

- `roh-example.R` - zawiera konsolowy przykład wykorzystania wszystkich algorytmów. Rysuje wynik w postaci wykresu


Struktury danych:
-----------------
Opisane szczegółowo w pliku `roh.R`

Przykład uruchomienia algorytmów:
---------------------------------
`roh-example.R`

Testy:
------
Testowalne metody zostały pokryte testami jednostkowymi. Aby uruchomić kompletny zestaw testów należy rozpocząć działanie programu `tests-runit.R`