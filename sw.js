// Paso a Paso : fonctionne hors ligne. L'app se met à jour en arrière-plan à chaque ouverture avec réseau.
const CACHE = 'paso-v1791598775860';
const SHELL = ['./', './index.html', './config.js', './manifest.webmanifest', './icon-192.png', './icon-512.png', './apple-touch-icon.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL.map(u => new Request(u, { cache: 'reload' })))).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  // Seulement les fichiers de l'app et les polices : les appels à la ligue (Supabase) vont toujours au réseau,
  // sinon le classement et les défis resteraient figés sur leur première version.
  const u = new URL(e.request.url);
  if (u.origin !== self.location.origin && !/^fonts\.(googleapis|gstatic)\.com$/.test(u.hostname)) return;
  // La page elle-même : réseau d'abord (3 s max), pour toujours ouvrir la dernière version ; cache hors ligne.
  // config.js aussi : un changement de configuration (ex. activation de la ligue) doit servir dès le premier lancement.
  if (e.request.mode === 'navigate' || u.pathname.endsWith('/config.js')) {
    e.respondWith(caches.open(CACHE).then(c => Promise.race([
      fetch(e.request, { cache: 'no-store' }).then(r => { if (r && r.ok) c.put(e.request.mode === 'navigate' ? './index.html' : e.request, r.clone()); return r; }),
      new Promise((_, no) => setTimeout(no, 3000)),
    ]).catch(() => (e.request.mode === 'navigate' ? c.match('./index.html').then(h => h || c.match('./')) : c.match(e.request, { ignoreSearch: true })).then(h => h || fetch(e.request)))));
    return;
  }
  e.respondWith(caches.open(CACHE).then(async c => {
    const hit = await c.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(r => { if (r && (r.ok || r.type === 'opaque')) c.put(e.request, r.clone()); return r; }).catch(() => hit);
    return hit || net;
  }));
});
