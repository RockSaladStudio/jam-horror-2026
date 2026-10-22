# Système de Monstre d'Horreur

Ce dossier contient tous les scripts nécessaires pour implémenter un système de monstre qui apparaît de manière innopinée lorsque le joueur lève son bandeau, avec un système de stress progressif.

## Fichiers inclus

1. **`stress_manager.gd`** (Autoload)
   - Gère le niveau de stress du joueur
   - Définit les seuils et intervalles de spawn
   - Calcule la taille et la distance des monstres basée sur le stress

2. **`monster_spawner.gd`**
   - Gère la logique de spawn des monstres
   - Vérifie les points de spawn dans le champ de vision
   - Contrôle le timing des apparitions

3. **`monster.gd`**
   - Script attachée à chaque monstre
   - Gère la durée de vie et le comportement

---

## 📋 INSTRUCTIONS DE SETUP COMPLET

### Étape 1: Configurer l'Autoload (StressManager)

1. Ouvre ton projet dans **Godot Engine 4.x**
2. Va dans **Project > Project Settings...**
3. Sélectionne l'onglet **AutoLoad**
4. Clique sur le dossier **`autoloads/`** (ou crée-le s'il n'existe pas)
5. Sélectionne le fichier **`stress_manager.gd`**
6. Clique sur **"Add"** ou **"Open"**
7. **IMPORTANT**: Dans la colonne **"Node Name"**, assure-toi que le nom est **`StressManager`** (sans les guillemets, majuscule importante)
8. Coche la case **"Enable"**
9. Clique sur **"Apply"** puis ferme la fenêtre

✅ **Le StressManager est maintenant un singleton accessible partout avec `StressManager`**

---

### Étape 2: Créer la scène du Monstre

1. Dans l'éditeur Godot, crée une nouvelle scène (**Scene > New Scene**)
2. Ajoute un nœud **`MeshInstance3D`** (ce sera ton monstre)
3. Assigne un mesh (par exemple, un simple **`BoxMesh3D`** pour tester)
4. Dans l'inspecteur, ajoute un **Material Override** avec une couleur effrayante (rouge, noir, etc.)
5. Sauvegarde cette scène sous **`res://scenes/monsters/monster.tscn`**
6. Attache le script **`monster.gd`** au nœud racine (MeshInstance3D)

> 💡 **Astuce**: Pour un vrai monstre, importe un modèle 3D (`.glb` ou `.fbx`) et utilise-le comme mesh.

---

### Étape 3: Créer le MonsterSpawner dans ta scène principale

1. Ouvre ta scène principale (celle où se trouve ton joueur)
2. Ajoute un nœud **`Node3D`** comme enfant de la racine
3. Renomme ce nœud en **`MonsterSpawner`**
4. Attache le script **`monster_spawner.gd`** à ce nœud

---

### Étape 4: Configurer le MonsterSpawner

Avec le **MonsterSpawner** sélectionné dans la scène :

#### Dans l'inspecteur, configure les propriétés :

| Propriété | Valeur | Description |
|-----------|--------|-------------|
| **`monster_scene`** | `res://scenes/monsters/monster.tscn` | La scène du monstre à spawner |
| **`camera`** | Glisse-dépose ta **Camera3D** du joueur | La caméra du joueur |
| **`blindfold`** | Glisse-dépose ton nœud **Blindfold** | Le bandeau du joueur |
| **`fov_angle`** | `0` (ou `45` pour restreindre) | Angle de FOV supplémentaire |
| **`monster_lifespan`** | `5.0` | Durée de vie des monstres en secondes |
| **`min_spawn_distance`** | `1.0` | Distance minimale de spawn |
| **`max_spawn_distance`** | `20.0` | Distance maximale de spawn (0 = illimitée) |

---

### Étape 5: Ajouter des Points de Spawn

