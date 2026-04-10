# NoText : Votre Assistant Vocal Local 100% Privé 🤫🎙

**NoText** est une utilité macOS révolutionnaire qui transforme votre voix en prompts structurés et professionnels, sans jamais envoyer la moindre donnée dans le cloud. C'est l'alternative **Open Source, locale et gratuite** aux solutions comme Whisper Flow ou MacWhisper.

---

## 🌟 Pourquoi NoText ?

À l'heure où tout passe par le Cloud, NoText fait le pari de l'**Indépendance** et de la **Vitesse**.

*   **⚡️ 100% Local** : Tout est traité sur votre Mac (Silicon) grâce à la puissance de **MLX** (Apple) et du modèle **Gemma 2B** (Google). Pas de serveurs, pas de latence, pas de frais d'API.
*   **🛡 Confidentialité Totale** : Vos paroles, vos idées et vos secrets de fabrication restent sur votre disque dur. Rien ne sort. Jamais.
*   **🚀 Push-To-Talk Global** : Maintenez la touche **Option (⌥)** dans n'importe quelle application (Slack, Chrome, VS Code) pour parler. Relâchez, et NoText tape automatiquement le résultat optimisé pour vous.

---

## ✨ Fonctionnalités "Ultimate"

*   **🪄 Reformulation Intelligente** : Ne vous contentez pas de transcrire. NoText transforme vos balbutiements vocaux en prompts parfaits (Direct, Formel, Créatif ou Code)..
*   **🌍 Traduction Instantanée** : Dictez en français, générez en anglais (ou inversement). Parfait pour solliciter les LLM globaux avec précision.
*   **📑 Historique Persistant** : Retrouvez vos 50 dernières transcriptions localement si vous oubliez de les coller.
*   **🖱 Drag & Drop** : Glissez n'importe quel fichier audio (`.mp3`, `.m4a`, etc.) pour le transformer en prompt instantanément.
*   **🎹 Auto-Paste** : L'app tape directement à la place de votre curseur une fois la génération terminée.
*   **🎧 Retours Sensoriels** : Retours haptiques sur Trackpad et sons système discrets pour une utilisation "à l'aveugle".

---

## 🏗 Technologie par evecorp

NoText exploite le meilleur de l'écosystème Apple & AI :
*   **Langage** : Swift / SwiftUI (Interface native pure).
*   **Moteur Audio** : native Speech SDK pour la reconnaissance temps réel.
*   **Inférence IA** : `mlx-lm` pour une vitesse d'exécution record sur puce M1/M2/M3/M4.
*   **Modèle** : Google Gemma 2B Instruct (Quantifié).

---

## 📥 Installation

1.  Téléchargez `NoText_v1.0.0.zip` depuis la [page des Releases](https://github.com/EVELETTE/NoText/releases).
2.  Décompressez l'archive et déplacez `notext.app` dans votre dossier `/Applications`.
3.  **⚠️ Note de Sécurité (Gatekeeper)** : Étant un projet Open Source non-signé par Apple, macOS peut afficher "App endommagée". Pour corriger cela, lancez cette commande dans le Terminal :
    ```bash
    xattr -d com.apple.quarantine /Applications/notext.app
    ```
4.  Lancez NoText et suivez le guide d'onboarding.

---

## 🛠 Technologie par evecorp

NoText exploite le meilleur de l'écosystème Apple :
*   **Interface** : SwiftUI Native.
*   **Inférence** : Apple MLX Framework.
*   **Modèle** : Gemma 2B Instruct (Google).

---

## ❤️ Soutenir le projet

NoText est un logiciel Open Source mis à disposition par **evecorp**. Si cet outil vous est utile, vous pouvez soutenir le projet ici :

👉 **[M'offrir un café via Revolut](https://checkout.revolut.com/pay/3416e235-8967-497a-8353-3ab929cf35a1)** ☕️

---

### Licence
Distribué sous licence MIT. Libre, gratuit, transparent. 

**By evecorp.**
