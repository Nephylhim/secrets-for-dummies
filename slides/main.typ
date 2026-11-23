#import "@preview/touying:0.6.1": *
#import themes.metropolis: *

#show: metropolis-theme.with(
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

- Je ne suis *pas* un professionnel de la sécurité
- Je suis développeur
- Ce que vous allez voir : une démarche pédagogique, pas un audit

== Whoami

*Thomas Coussot*

- Tech lead @ Accenture
- Chouchoute des produits, du besoin métier jusqu'au run (quand c'est possible)

= 0 - Intro

== Les fuites de données

- Coût moyen mondial d'une fuite en 2025 : *4,44 M\$* (10,22 M\$ aux États-Unis)
- Délai moyen d'identification + confinement : *241 jours*

#v(1fr)
#text(size: 14pt)[Source : IBM, _Cost of a Data Breach Report 2025_ (juillet 2025), ibm.com/reports/data-breach]

== Have I Been Pwned

- haveibeenpwned.com : vérifier si votre e-mail apparaît dans une fuite
- Les services de gestion de comptes (authentification + autorisation) existent,
  mais ne sont pas toujours utilisables

// TODO: ajouter un chiffre HIBP sourcé (nombre de comptes référencés)

= 1 - Pourquoi sécuriser les secrets ?

== Base de données en clair

- Une fuite de la BDD = tous les mots de passe lisibles
- Les utilisateurs réutilisent leurs mots de passe ailleurs

== Comment ça arrive ?

- Erreur de configuration
- Mot de passe de BDD par défaut
- Zero-day (exploitation d'une vulnérabilité inconnue)

= 2 - Progressons petit à petit

== 2.1 - Chiffrement

- *Asymétrique* : inutile ici
- *Symétrique* : ce qui se chiffre se déchiffre

#align(center)[BDD + clé = fichier en clair]

== 2.2 - Hashing : MD5

- Lecture en clair impossible
- Mais : attaque par *brute force*

*Fonction pure* : même entrée → même sortie, sans effet de bord

*Fonction de hash* : entrée de taille quelconque → empreinte de taille fixe, non réversible

*Problème* : les collisions

#speaker-note[Démo live : `01-md5`]

== Démo : MD5

Démo live (`01-md5/`) : hash d'une liste de mots de passe, puis cassage avec hashcat.

== 2.3 - SHA-256 / SHA-512

- Plus robuste face aux collisions
- Mais *trop rapide* : un GPU en teste des milliards par seconde

== Démo : SHA-512

Démo live (`02-sha512/`).

== 2.4 - Hash lent

- Lequel ? bcrypt, scrypt, Argon2…
- Contre-attaque : attaque par *dictionnaire* + mutations (`password` → `P@ssw0rd1`)

== 2.5 - Rainbow tables

- Tables pré-calculées hash → mot de passe
- Un même mot de passe donne toujours le même hash

== 2.6 - Sel

- Valeur aléatoire *unique par utilisateur*, ajoutée avant le hash
- Rend les rainbow tables inutilisables
- Stocké à côté du hash

== 2.7 - Poivre

- Secret *commun*, jamais stocké avec la BDD
- Stockage possible :
  - Secret manager (ex : Vault)
  - Variables d'environnement
  - Code

== 2.8 - Les bons exemples

- Suivre l'*OWASP Password Storage Cheat Sheet*
- Ne pas inventer sa propre crypto

// TODO: détailler les paramètres recommandés (Argon2id, etc.)

= 3 - Ouverture

== Et après ?

- Informatique quantique
- Passwordless (passkeys)

== Merci !

Questions ?
