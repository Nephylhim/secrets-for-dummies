#import "@preview/touying:0.8.0": *
#import "dummies-theme.typ": *

#show: dummies-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Secrets pour les nuls],
    subtitle: [Protéger des mots de passe, pas à pas],
    author: [Thomas Coussot],
  ),
)
#set text(lang: "fr", size: 22pt)
#set raw(theme: none)

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

#side("1F1EB-1F1F7", size: 4.5em)[
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

  - 1 incident sur 2 en 2025 relève d'un *piratage*
  - Les violations sont de plus en plus massives et impliquent souvent des prestataires
]

#v(1fr)
#text(size: 14pt)[Source : CNIL, _Rapport annuel 2025_, cnil.fr/fr/rapport-annuel-2025 (2024 : _Rapport annuel 2024_)]

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
#text(size: 14pt)[Source : Surfshark (CC BY 4.0), _Wrapping up 2025: global data breach statistics_, surfshark.com/research/study/data-breach-recap-2025]

== Combien de données exposées ?

#side("1F4E7", size: 5em)[
  - *84,8 milliards* de données personnelles exposées depuis 2004
  - dont *24 milliards* d'adresses e-mail (≈ 2,5 autres données associées à chaque e-mail)
  - *10,6 milliards* de comptes piratés depuis 2020, soit 44 % du total depuis 2004
]

#v(1fr)
#text(size: 14pt)[Source : Surfshark, _Data breach monitoring statistics_, surfshark.com/research/data-breach-monitoring]

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
#text(size: 14pt)[Capture : haveibeenpwned.com]

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

#side("1F510")[
  - *Asymétrique* : inutile ici
  - *Symétrique* : ce qui se chiffre se déchiffre

  #align(center)[BDD + clé = fichier en clair]
]

== 2.2 - C'est quoi une fonction pure ?

#side("2699")[
  - Même entrée → *toujours* la même sortie
  - Aucun effet de bord (pas d'écriture, pas d'aléatoire, pas d'horloge)

  ```
  double(4) = 8     // toujours
  ```
]

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

#side("1F4A5", size: 5em)[
  - Lecture en clair impossible
  - Mais : attaque par *brute force* (on hashe des candidats jusqu'à tomber sur le même hash)
  - *Problème* : les collisions (deux entrées différentes, même hash)
]

#speaker-note[Démo live : `01-md5`]

== Démo : MD5

Démo live (`01-md5/`) : hash d'une liste de mots de passe, puis cassage avec hashcat.

== 2.3 - SHA-256 / SHA-512

#side("1F680", size: 5em)[
  - Plus robuste face aux collisions
  - Mais *trop rapide* : un GPU en teste des milliards par seconde
]

== Démo : SHA-512

Démo live (`02-sha512/`).

== 2.4 - Hash lent

#side("1F40C", size: 5em)[
  - *PBKDF2* (ex : PBKDF2-HMAC-SHA512) : SHA-512 répété des centaines de milliers de fois
  - Le coût est réglable (nombre d'itérations)
  - Le sel est un simple *paramètre* : il n'est pas ajouté automatiquement (contrairement à bcrypt ou Argon2)
  - Contre-attaque : *dictionnaire* + mutations (`password` → `P@ssw0rd1`)
]

== 2.5 - Rainbow tables

#side("1F308", size: 5em)[
  - Tables pré-calculées hash → mot de passe
  - Un même mot de passe donne toujours le même hash
]

== 2.6 - Sel

#side("1F9C2", size: 5em)[
  - Valeur aléatoire *unique par utilisateur*, ajoutée avant le hash
  - Rend les rainbow tables inutilisables
  - Stocké à côté du hash
]

== 2.7 - Poivre

#side("1F336", size: 5em)[
  - Secret *commun*, jamais stocké avec la BDD
  - Stockage possible :
    - Secret manager (ex : Vault)
    - Variables d'environnement
    - Code
]

== 2.8 - Les bons exemples

#side("2705", size: 5em)[
  - Suivre l'*OWASP Password Storage Cheat Sheet*
  - Ne pas inventer sa propre crypto
]

// TODO: détailler les paramètres recommandés (Argon2id, etc.)

= 3 - Ouverture

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
#text(size: 12pt)[Icônes : OpenMoji (openmoji.org), licence CC BY-SA 4.0]
