#import "@preview/touying:0.8.0": *
#import "dummies-theme.typ": *

#show: dummies-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Secrets pour les nuls],
    subtitle: [Protéger des mots de passe, pas à pas],
    author: [Thomas Coussot],
  ),
  ..if "notes" in sys.inputs { (config-common(show-notes-on-second-screen: right),) } else { () },
)
#set text(lang: "fr", size: 22pt)
#set raw(theme: none)

#let tbox(body, fill: white) = box(fill: fill, stroke: 2pt + black, inset: 0.5em, radius: 2pt, body)
#let mono(s, size: 0.7em) = text(font: "DejaVu Sans Mono", size: size, s)
#let db-table(..rows) = table(
  columns: 2,
  inset: 0.4em,
  stroke: 1.5pt + black,
  fill: (_, y) => if y == 0 { dy-yellow } else { white },
  align: left,
  ..rows,
)
#let arrow = text(size: 1.6em, weight: "black")[→]

// Surligne les caractères qui diffèrent entre deux chaînes de même longueur
#let diff-hex(a, b) = {
  let ca = a.clusters()
  let cb = b.clusters()
  for (i, c) in ca.enumerate() {
    if c == cb.at(i) { c } else { highlight(fill: dy-yellow, c) }
  }
}

#title-slide()

== Disclaimer

#side("1F6A7")[
  - Je ne suis *pas* un professionnel de la sécurité
  - Je suis développeur
  - Ce que vous allez voir : une démarche pédagogique, pas un audit
]

== Whoami

#side("1F9D1-200D-1F4BB")[
  *Thomas Coussot*

  - Tech lead @ Accenture
  - Chouchoute des produits, du besoin métier jusqu'au run (quand c'est possible)
]

= 0 - Intro

== Combien de fuites par an ? (France)

#grid(
  columns: (1fr, 0.9fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    #align(center)[
      #table(
        columns: 2,
        align: center,
        inset: 0.6em,
        stroke: 2pt + black,
        table.header[2024][2025],
        [5 629], [6 167 (record)],
      )

      violations de données personnelles notifiées à la CNIL
    ]

    #set text(size: 0.85em)
    - 1 incident sur 2 en 2025 relève d'un *piratage*
    - Les violations sont de plus en plus massives et impliquent souvent des prestataires
  ],
  image("rsc/pas-mal-non-cest-francais.jpg", width: 100%),
)

#v(1fr)
#text(size: 14pt)[Source : CNIL, #link("https://www.cnil.fr/fr/rapport-annuel-2025")[_Rapport annuel 2025_] (2024 : #link("https://www.cnil.fr/fr/rapport-annuel-2024")[_Rapport annuel 2024_]). Image : _La Classe américaine_ (mème)]

== Combien de comptes piratés en 2025 ? (monde)

#grid(
  columns: (1fr, 1.1fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    #align(center)[
      #text(size: 2em, weight: "black")[425,7 millions]

      de comptes piratés dans le monde en 2025
    ]

    #set text(size: 0.85em)
    - Soit environ *14 comptes compromis par seconde*
    - France : *40,3 millions* de comptes, 2#super[e] pays le plus touché (densité 12 fois la moyenne mondiale)
    - Plus grosse fuite française : Free Mobile (12,8 M de comptes)
  ],
  image("rsc/most_breached_countries_worldwide_in_2025.png", width: 100%),
)

#v(1fr)
#text(size: 14pt)[Source : Surfshark (CC BY 4.0), #link("https://surfshark.com/research/study/data-breach-recap-2025")[_Wrapping up 2025: global data breach statistics_]]

== Combien de données exposées ?

#side("1F4E7", size: 5em)[
  - *84,8 milliards* de données personnelles exposées depuis 2004
  - dont *24 milliards* d'adresses e-mail (≈ 2,5 autres données associées à chaque e-mail)
  - *10,6 milliards* de comptes piratés depuis 2020, soit 44 % du total depuis 2004
]

#v(1fr)
#text(size: 14pt)[Source : Surfshark, #link("https://surfshark.com/research/data-breach-monitoring/statistics")[_Data breach monitoring statistics_]]