1. Avec le **MonsterSpawner** sélectionné
2. Clique sur le bouton **"+"** (Add Child Node) ou fais **Ctrl+A**
3. Ajoute des nœuds **`Marker3D`** (ils apparaissent comme des icônes d'axe dans la scène)
4. **Déplace ces markers** dans ta scène aux endroits où tu veux que le monstre puisse apparaître
5. **Répète** pour ajouter plusieurs points de spawn (5-10 recommandé pour un bon effet)

> ✅ **Ces markers sont automatiquement détectés comme points de spawn par le script**

---

### Étape 6: Vérifier le Blindfold

Ton script **`blindfold.gd`** existant doit fonctionner correctement. Assure-toi que :
- Il est attaché à un **`MeshInstance3D`** (le bandeau)
- Il a bien la variable **`current_progress`** (0.0 = bandeau baissé, 1.0 = bandeau levé)
- Le joueur peut lever le bandeau avec **`ui_accept`** (ou modifier dans le script)

> ⚠️ **Si tu changes le nom de l'action ou la logique, mets à jour `monster_spawner.gd`**

---

## 🎮 CONFIGURATION OPTIONNELLE

### Personnaliser le StressManager

Dans **`stress_manager.gd`**, tu peux modifier :

```gdscript
# Taux d'augmentation du stress (par seconde)
stress_increase_rate = 2.0  # Plus rapide = stress monte plus vite

# Stress maximum
max_stress = 100.0

# Seuils de stress pour les intervalles de spawn
stress_thresholds = [0.0, 30.0, 60.0, 90.0]

# Intervalles de spawn (en secondes) - plus le stress est élevé, plus c'est fréquent
spawn_intervals = [4.0, 2.0, 1.0, 0.3]  # 4s, 2s, 1s, 0.3s

# Taille minimale et maximale du monstre
min_size_multiplier = 1.0
max_size_multiplier = 4.0  # 4x plus gros à stress max

# Distance - 1.0 = distance normale, 0.1 = très proche
min_distance_multiplier = 0.2  # Très proche à stress max
max_distance_multiplier = 1.0
```

### Personnaliser le Monster

Dans **`monster.gd`**, tu peux activer :

```gdscript
# Déplacement aléatoire
wander_speed = 1.0
wander_radius = 3.0

# Le monstre disparaît si le joueur baisse le bandeau
disappear_on_blindfold_down = true

# Durée de vie
lifespan = 8.0  # 8 secondes
```

---

## 🚀 TESTER LE SYSTÈME

### Préparation
1. Assure-toi que tous les scripts sont bien attachés
2. Vérifie que le **MonsterSpawner** a bien :
   - `monster_scene` assignée
   - `camera` assignée
   - `blindfold` assignée
   - Plusieurs **Marker3D** comme enfants

### Exécution
1. Lance la scène avec **F5**
2. **Appuie sur la touche `ui_accept`** (par défaut : **Entrée** ou **Espace**)
   - Le bandeau commence à se lever
   - Dès que `current_progress > 0`, le système vérifie les points de spawn
3. **Regarde dans la direction des markers** que tu as placés
   - Un monstre devrait apparaître après quelques secondes
   - Le stress augmente tant que le monstre est visible
4. **Continue à lever le bandeau**
   - Plus tu gardes le bandeau levé, plus le stress monte
   - Les monstres apparaissent plus fréquemment
   - Les monstres deviennent plus gros et apparaissent plus près

---

## 🔧 DÉPANNAGE

### Problème : Aucun monstre n'apparaît

1. **Vérifie `current_progress`** : Ajoute un `print(blindfold.current_progress)` dans `_process` de `monster_spawner.gd` pour voir s'il dépasse 0
2. **Vérifie les points de spawn** : Assure-toi qu'ils sont dans le champ de vision de la caméra
3. **Vérifie les collisions** : Si tu as des murs, assure-toi que le raycast les détecte bien
4. **Vérifie la scène du monstre** : Assure-toi que `monster_scene` est bien assignée

### Problème : Le stress ne monte pas

1. Vérifie que `StressManager` est bien un Autoload
2. Vérifie que `StressManager.camera` est assignée (elle est set automatiquement par le spawner)
3. Ajoute un `print(StressManager.stress)` dans `_process` de `monster_spawner.gd`

### Problème : Les monstres sont trop petits/loin

1. Ajuste `min_size_multiplier` et `max_size_multiplier` dans `stress_manager.gd`
2. Ajuste `min_distance_multiplier` et `max_distance_multiplier`

---

## 🎯 BONNES PRATIQUES

### Placement des Points de Spawn
- Place-les **dans des coins sombres** ou des endroits inattendus
- Évite les endroits trop évidents
- Utilise **5-15 points** pour un bon équilibre
- Varie les distances (certains proches, certains loin)

### Réglage du Stress
- `stress_increase_rate = 1.0` : Montée progressive (recommandé pour l'horreur)
- `stress_increase_rate = 2.0-3.0` : Montée rapide (plus intense)
- Ajuste les `spawn_intervals` pour contrôler la fréquence

### Effets visuels
- Ajoute une **particle system** au monstre pour un effet effrayant
- Utilise un **shader** pour le rendre flou ou déformé
- Ajoute un **son** quand il apparaît (`AudioStreamPlayer3D`)

---

## 📊 Système de Stress Expliqué

```
Stress: 0-25   → Spawn toutes les 5 secondes → Monstre: taille normale, distance normale
Stress: 25-50  → Spawn toutes les 3 secondes → Monstre: 1.5x taille, 80% distance
Stress: 50-75  → Spawn toutes les 1 seconde  → Monstre: 2.0x taille, 50% distance
Stress: 75-100 → Spawn toutes les 0.5 seconde → Monstre: 3.0x taille, 30% distance
```

Le stress **n'augmente que lorsque le monstre est visible** et **ne descend jamais** (sauf reset manuel).

---

## 💡 SUGGESTIONS D'AMÉLIORATION

### 1. Réduction du Stress
Ajoute un système pour réduire le stress quand le joueur :
- Baisse complètement le bandeau pendant X secondes
- Trouve un objet spécial
- Passe dans une zone sûre

### 2. Sons Effrayants
Ajoute des sons qui :
- Jouent quand le stress monte
- Jouent quand un monstre apparaît
- Deviennent plus forts avec le stress

### 3. Visual Feedback
- Ajoute un effet de **vignette** qui s'intensifie avec le stress
- Fais **trembler l'écran** quand le stress est élevé
- Ajoute un **bruit visuel** (static) à haut stress

### 4. Comportement du Monstre
- Fais-le **suivre le joueur** lentement
- Fais-le **disparaître et réapparaître** aléatoirement
- Ajoute des **animations** (saut, attaque)

### 5. Système Probabiliste (Alternative)
Dans `stress_manager.gd`, tu peux utiliser `get_spawn_probability()` au lieu de `get_spawn_interval()` pour un spawn basé sur la chance plutôt que sur un intervalle fixe.

---

## 🎓 EXEMPLE DE MODIFICATION : Sons

Pour ajouter des sons au monstre :

1. Dans la scène `monster.tscn`, ajoute un nœud **`AudioStreamPlayer3D`**
2. Importe un son effrayant et assigne-le à **`Stream`**
3. Dans `monster.gd`, ajoute :

```gdscript
func _ready() -> void:
	$AudioStreamPlayer3D.play()
```

---

**✅ Tu es prêt à tester ! Lance ta scène et amuse-toi à effrayer tes joueurs.**
