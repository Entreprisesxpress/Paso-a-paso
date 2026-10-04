# Paso a Paso

Application d'espagnol d'Amérique latine (Mexique) pour un francophone du Québec :
le chantier de rénovation, le voyage et le quotidien. Sans pub, sans vies, sans limite.

**Ouvrir l'app : https://entreprisesxpress.github.io/Paso-a-paso/**

Sur iPhone : ouvre le lien dans Safari › Partager › « Sur l'écran d'accueil ».
Sur Android : Chrome › « Installer l'application ». L'app fonctionne ensuite hors ligne.

## Contenu du dépôt

- `index.html`, `manifest.webmanifest`, `sw.js`, icônes : l'app publiée (GitHub Pages, branche `main`, dossier racine).
- `source/paso-a-paso.html` : la source, identique à la version Claude (avec le tuteur IA et la sauvegarde en ligne,
  qui ne s'activent que dans Claude).
- `build.cjs` : régénère l'app publiée à partir de la source (`node build.cjs`, nécessite Playwright pour les icônes).