== Have I Been Pwned et les secrets dans le code

#grid(
  columns: (1fr, 1.2fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.8em)
    *Le site*
    - haveibeenpwned.com : vérifier si votre e-mail apparaît dans une fuite

    *Le constat côté dev*
    - On n'a pas toujours accès à un service de gestion de comptes (authentification + autorisation)
    - Du coup, on doit parfois gérer les secrets *dans le code*
  ],
  image("rsc/haveibeenpwned.png", width: 100%),
)

#v(1fr)
#text(size: 14pt)[Capture : #link("https://haveibeenpwned.com")[haveibeenpwned.com]]

#speaker-note[
  Note : ne jamais coder soi-même ses libs de sécurité (hash, crypto, authentification). Utiliser des libs éprouvées et maintenues, par exemple Spring Security côté Java, qui fournit déjà des encodeurs de mots de passe (bcrypt, Argon2, PBKDF2).
]

= 1 - Pourquoi sécuriser les secrets ?

== Base de données en clair, comment ça arrive ?

#side("1F5C4", size: 4.5em)[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    [
      *Le risque*
      - Une fuite de la BDD = tous les mots de passe lisibles
      - Les utilisateurs réutilisent leurs mots de passe ailleurs
    ],
    [
      *Les causes*
      - Erreur de configuration
      - Mot de passe de BDD par défaut
      - Zero-day (exploitation d'une vulnérabilité inconnue)
    ],
  )
]

= 2 - Progressons petit à petit

== 2.1 - Chiffrement

- *Asymétrique* : inutile ici
- *Symétrique* : ce qui se chiffre se déchiffre. Problème : qui a la *clé* lit *tous* les mots de passe, alors qu'on n'a jamais besoin de les relire, seulement de les *vérifier* (d'où le hash)

#v(0.5em)
#align(center)[
  #grid(
    columns: (auto, auto, auto, auto, auto),
    column-gutter: 0.8em,
    align: horizon + center,
    [
      #text(size: 0.6em, weight: "bold")[BDD chiffrée]
      #db-table(
        [login], [mot de passe],
        mono[admin], mono[U2FsdGVkX19v8…],
        mono[alice], mono[U2FsdGVkX1+Qz…],
      )
    ],
    text(size: 1.2em, weight: "black")[+],
    [
      #image("rsc/icons/1F511.svg", height: 3em)
      #text(size: 0.6em, weight: "bold")[clé]
    ],
    text(size: 1.2em, weight: "black")[=],
    [
      #text(size: 0.6em, weight: "bold")[Fichier en clair]
      #db-table(
        [login], [mot de passe],
        mono[admin], mono[123456],
        mono[alice], mono[azerty],
      )
    ],
  )
]

== 2.2 - C'est quoi une fonction pure ?

- Même entrée → *toujours* la même sortie
- Aucun effet de bord (pas d'écriture, pas d'aléatoire, pas d'horloge)

#v(0.5em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    #align(center)[*Pure* #text(fill: rgb("#1a7f37"))[✔]]
    #tbox[
      #mono(size: 0.8em)[double(4) → 8] \
      #mono(size: 0.8em)[double(4) → 8] \
      #mono(size: 0.8em)[double(4) → 8]
    ]
    #v(0.2em)
    #text(size: 0.7em)[Toujours le même résultat]
  ],
  [
    #align(center)[*Pas pure* #text(fill: rgb("#cf222e"))[✘]]
    #tbox[
      #mono(size: 0.8em)[maintenant() → 12:03] \
      #mono(size: 0.8em)[maintenant() → 12:04] \
      #mono(size: 0.8em)[aleatoire() → 0.42]
    ]
    #v(0.2em)
    #text(size: 0.7em)[Dépend de l'extérieur]
  ],
)

== 2.2 - C'est quoi une fonction de hash ?

#let hash-box(body) = box(fill: white, stroke: 2pt + black, inset: 0.5em, radius: 2pt, body)

