# Guide d'installation automatique de Whisper

## Comment fonctionne l'installation automatique

L'application **NoText** est maintenant équipée d'un système d'installation automatique qui fonctionne ainsi :

### 1. Vérification au démarrage

Dès que vous lancez l'application pour la première fois :
- L'application vérifie si la commande `whisper` est disponible
- Elle met en cache le résultat pour les lancements suivants
- Un indicateur visuel (vert/orange) montre le statut

### 2. Invite d'installation

Si Whisper n'est pas détecté :
- Une alerte apparaît automatiquement
- Elle explique ce qui va être installé
- Deux options : **Annuler** ou **Installer maintenant**

### 3. Processus d'installation

Quand vous cliquez sur "Installer maintenant" :
1. **Vérification de pip** : L'app vérifie que pip est disponible
2. **Installation** : Exécution de `pip install openai-whisper`
3. **Vérification** : Confirme que Whisper est bien installé
4. **Activation** : Le bouton d'enregistrement devient disponible

### 4. Indicateur de statut

Dans le coin supérieur gauche de l'interface :
- 🟢 **Point vert** : "Whisper installé" - Tout est prêt
- 🟠 **Point orange** : "Installation nécessaire" - Cliquez sur Installer

## Que se passe-t-il en arrière-plan ?

L'application exécute ces commandes automatiquement :

```bash
# Étape 1 : Vérifier si Whisper est présent
which whisper

# Étape 2 : Installer Whisper via pip
pip3 install openai-whisper

# Étape 3 : Vérifier l'installation
which whisper
```

## Requirements système

Pour que l'installation automatique fonctionne :
- **Python 3.8+** doit être installé (livré avec macOS)
- **pip** doit être disponible
- **Connexion internet** pour le téléchargement
- **Espace disque** : ~2-3 GB pour le modèle de base

## Dépannage

### L'installation échoue ?

1. **Vérifiez pip** :
   ```bash
   pip3 --version
   ```

2. **Si pip n'est pas là**, installez-le :
   ```bash
   python3 -m ensurepip --upgrade
   ```

3. **Réessayez l'installation** dans l'app

### L'installation réussie mais Whisper ne fonctionne pas ?

1. Redémarrez l'application
2. L'application re-vérifiera automatiquement l'installation

### Installation manuelle de secours

Si l'installation automatique ne fonctionne pas :

```bash
# Ouvrez Terminal et exécutez :
pip3 install openai-whisper

# Vérifiez :
whisper --help
```

## Premiers pas après l'installation

Une fois Whisper installé :
1. Le bouton **Enregistrer** devient actif
2. Cliquez dessus pour démarrer l'enregistrement
3. Parlez clairement
4. Cliquez sur **Arrêter**
5. La transcription apparaît automatiquement
6. Utilisez **Reformuler** pour optimiser le texte

## Notes

- **Première installation** : Peut prendre 2-5 minutes selon votre connexion
- **Modèle Whisper** : Le modèle "base" est téléchargé automatiquement (~140 MB)
- **Mises à jour** : L'application ne réinstallera pas Whisper si déjà présent
- **Stockage** : Le statut d'installation est sauvegardé entre les lancements

---

**Profitons de la transcription vocale locale ! 🎤✨**
