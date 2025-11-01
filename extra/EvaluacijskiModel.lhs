> {-# OPTIONS_GHC -Wno-x-partial #-}
>
> module EvaluacijskiModel where


== Uvod ========================================================================

Na drugom predavanju o rekurzijama spomenuli smo lijenost i thunkove koji nam
stvaraju potencijalne probleme pri korištenju rekurzije te da ih možemo
riješiti uz pomoć korištenja ugrađene funkcije 'seq'.

Za trenutnu razinu Haskella nije potrebno znati detalje evaluacijskog modela
jezika, već je bitno imati svijest o tome da se u pozadini potencijalno grade
stabla nekih ne izvršenih izraza koja možemo reducirati uz pomoć `seq` funkcije.

U ovoj dodatnoj lekciji dati ćemo malo jaču definiciju lijenosti i bolje
ilustrirati ulogu thunkova.


== Evaluacija / Redukcija ======================================================

> zbroj :: Num n => n -> n -> n
> zbroj a b = a + b

Ako u GHCi-ju pokušamo izvršiti 'zbroj 1 2' kao rezultat dobit ćemo broj '3'.
Pitanje je na koji način Haskell dolazi do tog rezultata? Stvar se svodi na
redukciju izraza koja je u principu samo supstitucija izraza sa lijeve strane
jednakosti izrazom sa desne sve dok više nije moguće napraviti supstituciju.

Pogledajmo korake redukcije našeg primjera 'zbroj 1 2':

1. zbroj 1 2
2. 1 + 2
3. 3

Izrazi se mogu klasificirati u tzv. forme. Nama bitne forme su:

1. Reducable Expression (RedEx)
   Svi izrazi koje je moguće reducirati.

2. Weak Head Normal Form (WHNF)
   Izraz reduciran sve do prvog vanjskog konstruktora vrijednosti ili lambda
   izraza. Ova forma je bitna jer u principu govori gdje lijena evaluacija
   "staje".

3. Normal Form (NF)
   Potpuno reducirani izraz koji ne sadrži RedExe u sebi.

U koracima 1 i 2 vidimo izraze koji su u RedEx formi. U koraku broj 3 rezultat
je vrijednost '3' koja je normalna forma izraza 'zbroj 1 2'. Broj 3 je ujedno i
u WHNF, zato što je prvi vanjski konstruktor vrijednosti.

Kako bi izgledala normalna forma izraza 'zbroj 1'? Prisjetimo se da je način na
koji smo definirali 'zbroj' samo sintaksni šećer za lambda funkcije te smo ju
mogli definirati i na slijedeći način:

zbroj = \ a -> ( \ b -> a + b )

Ako pokušamo reducirati izraz 'zbroj 1' imati ćemo slijedeće redukcijske korake:

1. zbroj 1
2. ( \ a -> ( \ b -> a + b ) ) 1
3. \ b -> 1 + b

Lambda izraz u kojem je 'a' zamijenjen sa '1' je normalna forma od 'zbroj 1'.


== Redukcijske strategije ======================================================

> kvadrat :: Num n => n -> n
> kvadrat a = a * a

Pogledajmo korake redukcije za izraz 'kvadrat ( zbroj 1 2 )':

1. kvadrat ( zbroj 1 2 )
2. kvadrat ( 1 + 2 )
3. kvadrat 3
4. 3 * 3
5. 9

Za sada ništa specijalno, no primijetimo da to nije jedini način za reducirati
taj izraz. U ovom konkretnom primjeru krenuli smo sa redukcijom iznutra prema
van.

Bez da nasumično određujemo koji izrazi i podizrazi će se prvi reducirati nameću
se dvije potencijalne strategije redukcije:

1. Redukcija iznutra prema van
2. Redukcija izvana prema unutra

Pogledajmo korake redukcije za 'kvadrat ( zbroj 1 2 )' sa strategijom redukcije
izvana prema unutra.

1. kvadrat ( zbroj 1 2 )
2. ( zbroj 1 2 ) * ( zbroj 1 2 )
3. ( 1 + 2 ) * ( zbroj 1 2 )
4. ( 1 + 2 ) * ( 1 + 2 )
5. 3 * ( 1 + 2 )
6. 3 * 3
7. 9

Na prvi pogled ova strategija se ne čini baš dobra. Potrebno je puno više koraka
evaluacije i nepotrebno se ponavlja jedna te ista operacija zbrajanja.

Prije nego što odbacimo strategiju izvana prema unutra, prisjetimo se definicije
funkcije 'head' i beskonačne liste jedinica 'ones' te pogledajmo kako primjena
naše dvije strategije na izraz 'head ones' utječe na rezultat.

head :: [ a ] -> a
head [] = error "empty list"
head ( x : _ ) = x

> ones :: Num a => [ a ]
> ones = 1 : ones

Koraci redukcije iznutra prema van su:

1. head ones
2. head ( 1 : ones )
3. head ( 1 : 1 : ones )
4. head ( 1 : 1 : 1 : ones )
...

Kao što vidimo, ovom strategijom redukcije nikada nećemo doći do rezultata jer
stalno pokušavamo reducirati najdublji izraz. U ovom slučaju je to 'ones' koji
nema normalnu formu kao i razne druge interesantne strukture s kojima bi
potencijalno htjeli baratati.

Pogledajmo sada korake redukcije izvana prema unutra:

1. head ones
2. head ( 1 : ones )
3. 1

Budući da prvo pokušavamo riješiti funkciju 'head' potrebno je znati koju od
dvije klauzule ćemo upotrijebiti.

Lista ima dva konstruktora vrijednosti. Jedan je '[]' koji ne prima argumente i
predstavlja praznu listu, a drugi je ':' tzv. cons ili konstruktor operator koji
prima jedan element tipa 'a' sa lijeve i listu 'a'ova sa desne strane.

Za odabir klauzule potrebno je samo znati koji od ta dva konstruktora odgovara
našem argumentu. Nije potrebno ići dublje u strukturu i dalje reducirati izraze.

Odnosno, potrebno je reducirati argument do WHNF.

Kao što vidimo, ova strategija nam omogućava da radimo sa strukturama koje
nužno nemaju normalnu formu što se čini dosta moćnije od prve strategije.

Ipak, prva strategija je nepobitno bolja po pitanju broja operacija kada ne
radimo sa beskonačnim strukturama. Pitanje je možemo li ikako poboljšati
redukciju izvana prema unutra i postići jednake ili bolje performanse?

Pogledajmo kako izraz 'kvadrat ( zbroj 1 2 )' izgleda u obliku stabla:

                          kvadrat ( zbroj 1 2 )
                                    |
                                    *
                                   / \
                          zbroj 1 2   zbroj 1 2
                              |           |
                              +           +
                             / \         / \
                            1   2       1   2

Primijetit ćemo da u principu imamo dvije identične grane te bi bilo idealno
spojiti te dvije grane u jednu na način da na prijašnje ogranke stavimo
pokazivač na tu jednu granu. Time ujedno argumenti funkcije umnoška na neki
način "dijele" argument funkcije 'kvadrat'.

                          kvadrat ( zbroj 1 2 )
                                    |
                                    *
                                   / \
                                  ●   ●
                                   \ /
                                zbroj 1 2
                                    |
                                    +
                                   / \
                                  1   2

Time smo smanjili broj potrebnih koraka redukcije pošto kada jednom reduciramo
granu zbroja, rezultat će odmah biti dostupan u lijevoj i desnoj grani množenja.

Usporedimo ponovno korake redukcije strategija iznutra prema van i izvana prema
unutra:

[ Iznutra prema van ]             [ Izvana prema unutra + dijeljeni argument ]

1. kvadrat ( zbroj 1 2 )          1. kvadrat ( zbroj 1 2 )
2. kvadrat ( 1 + 2 )              2. ( zbroj 1 2 ) * ( zbroj 1 2 )
3. kvadrat 3                      3. ( 1 + 2 ) * ( 1 + 2 )
4. 3 * 3                          4. 3 * 3
5. 9                              5. 9

Kao što vidimo, broj koraka redukcije sada je jednak, no sa redukcijom izvana
prema unutra i dijeljenim argumentom moguće je reducirati izraz i u manje koraka
nego sa strategijom iznutra prema van.

Ukratko, prošli smo kroz tri strategije evaluacije / redukcije:

1. Iznutra prema van (eng. innermost)
   Još se zove i call-by-value te odgovara striktnim programskim jezicima.

2. Izvana prema unutra (eng. outermost)
   Još poznata i kao call-by-name. Ne koristi se u praksi.

3. Iznutra prema van sa dijeljenim argumentima (eng. outermost with sharing)
   Još poznata i kao call-by-need ili u Haskellu redukcija grafa (graph
   reduction) te odgovara lijenim programskim jezicima.

Ono što je bitno primijetiti kod redukcije grafa je da se ta strategija može
primijeniti samo kod čistih jezika bez sporednih efekata (eng. side effects).
Kod jezika sa sporednim efektima, npr. ako funkcija 'zbroj' ujedno zapisuje
rezultat u datoteku, nećemo dobiti isti rezultat jer će se 'zbroj' pozvati samo
jednom.

Kao zaključak, možemo reći da su lijeni programski jezici oni jezici čiji je
evaluacijski model izvana prema unutra sa dijeljenim argumentima.


== Thunk =======================================================================

Thunk je u principu odgođeni dio koda koji će se izvršiti tek kada je to nužno.

Ako malo razmislimo, imati neki podatak i imati funkciju koja, kada ju pozovemo
bez argumenta, vrati tu istu vrijednost je u principu ista stvar.

> podatakD :: Int
> podatakD = 1

> podatakF :: () -> Int
> podatakF _ = 1

> fISd :: Bool
> fISd = podatakF () == podatakD

Tako da thunk možemo zamisliti kao funkciju koja treba vratiti podatak, a jednom
kad se taj thunk evaluira, ta funkcija se mijenja sa tim konkretnim podatkom
kako bi se spriječilo nepotrebno izvršavanje te funkcije ako se podatak koristi
više puta.

U GHCi-ju je moguće do neke mjere vidjeti stanje izvršenosti pojedinih izraza te
koji dijelovi su trenutno još u "thunk" obliku. Za to možemo koristiti ugrađenu
naredbu `:sprint` koja će pokušati ispisati izraz bez da forsira evaluaciju do
kraja.

Ako pokušamo ispisati `ones` vidjeti ćemo slijedeće:

ghci> :sprint ones
ones = _

Pošto nismo trebali ništa iz tog izraza, `ones` je još uvijek thunk što je
indicirano sa `_`. Ako pozovemo `head` na toj listi očekivali bi `:sprint ones`
ispiše nešto poput `1 : _`, no to se neće desiti:

ghci> head ones
1
ghci> :sprint ones
ones = _

Razlog je taj što je `ones :: Num n => [ n ]` previše polimorfan te se "čuva" za
potencijalno druga mjesta na kojima ga možemo pozvati gdje se npr. traže
`Double` lista jedinica umjesto `Int`.

Kako bi vidjeli efekt, potrebno je specijalizirati listu davanjem konkretnog
tipa elemenata liste:

> intOnes :: [ Int ]
> intOnes = ones

ghci> :sprint intOnes
intOnes = _
ghci> head intOnes
1
ghci> :sprint intOnes
intOnes = 1 : _

Ako pokušamo uzeti više elemenata liste dobiti ćemo slijedeće:

ghci> take 4 intOnes
[1,1,1,1]
ghci> :sprint intOnes
intOnes = 1 : 1 : 1 : 1 : _


== WHNF i seq ==================================================================

U prethodnim primjerima `head` forsira prvi element liste samo zato što je to
bilo potrebno kako bismo ispisali taj element na ekran. Da smo npr. samo
stavili taj izraz pod neki naziv i dalje bi bio samo thunk:

> theOne :: Int
> theOne = head intOnes

Prije nego ponovno probamo pogledati thunkove potrebno je ponovno učitati
program kako bismo izbrisali do sad evaluirane izraze.

ghci> :r
Ok, one module loaded.

Funkcija `seq` forsira izraz u WHNF.

ghci> :sprint intOnes
intOnes = _

ghci> seq intOnes ()
()

ghci> :sprint intOnes
intOnes = _ : _

Kao što vidimo, izraz je evaluiran do prvog konstruktora vrijednosti `:` tzv.
"cons" (cons dolazi od constructor) operatora.

ghci> seq theOne ()
()

ghci> :sprint theOne
theOne = 1

Primijetimo da je WHNF nekog broja ujedno i NF jer je sam taj broj zapravo
konstruktor. Ovo će možda biti malo jasnije kada obradimo definiranje vlastitih
podatkovnih tipova.


== Rekurzija 2 =================================================================

Prisjetimo se funkcije za izračun faktorijela iz druge lekcije o rekurzijama:

> fact1 :: ( Eq a , Num a ) => a -> a
> fact1 0 = 1
> fact1 x = x * fact1 ( x - 1 )

> fact2 :: ( Eq a , Num a ) => a -> a -> a
> fact2 0 acc = acc
> fact2 n acc = fact2 ( n - 1 ) ( n * acc )

> fact3 :: ( Eq a , Num a ) => a -> a
> fact3 n = fact2 n 1

Kao i verziju sa `seq`:

> fact2' :: ( Eq a , Num a ) => a -> a -> a
> fact2' 0 acc = acc
> fact2' n acc = let p = n * acc in seq p ( fact2 ( n - 1 ) p )

> fact3' :: ( Eq a , Num a ) => a -> a
> fact3' n = fact2' n 1

Pitanje je što se dešava kada definiramo neku vrijednost uz pomoć `fact1`:

> ex1 :: Int
> ex1 = fact1 3

Pogledajmo korake redukcije izraza `fact1 3`:

 1. fact1 3
 2. 3 * ( fact1 ( 3 - 1 ) )
 3. 3 * ( fact1 2 )
 4. 3 * ( 2 * ( fact1 ( 2 - 1 ) ) )
 5. 3 * ( 2 * ( fact1 1 ) )
 5. 3 * ( 2 * ( 1 * ( fact ( 1 - 1 ) ) ) )
 6. 3 * ( 2 * ( 1 * ( fact 0 ) ) )
 7. 3 * ( 2 * ( 1 * 1 ) )
 8. 3 * ( 2 * 1 )
 9. 3 * 2
10. 6

Kao što vidimo prije nego što dobijemo krajnje rješenje moramo sagraditi veliki
thunk neizvršenog koda što dodaje okvire na unutarnji stog. Memorijski dio
Haskell implementacije je nešto drugačiji od klasičnih jezika tako da stog u
Haskellu i npr. C-u nisu ista stvar ali konceptualno su dovoljno slični za naše
trenutne potrebe.

Poanta je da ovakvo građenje velikih izraza može uzrokovati stack overflow.

Taj problem obično rješavamo uz pomoć tail rekurzije i akumulatora. Taj obrazac
kompajler obično prepozna te ga efektivno optimizira u neku varijantu for petlje
čime izbjegne potrebu za dodavanjem novih okvira na stog zbog rekurzivnog poziva
funkcije.

U Haskellu je priča još malo kompliciranija zbog modela evaluacije koji ide
izvana prema unutra.

Ako se ravnamo prema striktnim jezicima kao što je C, redukcija izraza
`fact2 3 1` bi išla ovako:

1. fact2 3 1
2. fact2 2 ( 3 * 1 )
3. fact2 2 3
4. fact2 1 ( 2 * 3 )
5. fact2 1 6
6. fact2 0 ( 1 * 6 )
7. fact2 0 6
8. 6

Uvijek prvo reduciramo unutarnji izraz ako je moguće i samim time je prije
svakog rekurzivnog poziva akumulator sveden na konkretan broj.

Ono što se zapravo dešava u Haskell-u je slijedeće:

1. fact2 3 1
2. fact2 2 ( 3 * 1 )
3. fact2 1 ( 2 * ( 3 * 1 ) )
4. fact2 0 ( 1 * ( 2 * ( 3 * 1 ) ) )
5. 1 * ( 2 * ( 3 * 1 ) )
6. 1 * ( 2 * 3 )
7. 1 * 6
8. 6

Broj koraka u ovom konkretnom slučaju je isti, no ono što je bitno je da se
gradi veliko nereducirano stablo umnožaka u memoriji zato što se uvijek
pokušava reducirati najvanjskiji mogući izraz.

Uz pomoć `seq` funkcije možemo ručno kontrolirati kada će se neki izraz
reducirati te promijeniti evaluacijsku strategiju.