#align(center)[
  #grid(
    columns: (auto, auto, auto),
    column-gutter: 1em,
    align: horizon + center,
    stack(spacing: 0.4em, hash-box[`a`], hash-box[`password`], hash-box[`un très long texte…`]),
    box(fill: dy-yellow, stroke: 3pt + black, inset: 0.8em, text(weight: "black")[HASH]),
    stack(spacing: 0.4em, hash-box[`0cc175b9…`], hash-box[`5f4dcc3b…`], hash-box[`b3e5a2f1…`]),
  )
]

- Une fonction *pure*, à sens unique : on ne retrouve pas l'entrée depuis l'empreinte
- Entrée de taille quelconque → empreinte de *taille fixe*
- Un petit changement en entrée change tout en sortie

```
hash("password") = 5f4dcc3b5aa765d61d8327deb882cf99
hash("Password") = dc647eb65e6711e155375218212b3964
```

== 2.2 - Hashing : MD5

- Lecture en clair impossible, mais attaque par *brute force* possible
- *Problème* : les *collisions* (deux entrées différentes, même hash)

#let ma = "d131dd02c5e6eec4693d9a0698aff95c2fcab58712467eab4004583eb8fb7f8955ad340609f4b30283e488832571415a085125e8f7cdc99fd91dbdf280373c5bd8823e3156348f5bae6dacd436c919c6dd53e2b487da03fd02396306d248cda0e99f33420f577ee8ce54b67080a80d1ec69821bcb6a8839396f9652b6ff72a70"
#let mb = "d131dd02c5e6eec4693d9a0698aff95c2fcab50712467eab4004583eb8fb7f8955ad340609f4b30283e4888325f1415a085125e8f7cdc99fd91dbd7280373c5bd8823e3156348f5bae6dacd436c919c6dd53e23487da03fd02396306d248cda0e99f33420f577ee8ce54b67080280d1ec69821bcb6a8839396f965ab6ff72a70"
#let chunks(s) = range(0, s.len(), step: 64).map(i => s.slice(i, i + 64))

#v(0.3em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 0.8em,
  ..(("Message A", ma, mb), ("Message B", mb, ma)).map(((name, x, y)) => {
    let xs = chunks(x)
    let ys = chunks(y)
    tbox[
      #text(size: 0.6em, weight: "bold")[#name (128 octets)] \
      #for (i, l) in xs.enumerate() {
        mono(size: 7.6pt, diff-hex(l, ys.at(i)))
        linebreak()
      }
    ]
  }),
)

#align(center)[
  #text(size: 0.75em)[MD5 des deux messages : #mono(size: 1em)[79054025255fb1a26e4bc422aef54eb4]]
]

#v(1fr)
#text(size: 12pt)[Source : Wikipedia, #link("https://en.wikipedia.org/wiki/MD5#Collision_vulnerabilities")[_MD5 : Collision vulnerabilities_] (octets différents surlignés)]

#speaker-note[Démo live : `01-md5`]

== Les outils : hashcat et John the Ripper

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    *hashcat*
    #set text(size: 0.8em)
    - Casseur de hash « le plus rapide du monde »
    - Exploite le *GPU* (milliards d'essais par seconde)
    - Modes : dictionnaire (`-a 0`), règles de mutation (`-r`), force brute (`-a 3`)
    - On choisit l'algo avec `-m` (ex : `-m 0` = MD5)
  ],
  [
    *John the Ripper*
    #set text(size: 0.8em)
    - Le classique, né en 1996, historiquement orienté *CPU*
    - Détecte souvent seul le format du hash
    - Modes : dictionnaire (`--wordlist`), règles (`--rules`), incrémental
    - Très pratique pour les fichiers (zip, ssh, etc.) via `*2john`
  ],
)

#v(0.4em)
#align(center)[
  #mono(size: 0.8em)[hashcat -m 0 -a 0 md5.hash example.dict]
]

#v(1fr)
#text(size: 14pt)[Sites : #link("https://hashcat.net/hashcat/")[hashcat.net], #link("https://www.openwall.com/john/")[openwall.com/john]]

== Démo : MD5

Démo live (`01-md5/`) : hash d'une liste de mots de passe, puis cassage avec hashcat.

