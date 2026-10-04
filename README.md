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

## Ligue entre amis (comptes, sauvegarde en ligne, défis)

La ligue utilise un projet [Supabase](https://supabase.com) gratuit. Une seule mise en place :

1. Créer un compte sur supabase.com, puis **New project** (nom : `paso-a-paso`, région : Canada).
2. **SQL Editor › New query** : coller le contenu de [`supabase/schema.sql`](supabase/schema.sql), puis **Run**.
3. **Authentication › Sign In / Providers › Email** : décocher **Confirm email** (inscription immédiate, sans courriel à confirmer).
4. **Project Settings › API** (ou **Data API**) : copier la **Project URL** et la clé **anon public**, et les mettre dans `config.js` :

```js
window.PASO_CONFIG = { url: 'https://xxxx.supabase.co', key: 'eyJ…' };
```

La clé « anon » est publique par conception : les règles de sécurité (RLS) du fichier SQL font que
chacun ne modifie que son profil et ses défis, et que la sauvegarde complète reste privée.
Tant que `config.js` vaut `null`, l'app fonctionne normalement, sans la ligue.

Le tableau **Ma famille** (onglet Défis) lit la même table `profiles` : qui s'est inscrit et quand, qui a été actif aujourd'hui, les jours actifs de la semaine, les leçons, la série, les mots appris et l'unité en cours. Sur un projet déjà installé, relancer `supabase/schema.sql` ajoute les colonnes manquantes sans rien effacer.
