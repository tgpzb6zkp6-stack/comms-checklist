// ─────────────────────────────────────────────────────────────
//  Service Worker — Ad-hoc Comms Checklist PWA
//  Full offline support + background update detection
// ─────────────────────────────────────────────────────────────

const CACHE_NAME = "comms-checklist-v2";

const ASSETS = [
  "./",
  "./index.html",
  "./manifest.json",
  "./sw.js"
];

// ── Install ───────────────────────────────────────────────────
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())
  );
});

// ── Activate: clear old caches ────────────────────────────────
self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

// ── Fetch: cache-first, fallback to network ───────────────────
self.addEventListener("fetch", event => {
  if (event.request.method !== "GET") return;
  event.respondWith(
    caches.match(event.request).then(cached => {
      const networkFetch = fetch(event.request).then(response => {
        if (response && response.status === 200) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => null);
      return cached || networkFetch || caches.match("./index.html");
    })
  );
});

// ── Skip waiting on demand (for update banner) ────────────────
self.addEventListener("message", event => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});