== 2.3 - SHA-256 / SHA-512

- Plus robuste face aux collisions
- Mais *trop rapide* : un GPU en teste des milliards par seconde

#v(0.5em)
#let hline(name, h) = (mono(size: 0.75em, name), mono(size: 0.62em, h))
#table(
  columns: (auto, 1fr),
  inset: 0.4em,
  stroke: 1.5pt + black,
  fill: (_, y) => if y == 0 { dy-yellow } else { white },
  [Algo], [Hash de `password`],
  ..hline("MD5", "5f4dcc3b5aa765d61d8327deb882cf99"),
  ..hline("SHA-256", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"),
  ..hline("SHA-512", "b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb9…"),
)

== MD5 et SHA : à quoi ça sert alors ?

- Ils sont faits pour être *rapides* : parfait pour le reste, mauvais pour les mots de passe
- *Intégrité* : vérifier qu'un fichier n'a pas été modifié ou corrompu (checksum d'un téléchargement)
- *Identifiants de contenu* : Git identifie commits et fichiers par leur hash
- *Signatures et certificats* : on signe le hash d'un document plutôt que le document entier
- *Déduplication, caches, tables de hachage*

#v(0.3em)
#align(center)[
  #mono(size: 0.8em)[sha256sum debian.iso → comparer avec le hash publié]
]

== Démo : SHA-512

Démo live (`02-sha512/`).

== 2.4 - HMAC

- *HMAC(clé, message)* : un hash qui mélange le message avec une *clé secrète*
- Même clé + même message → même résultat (fonction pure), mais sans la clé, impossible de le recalculer
- Sert de brique à *PBKDF2* (qui répète un HMAC des milliers de fois)

#v(0.3em)
#align(center)[
  #grid(
    columns: (auto, auto, auto, auto, auto),
    column-gutter: 0.8em,
    align: horizon + center,
    tbox[#mono[message]],
    text(size: 1.2em, weight: "black")[+],
    tbox(fill: dy-yellow)[#mono[clé secrète]],
    text(size: 1.2em, weight: "black")[→],
    box(fill: dy-yellow, stroke: 3pt + black, inset: 0.6em, text(weight: "black")[HMAC]),
  )

  #v(0.3em)
  #mono(size: 0.7em)[HMAC-SHA256("alice", clé) = 9c1f…]
]

== 2.4 - Hash lent

- *PBKDF2* (ex : PBKDF2-HMAC-SHA512) : on répète le hash des centaines de milliers de fois
- Le coût est réglable (nombre d'itérations)
- Le sel est optionnel ici : on y reviendra un peu plus tard

#v(0.4em)
#align(center)[
  #tbox(fill: white)[
    #mono(size: 0.9em)[PBKDF2-HMAC-SHA512(mot de passe, 220 000 itérations)]
  ]
]

#v(0.4em)
- D'autres algos de hash lent : *bcrypt*, puis *Argon2id* (recommandé aujourd'hui)

#speaker-note[
  220 000 itérations = valeur OWASP pour PBKDF2-HMAC-SHA512 (600 000 pour PBKDF2-HMAC-SHA256).
]

== 2.4 - Combien de hashs par seconde ?

- Mesures hashcat sur *un seul GPU grand public* (RTX 4090), par algorithme :

#v(0.3em)
#align(center)[
  #table(
    columns: (auto, auto),
    inset: 0.35em,
    stroke: 1.5pt + black,
    fill: (_, y) => if y == 0 { dy-yellow } else { white },
    align: left,
    [Algorithme], [Essais par seconde],
    [MD5], [164,1 milliards],
    [SHA-256], [22,0 milliards],
    [SHA-512], [7,5 milliards],
    [PBKDF2-SHA512 (220 000 it.)], [≈ 14 000],
    [bcrypt (coût 5)], [184 000],
    [Argon2id], [non mesuré (mémoire élevée : GPU peu efficace)],
  )
]

#v(0.2em)
#text(size: 0.65em)[PBKDF2 : mesuré à 999 itérations (3,1 M/s), ramené à 220 000 itérations (÷ 220). Plus c'est lent pour l'attaquant, mieux c'est.]

