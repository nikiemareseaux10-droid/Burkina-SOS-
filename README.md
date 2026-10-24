# Burkina SOS 🇧🇫

> *Un seul geste, toute une nation à votre secours !*

Application mobile d’urgence (Flutter, Android) : accès rapide aux services de secours, partage de la position GPS et alerte des proches en un clic.

## Fonctionnalités

- **Bouton SOS** avec confirmation (évite les faux déclenchements)
- **Appels d’urgence** : Police 17, Gendarmerie 16, Sapeurs-pompiers 18, SAMU 15, CNVA 10-10
- **Ma position** : coordonnées GPS, partage (WhatsApp, SMS…) et lien Google Maps
- **Alerte au proche** : contacts de confiance enregistrés sur le téléphone, message d’assistance + position envoyés par SMS
- **Menu Plus** : avis de recherche (CNVA), contacts d’urgence, aide et conseils, à propos, confidentialité

## Contenu du projet

| Fichier | Rôle |
|---|---|
| `lib/main.dart` | Toute l’application (écrans et logique) |
| `pubspec.yaml` | Nom, version et dépendances |
| `.github/workflows/build-apk.yml` | Construit l’APK automatiquement sur GitHub |

Le dossier `android/` n’est pas inclus : il est généré automatiquement au moment de la construction.

## Obtenir l’APK (sans rien installer sur l’ordinateur)

1. Créez un compte gratuit sur [github.com](https://github.com).
2. Créez un **nouveau dépôt** (bouton « New »), vide.
3. Cliquez sur **Add file → Upload files** et envoyez **tout le contenu** de ce dossier, y compris le dossier caché `.github`. Validez avec **Commit changes**.
4. Ouvrez l’onglet **Actions**. Le workflow **Build APK** démarre tout seul (sinon : *Build APK → Run workflow*).
5. Attendez environ 8 minutes que la coche verte ✅ apparaisse.
6. Cliquez sur l’exécution terminée, puis téléchargez **burkina-sos-apk** en bas de la page.
7. Dézippez : vous obtenez `app-release.apk`.

## Installer l’APK sur un téléphone Android

1. Copiez `app-release.apk` sur le téléphone (WhatsApp, câble USB, Bluetooth…).
2. Ouvrez le fichier. Si Android le demande, autorisez **l’installation depuis cette source**.
3. Au premier lancement, **autorisez la localisation** : elle sert à partager votre position.

## Construire en local (option avancée)

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install) et Android Studio (SDK Android).

```bash
cp -r lib pubspec.yaml /tmp/            # sauvegarde par précaution
flutter create --org bf.burkinasos --project-name burkina_sos --platforms=android .
# remettez lib/ et pubspec.yaml s’ils ont été modifiés
```

Ajoutez ensuite dans `android/app/src/main/AndroidManifest.xml`, juste avant la balise `<application` :

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

Puis :

```bash
flutter pub get
flutter build apk --release
```

L’APK se trouve dans `build/app/outputs/flutter-apk/app-release.apk`.

## En cas de problème

- **Le build échoue sur GitHub** : ouvrez l’exécution en erreur ❌, copiez le message rouge et demandez de l’aide avec ce message.
- **« Application non installée »** : désinstallez une ancienne version, puis réinstallez.
- **Position indisponible** : activez le GPS et autorisez la localisation pour Burkina SOS dans les paramètres Android.
- **Le SMS ne part pas** : vérifiez qu’au moins un contact de confiance est enregistré (onglet *Proches*).

## Important

- **Vérifiez les numéros d’urgence** (en particulier le 10-10) auprès des sources officielles avant toute diffusion.
- L’application **ne remplace pas** les services officiels et n’est reliée à aucun d’eux.
- **Confidentialité** : les contacts restent sur l’appareil ; la position n’est envoyée que lorsque vous le décidez. Aucun serveur n’est utilisé.
- Cette version n’est **pas signée pour le Play Store** (APK de test et de diffusion directe).

## Prochaines étapes

1. Tester sur plusieurs téléphones Android
2. Ajouter les comptes et les photos/vidéos de signalement
3. Lancer une version bêta
