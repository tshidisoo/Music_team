// Firebase Messaging Service Worker
// Required for firebase_messaging on Flutter Web

importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Your Firebase config will be injected at runtime by FlutterFire.
// This service worker handles background push notifications.
firebase.initializeApp(self.firebaseConfig || {});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title || 'Music Team';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});