#v(1fr)
#text(size: 14pt)[Source : #link("https://gist.github.com/Chick3nman/32e662a5bb63bc4f51b847bb422222fd")[benchmark hashcat v6.2.6, RTX 4090]]

== 2.5 - Attaque : les rainbow tables

- Tables pré-calculées hash → mot de passe : on cherche le hash volé dans la table
- Rappel : un hash est une *fonction pure* → un même mot de passe donne *toujours* le même hash, donc on peut le pré-calculer une fois pour toutes

#v(0.3em)
#align(center)[
  #db-table(
    [Hash (MD5)], [Mot de passe],
    mono[e10adc3949ba59abbe56e057f20f883e], mono[123456],
    mono[5f4dcc3b5aa765d61d8327deb882cf99], mono[password],
    mono[d8578edf8458ce06fbc5bb76a58c5ca4], mono[qwerty],
    mono[ab4f63f9ac65152575886860dde480a1], mono[azerty],
    mono[0d107d09f5bbe40cade3de5c71e9e9b7], mono[letmein],
  )
]

#v(1fr)
#text(size: 14pt)[Extrait simplifié (une vraie rainbow table stocke des chaînes de hash). Exemple de vraies tables : #link("https://freerainbowtables.com/")[freerainbowtables.com]]

#speaker-note[
  Pour aller plus loin : #link("https://crackstation.net/hashing-security.htm")[crackstation.net/hashing-security.htm]
]

== 2.6 - Sel

- Valeur aléatoire *unique par utilisateur*, qu'on *colle au mot de passe* (concaténation) avant de hasher : hash(sel + mot de passe)
- Rend les rainbow tables inutilisables
- Stocké à côté du hash

#v(0.3em)
#align(center)[
  #table(
    columns: 4,
    inset: 0.4em,
    stroke: 1.5pt + black,
    fill: (_, y) => if y == 0 { dy-yellow } else { white },
    align: left,
    [login], [mot de passe], [sel], [hash (SHA-512, tronqué)],
    mono[alice], mono[password], mono[k9X2], mono[f9f58b8bbbf04c76…],
    mono[bob], mono[password], mono[Zp4q], mono[b347b2552f9dde33…],
  )

  #text(size: 0.75em)[Même mot de passe, hashs différents]
]

== 2.7 - Attaque : dictionnaire et mutations

- Le sel bloque les rainbow tables, mais pas un attaquant qui *teste des mots de passe probables*
- *Dictionnaire* : liste de mots de passe courants (issus de fuites, mots usuels)
- *Dictionnaire + mutations* : règles de transformation appliquées à chaque mot

#v(0.3em)
#align(center)[
  #db-table(
    [Dictionnaire], [Mutations testées],
    mono[password], mono[P\@ssw0rd · password1 · Password!],
    mono[soleil], mono[S0leil · soleil2024 · Soleil!],
  )

  #text(size: 0.75em)[hashcat : #mono(size: 1em)[-a 0] (dictionnaire), #mono(size: 1em)[-r] (règles de mutation)]
]

== 2.8 - Les mots de passe les plus courants

- Un dictionnaire n'est pas théorique : les mots de passe réels sont *très prévisibles*
- Top 10 mondial 2025 (NordPass ; la liste SecLists 2025 est quasi identique) :

#v(0.3em)
#align(center)[
  #table(
    columns: 5,
    inset: 0.4em,
    stroke: 1.5pt + black,
    fill: white,
    align: left,
    mono[1. 123456], mono[2. admin], mono[3. 12345678], mono[4. 123456789], mono[5. 12345],
    mono[6. password], mono[7. Aa123455], mono[8. 1234567890], mono[9. pass\@123], mono[10. admin123],
  )
]

#v(0.3em)
- Ils tombent tous dans les *premières secondes* d'une attaque par dictionnaire
- Même constat sur la liste *RockYou* (fuite de 2009) : `123456`, `12345`, `password`…

