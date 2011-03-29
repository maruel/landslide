Corruption silencieuse de données
=================================

## exemples, détection et correction
### (si vous êtes chanceux)

.fx: main_slide

.notes: Qu'est-ce qui est pire qu'un crash? Bien sûr, une corruption de données
silencieuse.

.notes: Alors, qui peut expliquer clairement ce qu'est une corruption de données
silencieuse?

.notes: La prémise de base est simple. Vous avez des entrées, un processus et
des sorties. Dans un processus déterministe, les sorties seront toujours les
même pour le même processus et les mêmes entrées.

.notes: Cette présentation est à propos des comportements probabilistes et
comment les détecter. Au fait, je vais parler d'un crash ou deux dans certains
cas intéressants.

---

Problèmes matériels
===================

## PPC: Personal Probabilistic Computer

.fx: main_slide

.notes: En informatique, on aime bien le déterminisme. Malheureusement le
matériel ne remplit pas toujours la partie de son contrat.

---

CPU
---

#  AMD Errata
## 96 depuis les Athlons
<http://support.amd.com/us/processor_techdocs/41322.pdf>

#  Intel CPU Errata
## 142 juste pour le Core i7-9xx
<ftp://download.intel.com/design/processor/specupdt/320836.pdf>

Un processeur moderne ou un GPU a ~1 milliard de transistors, un seul a besoin
de mal fonctionner, occasionellement.

.notes: Premièrement, les processeurs sont vraiment pleins de bugs, de fonctions
cachées et évidement de microcode mutable.

.notes: Si vous voulez avoir mal au coeur, regardez les erratas de votre
processeur.

.notes: C'est donc parfois une bonne idée de ne pas être un des premiers à
acheter un nouveau produit. C'est en général la job du système d'exploitation de
régler les problèmes mais parfois ces problèmes sont des trous de sécurités,
particulièrement face aux machines virtuelles.

.notes: Une fois on a eu un problème occasionnel sur un serveur qui était
difficile à diagnostiquer, jusqu'à temps qu'on regarde de plus près et de voir
que le problème se manifestait seulement que lorsque l'opération était
"scheduled" sur le core #3.

.notes: La solution fût simple, désactiver le core #3.

---

Autres matériels
----------------

- La RAM (un classique)
- Contrôlleur PCI ou RAID

.notes: Je ne m'éterniserai pas là dessus mais évidement n'importe quelle partie
d'un ordinateur peut causer des problèmes occasionnels et non déterministes. Je
vais parler du pire.

---

Le pire: votre disque dur
-------------------------

Ratio d'erreur de lecture non récupérable par bits lu

