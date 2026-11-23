# TODO

- Slide lien vers projet github
- Slide QR Code vers le PDF des slides
- Petite mention "N'hésitez pas à m'interrompre" ?
- Présenter *bcrypt* puis *Argon2id* après PBKDF2 (slide « Hash lent »), avec leurs paramètres (OWASP : Argon2id 19 Mio / 2 itérations / 1 ; bcrypt coût ≥ 10)
  - Ces slides citent déjà bcrypt/Argon2id (vitesses 2.4, entropie 2.9, migration 2.16, bons exemples 2.19, note Spring Security) : les présenter avant ou accepter la mention. Argon2id reste « non mesuré » (à mesurer avec `hashcat -b`)
  - Argon2 a un paramètre optionnel « secret » (poivre natif, RFC 9106 §3.1) : voir la speaker note de 2.14
- Démos supplémentaires : PBKDF2 / bcrypt / Argon2