#v(1fr)
#text(size: 12pt)[Sources : NordPass 2025 (via #link("https://devolutions.net/blog/most-common-passwords-of-2025-the-more-things-change-the-more-they-stay-the-same/")[Devolutions]) ; #link("https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/2025-199_most_used_passwords.txt")[SecLists, 2025-199_most_used_passwords] ; RockYou : #link("https://en.wikipedia.org/wiki/RockYou")[Wikipedia] (fuite de décembre 2009, plus de 32 M de comptes) et #link("https://md5hashonline.com/most-common-passwords/")[md5hashonline.com] (classement)]

== 2.9 - Force brute et entropie

- Sans dictionnaire : on teste *toutes* les combinaisons. Le temps dépend de l'*alphabet* et surtout de la *longueur*
- Chaque caractère de plus multiplie le temps par la taille de l'alphabet

#v(0.3em)
#align(center)[
  #table(
    columns: 3,
    inset: 0.4em,
    stroke: 1.5pt + black,
    fill: (_, y) => if y == 0 { dy-yellow } else { white },
    align: left,
    [Mot de passe], [MD5], [bcrypt (coût 5)],
    [8 minuscules], [≈ 1,3 seconde], [≈ 13 jours],
    [8 caractères imprimables], [≈ 10 heures], [≈ 1 050 ans],
    [12 caractères imprimables], [≈ 92 000 ans], [≈ 82 milliards d'années],
  )
]

#v(0.2em)
#text(size: 0.7em)[Calcul : nombre de combinaisons ÷ vitesse d'une RTX 4090 (MD5 : 164 GH/s, bcrypt coût 5 : 184 kH/s). Un coût de 10 est 32 fois plus lent.]

#v(1fr)
#text(size: 14pt)[Vitesses : #link("https://gist.github.com/Chick3nman/32e662a5bb63bc4f51b847bb422222fd")[benchmark hashcat v6.2.6 sur RTX 4090]]

== 2.10 - Longueur plutôt que complexité

#align(center)[
  #move(dy: -24pt, image("rsc/xkcd-936-password-strength.png", height: 370pt))
]

#place(bottom + left, dy: 8pt, text(size: 12pt)[Source : #link("https://xkcd.com/936/")[xkcd 936, _Password Strength_] \ Randall Munroe, CC BY-NC 2.5])

#speaker-note[
  Une phrase de passe de plusieurs mots aléatoires est plus facile à retenir et plus longue qu'un mot court avec des substitutions (P\@ssw0rd), donc plus résistante à la force brute.
]

== 2.11 - Poivre

- Secret *commun* à tous les utilisateurs, *jamais stocké avec la BDD*
- Comme le sel, il est ajouté au mot de passe avant le hash, mais *il reste secret*
- Une fuite de la seule BDD (injection SQL, sauvegarde) ne suffit plus à casser les hashs : sans le poivre, impossible de tester des mots de passe

#v(0.3em)
#align(center)[
  #grid(
    columns: (auto, auto, auto),
    column-gutter: 1.2em,
    align: horizon + center,
    tbox[
      #text(size: 0.6em, weight: "bold")[Base de données] \
      #mono[hash + sel]
    ],
    text(size: 1.2em, weight: "black")[≠],
    tbox(fill: dy-yellow)[
      #text(size: 0.6em, weight: "bold")[Ailleurs (coffre, HSM…)] \
      #mono[poivre]
    ],
  )

  #v(0.4em)
  #mono(size: 0.8em)[hash(mot de passe + sel + poivre)]
]

== 2.12 - Poivre : où le stocker ?

- Secret *commun*, jamais stocké avec la BDD
- Où le stocker ? *Du plus au moins recommandé* :

