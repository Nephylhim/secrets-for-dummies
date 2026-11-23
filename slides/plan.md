Secrets
Disclaimer sécu, pas pro, je suis dev

Whoami

0 - intro

Fuites de données. Sujet + chiffres.
HaveIBeenPwned.
Services de gestion des compte authentication + authorization pas tjs utilisable.

1- Pourquoi on sécurise des secrets ?

Bdd en clair

Comment ça arrive?

erreur de conf
mdp Db par défaut
zero day (expl. Vuln)

2- Progressons sur la sécurisation petit à petit

2.1- chiffrement

Asymétrique inutile
Symétrique ça se déchiffre.

db + clé = fichier clair

2.2- Hashing md5

Lecture Claire inutile.
Explication brute force.

Explication fn pure
Explication fn hash

Pb collision

2.3- SHA256

Trop rapide

2.4- Hash lent

Lequel?

Atk dictionnaire mut.

2.5- Rainbow tables

2.6- Sel

2.7- Poivre

Fonctionnement.
Stockage:
- Secret Manager (ex: Vault)
- Env
- Code

2.8- Les bons exemples

OWASP

3- ouverture

Quantique
Passwordless
