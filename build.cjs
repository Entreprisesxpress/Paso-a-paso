const fs = require('fs');
const { chromium } = require('playwright');
const src = fs.readFileSync(__dirname + '/source/paso-a-paso.html', 'utf8');
const VERSION = 'v' + Date.now();
const head = `<!doctype html><html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#e4007c">
<meta name="description" content="Apprends l'espagnol d'Amérique latine pour le chantier, le voyage et le quotidien.">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="Paso a Paso">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" type="image/png" sizes="192x192" href="icon-192.png">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<script src="config.js"></script>
<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0;font:14px system-ui,sans-serif}img{max-width:100%}[hidden]{display:none!important}</style>
</head><body>`;
const tail = `<script>if ('serviceWorker' in navigator) addEventListener('load', () => navigator.serviceWorker.register('sw.js').catch(() => {}));</script></body></html>`;
fs.writeFileSync(__dirname + '/index.html', head + src + tail);
// config.js : adresse et clé publique du projet Supabase (ligue entre amis). Jamais écrasé s'il existe.
if (!fs.existsSync(__dirname + '/config.js')) fs.writeFileSync(__dirname + '/config.js', '// Ligue entre amis : remplir avec l\'adresse et la clé « anon » du projet Supabase.\nwindow.PASO_CONFIG = null;\n');
fs.writeFileSync(__dirname + '/manifest.webmanifest', JSON.stringify({
  name: 'Paso a Paso', short_name: 'Paso a Paso', description: "Espagnol d'Amérique latine pour le chantier, le voyage et le quotidien.",
  lang: 'fr', start_url: './', scope: './', display: 'standalone', orientation: 'portrait',
  background_color: '#f7f5fb', theme_color: '#e4007c',
  icons: [{ src: 'icon-192.png', sizes: '192x192', type: 'image/png' }, { src: 'icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: 'icon-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' }],
}, null, 2));
fs.writeFileSync(__dirname + '/sw.js', `// Paso a Paso : fonctionne hors ligne. L'app se met à jour en arrière-plan à chaque ouverture avec réseau.
const CACHE = 'paso-${VERSION}';
const SHELL = ['./', './index.html', './config.js', './manifest.webmanifest', './icon-192.png', './icon-512.png', './apple-touch-icon.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(caches.open(CACHE).then(async c => {
    const hit = await c.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(r => { if (r && (r.ok || r.type === 'opaque')) c.put(e.request, r.clone()); return r; }).catch(() => hit);
    return hit || net;
  }));
});
`);
const mascotMatch = src.match(/function mascot\(mood\) \{[\s\S]*?\n\}/)[0];
const tokens = src.match(/:root\{\n[\s\S]*?\n\}/)[0];
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
  const p = await b.newPage();
  await p.setContent(`<style>${tokens} body{margin:0} .ic{display:grid;place-items:center;background:var(--pink)} .ic svg{display:block}</style><div id="i" class="ic"></div><script>${mascotMatch}</script>`);
  for (const [name, size, pad] of [['icon-512.png', 512, .12], ['icon-192.png', 192, .12], ['apple-touch-icon.png', 180, .1], ['icon-maskable-512.png', 512, .22]]) {
    await p.evaluate(([size, pad]) => { const el = document.getElementById('i'); el.style.width = el.style.height = size + 'px'; el.innerHTML = mascot('happy'); const s = el.querySelector('svg'); s.style.width = s.style.height = (size * (1 - 2 * pad)) + 'px'; }, [size, pad]);
    await (await p.$('#i')).screenshot({ path: __dirname + '/' + name });
  }
  await b.close();
  console.log('built', VERSION, fs.readdirSync(__dirname));
})();