#v(0.2em)
#set text(size: 0.72em)
#align(center)[
  #table(
    columns: (auto, auto, 1fr),
    inset: 0.35em,
    stroke: 1.5pt + black,
    fill: (_, y) => if y == 0 { dy-yellow } else { white },
    align: left,
    [\#], [Emplacement], [C'est quoi ?],
    [1], [*HSM* \ (matériel)], [Boîtier physique qui garde la clé : elle n'en sort jamais, on lui envoie des données et il calcule le HMAC],
    [1], [*KMS* \ (cloud)], [Même principe en service managé (AWS KMS, Azure Key Vault, GCP KMS), adossé à des HSM],
    [2], [*Secret manager*], [Coffre logiciel (Vault, AWS Secrets Manager) : l'appli récupère le poivre au démarrage, accès contrôlé et audité],
    [3], [Variable d'environnement], [Injectée au déploiement : lisible par quiconque accède au serveur ou aux dumps],
    [4], [Dans le code], [À éviter : fuite du dépôt = fuite du poivre],
  )
]

#v(1fr)
#text(size: 14pt)[Sources : #link("https://pages.nist.gov/800-63-4/sp800-63b.html")[NIST SP 800-63B-4] (secret « SHOULD » en HSM/TEE), #link("https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html")[OWASP] (vault ou HSM)]

== 2.13 - Poivre : quelle stratégie ?

#set text(size: 0.95em)
Deux façons d'utiliser le poivre (OWASP), avec bcrypt en exemple :

#v(0.3em)
#let flow(label, ..steps) = {
  grid(
    columns: (4.5em, 1fr),
    align: horizon + left,
    text(weight: "bold")[#label],
    {
      let items = ()
      for (i, s) in steps.pos().enumerate() {
        if i > 0 { items.push(arrow) }
        items.push(s)
      }
      stack(dir: ltr, spacing: 0.5em, ..items.map(x => box(x)))
    },
  )
}
#flow([Avant], tbox[mot de passe + *poivre*], tbox[bcrypt], tbox(fill: dy-yellow)[hash stocké])
#v(0.5em)
#flow([Après], tbox[mot de passe], tbox[bcrypt], tbox[HMAC(*poivre*, hash)], tbox(fill: dy-yellow)[hash stocké])
#v(0.4em)
- *Avant* : le poivre est collé au mot de passe, comme un sel secret
- *Après* : on hache normalement, puis on « signe » le hash avec un HMAC (vu plus tôt) dont la clé est le poivre
- À la connexion, on refait exactement le même calcul et on compare
- NIST et OWASP : plutôt *après* ; ParagonIE : *chiffrer* le hash avec une clé
- Changer de poivre impose un reset des mots de passe (ou garder l'ancien et stocker une *version* à côté du hash)

#v(1fr)
#text(size: 14pt)[Sources : #link("https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html")[OWASP] (Peppering), #link("https://pages.nist.gov/800-63-4/sp800-63b.html")[NIST SP 800-63B-4], #link("https://paragonie.com/blog/2016/02/how-safely-store-password-in-2016")[ParagonIE]]

#speaker-note[
  La rotation « directe » du chiffrement du hash est ma déduction : on déchiffre avec l'ancienne clé et on rechiffre avec la nouvelle, sans connaître le mot de passe. À valider avant de l'affirmer.
]

== 2.14 - Comparaison en temps constant

- Comparer deux hashs avec `==` s'arrête au *premier octet différent* : le temps de réponse fuit de l'information (*timing attack*)
- Utiliser une comparaison *en temps constant*
- Les libs de hash de mots de passe (bcrypt, Argon2…) font déjà la vérification pour vous : ne pas recoder la comparaison

#v(0.3em)
#align(center)[
  #db-table(
    [Langage], [Fonction],
    [Java], mono[MessageDigest.isEqual],
    [Python], mono[hmac.compare_digest],
    [Node.js], mono[crypto.timingSafeEqual],
  )
]

== 2.15 - Migrer d'anciens hashs

- Cas réel : une BDD en MD5 ou SHA-1, qu'on veut faire passer à Argon2id
- On ne peut pas convertir un hash : il faut le mot de passe en clair
- *À la connexion* : vérifier avec l'ancien hash, puis re-hasher avec le nouvel algo et remplacer
- Stocker l'algo et ses paramètres *avec le hash* (format PHC) pour accepter un mélange ancien/nouveau pendant la transition

#v(0.3em)
#align(center)[
  #tbox(fill: white)[
    #mono(size: 0.62em)[\$argon2id\$v=19\$m=19456,t=2,p=1\$\<sel\>\$\<hash\>]
  ]
]

