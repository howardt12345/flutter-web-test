'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/assets\AssetManifest.json": "71718671904bd2133b3357d98a06f35e",
"/assets\FontManifest.json": "3c3c8da0568ead68342045b700890a1d",
"/assets\fonts\CustomIcons.ttf": "da2aceb29304c231464cbc0f8be55aed",
"/assets\fonts\MaterialIcons-Regular.ttf": "a37b0c01c0baf1888ca812cc0508f6e2",
"/assets\fonts\Roboto-Black.ttf": "5ebb24ee1112dd9562629375c387879a",
"/assets\fonts\Roboto-Bold.ttf": "e07df86cef2e721115583d61d1fb68a6",
"/assets\fonts\Roboto-Light.ttf": "88823c2015ffd5fa89d567e17297a137",
"/assets\fonts\Roboto-Medium.ttf": "58aef543c97bbaf6a9896e8484456d98",
"/assets\fonts\Roboto-Regular.ttf": "11eabca2251325cfc5589c9c6fb57b46",
"/assets\fonts\Roboto-Thin.ttf": "321de678e592d0b8f44f1a82d7ca4b62",
"/assets\images\logo.png": "cacba03daf6fe358c7e01e73786df5aa",
"/assets\images\logo_dark.png": "83389e1f7d9bc28555183cadf47d4cf5",
"/assets\LICENSE": "5827ed8d42164badac3650327ea26d9b",
"/assets\packages\cupertino_icons\assets\CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets\packages\font_awesome_flutter\lib\fonts\fa-brands-400.ttf": "3ca122272cfac33efb09d0717efde2fa",
"/assets\packages\font_awesome_flutter\lib\fonts\fa-regular-400.ttf": "bdd8d75eb9e6832ccd3117e06c51f0d3",
"/assets\packages\font_awesome_flutter\lib\fonts\fa-solid-900.ttf": "d21f791b837673851dd14f7c132ef32e",
"/CNAME": "157a03bf8376e1b9a8b95d92e3575b90",
"/index.html": "8f6587095aea3aef8cde312fe72334d5",
"/main.dart.js": "6b82e9387b37a531141d5a0317e885b9",
"/main.dart.js.deps": "6bde31e5a54bc1d3dadd61905c8fe129"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request, {
          credentials: 'include'
        });
      })
  );
});