- [Seagate: < 10^14](
    http://www.seagate.com/docs/pdf/datasheet/disc/ds_barracuda_xt.pdf)
- [Western digital: < 10^14](
    http://www.wdc.com/wdproducts/library/SpecSheet/ENG/2879-701276.pdf)
- [Samsung: 1 secteur par 10^15 bits](
    http://www.samsung.com/global/business/hdd/pr/brochures/downloads/2010_Internal%20HDD%20Product%20Guide%20Book_Rev.01.pdf)
- [Hitachi: < 10^14](
    http://www.hitachigst.com/tech/techlib.nsf/techdocs/155901D3B251D9A9862577D50023A20A/$file/DS7K3000_ds.pdf)

.notes: Regardez la diapositive. Qu'est-ce qu'elle montre? Si vous avez suivit
l'évolution des disques durs dans les dernières décénies, vous avez réalisé que
le taux d'erreur par lecteur est resté sensiblement le même alors que la
capacité a été multiplié par un facteur d'au dessus de mille. Donc maintenant ça
commence à être risqué d'essayer de lire un disque dur au complet une fois.
C'est pas aussi pire que le tableau peut sembler montrer car c'est les seuils de
tolérance mais j'espère que ça peut vous convaincre qu'un setup RAID n'est plus
très utile en 2011.

.notes: J'en avais parlé dans ma dernière présentation, le Terabyte benchmark,
nous classons 1Tb de chaines de 100 octets, donc 10,000,000,000 (dix milliards)
de chaines.

.notes: Quelqu'un se rappelle quel record Google a fait en 2008? Sur 1000
ordinateurs. 68 secondes.

.notes: Bon, un 1Tb, c'est bien mais c'est beaucoup trop rapide à classer alors
des programmeurs ont décidés de classer 1Pb. Quelqu'un veut deviner? Sur 4000
ordinateurs et 48000 disques durs. 6 heurs et 2 minutes.

.notes: Mais ce qui est vraiment intéressant, c'est qu'à chaque essai, au moins
un disque dur brisait. Donc, si vous utiliser un HD à 100% pendant 6h, vous avez
probablement une chance sur 50 milles qu'il brise. C'est beaucoup. Mais c'est ok
quand le disque dur plante, le système d'exploitation va avertir le processus,
peut-être qu'il va crasher mais l'important est que l'erreur n'est pas
silencieuse. Mais parfois le disque dur ne réussira pas à lire le secteur et va
retourner du déchet à la place de retourner une erreur. Et c'est exactement le
sujet de cette présentation.

---

Problèmes Logiciels
========

# Ça ne s'améliore pas...

.fx: main_slide

---

Calcul à virgule flotante
-------------------------

<http://en.wikipedia.org/wiki/Pentium_FDIV_bug>

- Les différences entre un calcul exécuté en SSE ou sur le FPU en 80 bits,
  save/load en double sur la stack, etc.
- GPU

32 bits

- (10.0000001-10) / (10.0000001-10)

64 bits

- (10.0000000000000001-10) / (10.0000000000000001-10)

.notes: Donc, pour ceux qui ont trouvé la réponse à l'énigme, bravo! Rammenez
vous en 1994. Le meilleur processeur était un Pentium 1 à 60 ou 66 mhz. Et ce
processeur ne pouvait diviser deux nombres correctement.

.notes: Mais le problème avec les nombres à virgules est bien plus grand. Quand
vous utilisez un processeur récent, le calcul est fait en 64 bits à la place de
80 car le SSE est utilis donc l'arrondit est différent. Et c'est encore pire
lorsque de l'accélération par GPU est utilisé.

.notes: Et c'est entre autre à cause que les GPUs ont un "rounding" qui est
"hard codé".

.notes: Et vous vous demandez encore pourquoi c'est important?

---

Attention au floats
-------------------

    <?php $d = 2.2250738585072011e-308; ?>

Et ces nombres?

    2.2250738585072008e-308
    2.2250738585072009e-308
    2.2250738585072010e-308
    2.2250738585072012e-308

Solution: Utiliser gcc -ffloat-store; mais pourquoi?

[Fixé dans SVN le 2011-01-06](http://bugs.php.net/bug.php?id=53632)

.notes: Bien, dans les versions vieilles de PHP, comme plus d'un mois, un
utilisateur peut faire geler le serveur au complet s'il peut mettre ce nombre
dans une variable.

.notes: Ce nombre representé le plus petit nombre en 64 bits qui est
sous-normal, 0.1111111111111111111111111111111111111111111111111111 x 2^-1022.

.notes: Currieusement, les nombres litéraux proches, qui retournent tous le même
nombre en double, ne cause pas ce problème. Est-ce que quelqu'un peut me dire
pourquoi? Il y a déjà un indice dans la diapo.

.notes: Alors qu'est-ce que --ffloat-store fait?

.notes: C'est une façon détournée de forcer toute les calculations à être
exécutés en 64 bits à la place du 80 bits qui est par défaut en plaçant de façon
systématique les doubles sur la stack. C'est évidemment pas très performant.

.notes: Aussi, ça ne se produit seulement parce que le SSE n'est pas utilisé.

.notes: Et le plus drôle est que le fichier source où il y avait le bogue venait
d'une vieille version de libc, mais php n'avait pas mis à jour leur copie quand
libc avait réglé le bogue il y a plusieurs années.

---

Compilateur
-----------

[gcc 4.3 red-zone overflow on x64](
  http://gcc.gnu.org/bugzilla/show_bug.cgi?id=39118)

- Leaf function
- Compilé avec "Frame Pointer Optimization" désactivé
- 128 octets de stack peut être utilisé sans déplacer le pointeur de stack
- Interruption au moment précis entre undata store et a data loads se produit
  dans la "red zone overflow" sur la stack
- Crash ou valeurs totalement invalides, dépendant du type de variable corrompu
- Totalement non-reproductible!

.notes: La zone rouge, c'est 128 octets que la fonction peut utiliser et qui ne
sera pas écrasée par un "signal handler" ou d'interruption.

.notes: Ça se produit lorsque le FPO a été désactivé pour aider au déverminage.

---

Librarie C standard
-------------------

`strstr()`

- [Valeur de retour invalide sur SSE2-SSE3](
    http://sourceware.org/bugzilla/show_bug.cgi?id=12092)
- Régression de la performance de la version SSE4 par rapport aux versions
  non-SSE4
- Octobre 2010

<http://sourceware.org/bugzilla/attachment.cgi?id=5037>

    strstr(
      "F_BD_CE_BD_EF_BF_BD_EF_BF_BD_EF_BF_BD_EF_"
        "BF_BD_C3_88_20_EF_BF_BD_EF_BF_BD_EF_BF_"
        "BD_C3_A7_20_EF_BF_BD",
      "_EF_BF_BD_EF_BF_BD_EF_BF_BD_EF_BF_BD_EF_"
        "BF_BD") != NULL

.notes: La version SSE4 était plus lente que les autre versions! Elle était
quadratique.

.notes: Les versions optimisés utilisent l'algorithme de Boyer-Moore.

.notes: C'est le genre de chaînes qu'on ne voit pas souvent, mais quand votre
mission est d'organiser l'information mondiale, ça arrive que des chaînes
étranges soient trouvées.

---

Librarie C standard (cont.)
---------------------------

`strncmp/strncase`

- Crash sur des longues chaînes qui se terminent à la fin d'une page de mémoire
  sur les version SSE2-SS3 x64
- <http://sourceware.org/bugzilla/show_bug.cgi?id=12077>
- Octobre 2010

.notes: Ce n'est pas une corruption silencieuse mais c'est quand même drôle, et
ça nous ai arrivé.

---

Votre programme multi-thread sans lock
------------------------------

    int sum = 0;

    void f() {
      for (int i = 0; i < 1000000; ++i)
        sum++;
    }

    void main() {
      t1 = start_thread(&f);
      t2 = start_thread(&f);
      join_thread(t1);
      join_thread(t2);
    }

.notes: Qui a déjà écrit une application avec plusieurs threads?

.notes: Qui comprend comment utiliser des locks?

.notes: Pour le monde qui reste, je crois que ce pseudo-code parle par lui-même.

.notes: Donc, qui peut me dire qu'est-ce qu'un lock
single-writer-multiple-reader est? Parfois un nom différent est utilisé.

.notes: Envoie moi ton CV.

---

Fiasco des clés ssh sur Debian
---------------------

Réduction de l'entropie sur les clés ssh générées entre 2006-2008

Seulement 32767 clés ssh différentes (!) peuvent être générés sur les versions
défectueuses

<http://debian.org/security/key-rollover/>

openssl.org n'était pas vulnérable, seulement les descendants de debian

Comment détecter une réduction d'entropie?

.notes: Un manque d'entropie est aussi une sorte de corruption silencieuse de
données. On s'attend à ce que le processus soit probabiliste alors qu'il est
déterministe!

.notes: Qui a une clé ssh?

.notes: Qui l'a créé en 2008 ou avant?

.notes: Qui a utilisé un système debian ou ubuntu pour la créer?

.notes: De ceux qui reste, qui pense que leur clé ssh est sécuritaire?

.notes: En passant, le manque d'entropie est une des nombreuses erreurs qui a
permit de cracker la PlayStation 3 il y a quelques semaines.

.notes: La chose à retenir est que l'entropie d'une source "random" est
extrêmement importante et qu'une réduction de son entropie ne sera pas visible.

---

Convaincu?
==========

## Comment détecter

.fx: main_slide

---

Quoi faire?
-----------

N'essayez pas

- Tests unitaires systématiques
- Retirer toute votre argent de la banque

À la place,

- Ne pas faire confiance aux logiciels
- Ne pas faire confiance au matériel
- Utiliser le plus de logiciels "open source"
- Faire confiance mais vérifier

.notes: Pourquoi je dis de favoriser les logiciels avec le code source
disponible? Ce n'est pas par évangélisme, c'est simplement que chaque boîte
noire augmente considérablement la difficulté de comprendre et d'identifier le
problème.

---

Détection
---------

La seule vraie façon de détection une corruption silencieuse de données est
d'être capable de rouler votre processus plusieurs fois avec les mêmes données
d'entrées pour comparer les sorties; sans effect secondaire et indépendemment de
l'ordinateur qui est utilisé.

---

Quand bâdrer
------------

Vous ne devriez pas faire attention pour:

- Données éphémères
- Données à être effacées
- Données non utilisées

Ce que vous devriez porter attention:

- La plupart des données utilisateurs
- N'importe quoi qui touche l'argent ou des propriétés de valeur

.notes: Premièrement, laissez-moi définir les données éphémère. C'est tout ce
qui est a une valeur qui est limité dans le temps et qui sera remplacé dans un
avenir connu d'avance.

.notes: Par exemple, si vous regardez une page web, ce n'est pas trop grave si
il y a un "glitch" car les données peuvent être regénérées facilement.

.notes: En particulier, ce sont les données en transit qui peuvent être
réenvoyés sans problème, comme des pages webs ou le traffic d'un jeu vidéo. Les
scores, par contre, sont importants à protéger.

.notes: En général, si vous offrez un service où les usagers peuvent mettre des
données dessus, les usagers vous font confiance.

---

Détection
---------

- Utiliser une signature cryptographique sur toutes les entrées
    - Vérifier la signature à la lecture
- Réduire les mutations de données
    - Utiliser une approche de programmation fonctionnelle
- Utiliser des processus isolés

.notes: Je fais référence aux données importantes seulement. Vous pouvez
toujours regénérer des nouvelles copies et faire du "garbage collection" avec
les tables précédentes. Je discuterai de cela plus tard.

.notes: Essayez de ne pas avoir des processus massivement "multithreadé" où tout
roule dans un seul processus. En faisant cela, vous augmentez massivement la
probabilité d'effets secondaires, causé par une utilisation inappropriée ou
l'absense de "locks" par exemple.

---

Système de fichiers
-----------

- Système de fichiers avec "snapshots" implicites
- Avantages
    - Hash des métadonnées
    - "Copy on write"
- Moins de mutation de secteurs sur le disque
- Désavantages
    - Plus d'accès aléatoires
    - Plus de fragmentation
    - Ces 2 problèmes sont moins criants sur de la mémoire flash

.notes: Les systèmes de fichiers meurent aussi. Qui a déjà eu des erreurs sur le
système de fichiers sur son ordinateur?

.notes: Si vous regardez les avantages, c'est essentiellement ce que j'ai dis
auparavant.

.notes: Qui peut m'en nommer un? BTRFS? ZFS?

.notes: BTRFS n'est pas recommandé encore mais vous devriez changer aussitôt que
c'est viable.

---

Base de données
---------------

- Ne *jamais* effacer les “évidences”
- L'espace disque coûte toujours moins cher
- Les bases de données se compressent facilement
- Un index peut facilement être recréé
- Déterminer ce qui est important, ce qui ne l'est pas
    - Est-ce possible de recréer une table à partir d'autres? Est-ce que ça peut
      être bidirectionel?
    - Inutile s'il n'y a pas de signature sur chaque entrée
- Hash des entrées individuelles et non du fichier au complet
- Visez la replication à la place d'archivage (backup)
    - Fonctionnement seulement bien avec des bases de données "Append-Only"

.notes: L'idée est d'utiliser une approche de programmation fonctionnelle, où
aucune donnée n'est jamais modifiée mais seulement des nouvelles données sont
créées. BigTable est construit sur ce principle en utilisant des SSTables.

.notes: Qui peut me dire ce qu'est une SSTable? CV?

.notes: SSTable est l'accronyme de Sorted Strings table. Cherchez sur le net
pour plus de détails. Donc BigTable, pour émuler des entrées modifiables, ajoute
simplement des nouvelles entrées à la fin de la table et met à jour l'indexe.

.notes: Mais l'index est mutable? On s'en fout car il peut être recréé.

.notes: Et une fois qu'une SSTable a trop de junk dedans, on en regénère
d'autres et on échange les tables actives. Les anciennes tables sont mangées par
le garbage collector. Et si ça sonne comme l'implémentation de String dans tous
les languages avec une gestion de mémoire par GC, c'est normal car des données
en lecture seule sont plus sécuritaire et les GC fonctionnent.

.notes: Et c'est encore plus simple lorsque vous savez qu'un disque dur, c'est
pas cher. Et vous pouvez répliquer les tables en temps réel car la table est
"Append-Only", son contenu n'est jamais modifié.

.notes: Mais garder les entrées individueles d'une table est important. Le
fichier n'est qu'un contenant. Peut-être qu'une seule entrée fut corrompue,
c'est donc d'important de pouvoir sauvegarder le maximum de données.

.notes: N'oubliez pas, effacer un fichier c'est rapide. La réplication est
simple lorsqu'il n'y a pas de mutation.

---

Distributed parallel fault-tolerant file system
-----------------------------------------------

- Plusieurs copies
    - Redondance intégrée
- Plusieurs ordinateurs dans un "cluster"
    - Vérifie automatiquement si un ordinateur est mort ou une copie est
      corrompue
- C'est surtout
    - Redondance
    - Absense de localité d'ordinateur, "computer-locality"
      - Utilisation de "rack locality" à la place
      - C'est ce que la plupart des architectes de base de données font!

.notes: Qui peut me nommer un système de fichier distribué qui est tolérant aux
erreurs

.notes: GFS, hadoop distributed file system, HDFS, AFS

.notes: Facebook, IBM, Linkedin, Twitter, Rackspace.

---

En conclusion
=============

---

Approche programmation fonctionnelle
--------------------------------------

Données en lecture seule le plus possible

Un algorithme à utiliser potentiellement est MapReduce

.notes: Pour les données importantes seulement

---

Utiliser des processus déterministes
------------------------------------

- Données d'entrées immuables
- Les données de sorties sont toujours les même pour un même processus
- Indépendant de l'ordinateur sur lequel le processus roule

C'est la seule façon de vérifier votre algorithme d'une façon automatisée

.notes: Ou de même essayer de déverminer une erreur transiente. Les "memory
dumps" sont moins utiles car en général, on n'a pas accès aux données d'entrées.

---

Redondance d'exécution
----------------------

Rouler de façon préemptive quelques "jobs" plusieurs fois pour détecter une
corruption silencieuse de données en comparant des résultats de façon proactive
et de facon automatisée

## Un logiciel redondant est beaucoup plus solide que du matériel redondant

---

Regardez vos flux de données
----------------------------

Signifie fréquemment réécrire une bonne partie des flux de données dans votre
logiciel.

Mais quel est le coût d'une corruption silencieuse (ou visible) dans votre
projet, versus la probabilité que ça se produise.

.notes: C'est difficile, vraiment difficile. Vous ne pouvez facilement changer
une logiciel sans changer ses fonctionalités de base. Mais si vous pensez à
créer une start up qui va peut-être attendre des millions d'utilisateurs,
pensez-y deux fois.

---

Merci!
======

## Les sources de cette présentation seront à
## <http://github.com/maruel/landslide>

.fx: main_slide
