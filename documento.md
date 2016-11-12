Tools
=====

Per sviluppare il problema ho **scrito un codice nel linguaggio R**, ed
ho fatto uso dei pacchetti[^1]: *rattle*, *rpart.plot*, *randomforest*.

Organizzazione dei dati
=======================

Pulizia
-------

Per togliere i dati “*sporchi*” dai set di dati ho **eliminato** da
*train* le righe:

-   con date multiple

-   con le colonne allineate in maniera errata

Dati mancanti
-------------

ho colmato i dati mancanti:

-   per la variabile **Punteggio** ho assegnato la mediana ai dati *NA*
    e a quelli *equipment or floor not properly drained*

-   ho assegnato il **Coefficiente di livello** in base alla tabella
    [tab:punteggi]

-   ho considerato nel valore **Criticità**, *anti-siphonage or backflow
    prevention device not provided where required* come *Critical*, in
    modo da avere gli stessi valori (*Critical*, *Not Critical*, *Not
    Applicable*) in entrambi i set di dati

-   ho cercato con un **decision tree** il **Quartiere** per i dati in
    cui risultava *Missing*; per cercare il quartiere ho usato come
    parametro principale il Codice postale 

Nuove categorie
---------------

Ho dovuto[^2] raggruppare i valori in macro aree, ho altresì aggiunto
nuove variabili al modello:

-   ho raggruppato **Tipo cucina**, per esempio la categoria
    *Californian* e la categoria *Hawaiian* sono raggruppate nella
    macro-categoria *American*

-   ho aggiustato **Tipo ispezione**, per esempio, considerando
    cosiderando *re-opening* come *initial* trattando quindi che un
    locale che ha riaperto come un locale nuovo

-   ho creato delle **Zone** basandomi sul Codice postale

-   ho creato una variabile **Prefisso telefonico** poiché a New York
    può essere importante[^3]!

      Regola      Coefficiente
  -------------- --------------
    $p\leq13$          A
   $13<p\leq27$        B
      $27<p$           C

[tab:punteggi]

Random Forest {#sec:randomforest}
=============

Per cercare **quale Azione sarebbe stata intrapresa nei confronti del
ristorante** ho usato un algoritmo **random forest**.

Ho provato ad includere quanti più parametri possibili e ho capito che varibili come
**Criticità**, **Tipo ispezione** e **Punteggio** hanno un peso
importante!

Dopo vari tentativi volti ad ottimizzare l’uso delle varibili ho
costruito la **foresta principale**, da cui ho poi creato la tabella dei
risultati.

Risultati
=========

Prima di compilare i risultati ho supposto che nel caso:

-   *Establishment re-closed by DOHMH* il locale **chiudesse**

-   *Establishment re-opened by DOHMH* il locale **non avesse
    violazioni**

Ho infine salvato i risultati nel file *submit.csv*.

[^1]: <https://cran.r-project.org/web/packages/>

[^2]: Con più di 54 categorie rpart da’ errore

[^3]: <http://archive.is/2016.08.07-072128/http://www.linkiesta.it/it/article/2011/04/26/a-new-york-i-prefissi-telefonici-li-mettono-allasta/618/>