#v(1fr)
#text(size: 14pt)[Source : OWASP, #link("https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html")[_Password Storage Cheat Sheet_] (Upgrading Legacy Hashes)]

== 2.16 - Attaques en ligne et hors ligne

- *Hors ligne* : l'attaquant a la BDD et teste à l'infini sur son GPU : seul le hash lent protège
- *En ligne* : l'attaquant passe par le formulaire de connexion, et on peut le freiner
  - Limiter le nombre d'essais (*rate limiting*), délais croissants, verrouillage temporaire
  - *MFA* : un mot de passe volé ne suffit plus
  - Détecter le *credential stuffing* (mots de passe réutilisés issus d'autres fuites)

== 2.17 - Refuser les mots de passe déjà fuités

- *Pwned Passwords* (HIBP) : des centaines de millions de mots de passe issus de fuites, interrogeables par API
- *k-anonymity* : on envoie seulement les *5 premiers caractères* du SHA-1, jamais le mot de passe

#v(0.3em)
#align(center)[
  #tbox(fill: white)[
    #mono(size: 0.7em)[GET api.pwnedpasswords.com/range/5BAA6]
  ]

  #v(0.2em)
  #text(size: 0.8em)[La réponse liste les suffixes de hash et leur nombre d'occurrences :]

  #tbox(fill: white)[
    #mono(size: 0.6em)[1E4C9B93F3F0682250B6CF8331B7EE68FD8:52373976]
  ]

  #text(size: 0.8em)[Le suffixe de `password` (SHA-1 `5BAA61E4…`) apparaît 52 373 976 fois]
]

#v(1fr)
#text(size: 14pt)[Source : #link("https://haveibeenpwned.com/API/v3#PwnedPasswords")[haveibeenpwned.com/API/v3]]

== 2.18 - Les bons exemples

- Suivre l'*OWASP Password Storage Cheat Sheet*
- Ne pas inventer sa propre crypto

#v(0.3em)
#align(center)[
  #table(
    columns: 2,
    inset: 0.4em,
    stroke: 1.5pt + black,
    fill: (_, y) => if y == 0 { dy-yellow } else { white },
    align: left,
    [Algorithme], [Paramètres minimum recommandés],
    [Argon2id], [19 Mio de mémoire, 2 itérations, 1 de parallélisme],
    [scrypt], [N = 2#super[17], r = 8, p = 1],
    [bcrypt], [facteur de coût ≥ 10],
    [PBKDF2-HMAC-SHA256], [600 000 itérations],
  )
]

#v(1fr)
#text(size: 14pt)[Source : OWASP, #link("https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html")[_Password Storage Cheat Sheet_]]

= 3 - Au-delà des mots de passe

== Les autres secrets : clés d'API, tokens

- Même problème, autre cible : un secret *commité dans git* reste dans l'historique
- Ne pas mettre les secrets dans le code, les logs ou les images Docker : *secret manager* (Vault, etc.) ou variables d'environnement injectées
- *Détecter* les fuites avant qu'elles partent : scan du dépôt et de l'historique

#v(0.3em)
#align(center)[
  #db-table(
    [Outil], [Rôle],
    [gitleaks], [scan d'un dépôt git (historique inclus), utilisable en pre-commit et en CI],
    [trufflehog], [scan et *vérification* que le secret trouvé est encore valide],
    [GitHub secret scanning], [détection côté plateforme, avec push protection],
  )
]

#v(1fr)
#text(size: 14pt)[Sites : #link("https://github.com/gitleaks/gitleaks")[github.com/gitleaks/gitleaks], #link("https://github.com/trufflesecurity/trufflehog")[github.com/trufflesecurity/trufflehog]]

= 4 - Ouverture

== Et après ?

#side("269B", size: 5em)[
  - Informatique quantique
  - Passwordless (passkeys)
]

== Merci !

#side("1F44B", size: 5em)[
  Questions ?
]

#v(1fr)
#text(size: 12pt)[Icônes : #link("https://openmoji.org")[OpenMoji], licence CC BY-SA 4.0]
