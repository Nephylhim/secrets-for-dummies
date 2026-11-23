# TODO

- Slide lien vers projet github
- Slide QR Code vers le PDF des slides
- Petite mention "N'hésitez pas à m'interrompre" ?
- Présenter *bcrypt* puis *Argon2id* après PBKDF2 (slide « Hash lent »), avec leurs paramètres (OWASP : Argon2id 19 Mio / 2 itérations / 1 ; bcrypt coût ≥ 10)
  - Les remettre dans « Combien de hashs par seconde ? » : bcrypt ≈ 184 000 essais/s (coût 5, RTX 4090), Argon2id non mesuré (à mesurer avec `hashcat -b`)
  - Encore cités sans explication : migration (2.16), bons exemples (2.19), note Spring Security (speaker note)
  - Argon2 a un paramètre optionnel « secret » (poivre natif, RFC 9106 §3.1) : voir la speaker note de 2.14
- Démos supplémentaires : PBKDF2 / bcrypt / Argon2
