# Plan : Refonte de l'interface EasyFlowQ inspirée de Kaluza (Beckman Coulter)

## Contexte

EasyFlowQ (v1.7) est un logiciel open-source d'analyse de cytométrie en flux basé sur PySide6/Matplotlib. Son interface actuelle est peu intuitive : layout rigide en 3 colonnes (samples | plot + options | gates/figure options), pas de système de protocoles, pas de hiérarchie de gates, pas de menu contextuel radial, un seul plot visible à la fois, et des options de figure enterrées dans un panneau latéral.

**Kaluza** de Beckman Coulter est la référence en matière d'UX pour la cytométrie. Ses concepts clés sont :
- **Workspace multi-plots** avec sheets/onglets et zoom
- **Radial Menu** (clic droit contextuel)
- **Protocoles** réutilisables (gating strategy + plots + compensation)
- **Hiérarchie de gates** parent/enfant avec Gate Table
- **Auto-Layout** intelligent des plots
- **Batch processing** de fichiers multiples
- **Tree Plot / Radar Plot / Comparison Plot**
- **Boolean gating** (AND, OR, NOT)
- **Undo/Redo illimité**
- **Ribbon toolbar** pour création rapide de plots/gates

---

## Analyse comparative : EasyFlowQ vs Kaluza

| Fonctionnalité | EasyFlowQ actuel | Kaluza cible |
|---|---|---|
| Workspace | 1 seul plot, layout fixe | Multi-plots, drag & drop, zoom, sheets |
| Gating | Liste plate, polygon/line/quad/split | Hiérarchie parent/enfant, boolean, auto-gate |
| Protocoles | Session save/load (JSON) | Protocoles réutilisables, drag & drop sur fichiers |
| Menu contextuel | Aucun sur les plots | Radial menu contextuel |
| Types de plots | Dot, density, histogram | + Tree Plot, Radar Plot, Comparison Plot, Contour |
| Batch | Non | Oui, avec protocoles |
| Undo/Redo | Non | Illimité |
| Statistiques | Fenêtre séparée | Tables intégrées dans le workspace |
| Panneau fichiers | Tree simple | Analysis List avec protocoles et datasets |

---

## Modifications à effectuer

### Phase 1 : Restructuration du Layout Principal
**Fichiers impactés :** `MainWindow.ui`, `window_Main.py`, `uiDesigns/MainWindow_FigOptions.py`, `uiDesigns/MainWindow_SmplSect.py`

1. **Remplacer le layout fixe par des QDockWidgets**
   - Panneau gauche (Analysis List) : QDockWidget redimensionnable
   - Panneau droit (Propriétés/Attributs) : QDockWidget repliable
   - Zone centrale : Workspace multi-plots
   - Les panneaux peuvent être détachés, repositionnés, masqués

2. **Ribbon Toolbar** (remplacer la barre d'options actuelle)
   - Onglet "Home" : Types de plots (Dot, Density, Histogram, Contour), gates, compensation
   - Onglet "Analysis" : Statistiques, batch, export
   - Onglet "View" : Layout, zoom, sheets

3. **Workspace multi-plots** (zone centrale)
   - Remplacer le `plotBox` unique par un `QGraphicsScene`/`QGraphicsView` ou un `QMdiArea`
   - Chaque plot est un widget indépendant (drag, resize, close)
   - Système d'onglets/sheets (QTabWidget pour les sheets)
   - Auto-Layout : grille intelligente qui réorganise les plots

### Phase 2 : Système de Protocoles
**Nouveaux fichiers :** `backend/protocols.py`, `window_Protocol.py`

4. **Modèle de Protocole**
   ```
   Protocol:
     - name: str
     - plots: List[PlotConfig]  (type, channels, scales, gates)
     - gating_hierarchy: GateTree
     - compensation: CompMatrix
     - statistics: List[StatConfig]
     - layout: LayoutConfig
   ```
   - Sérialisation JSON (extension `.efqp`)
   - Extensible depuis le système `sessionSave` existant (`backend/efio.py`)

5. **Application de protocoles**
   - Drag & drop d'un protocole sur un fichier dans l'Analysis List
   - Matching automatique des paramètres par nom
   - Dialogue de mapping si les noms ne correspondent pas
   - Batch : appliquer un protocole à N fichiers

6. **Éditeur de protocoles**
   - Sauvegarder la stratégie de gating actuelle comme protocole
   - Modifier les plots/gates/stats d'un protocole
   - Bibliothèque de protocoles (répertoire utilisateur)

### Phase 3 : Hiérarchie de Gates
**Fichiers impactés :** `backend/gates.py`, `backend/qtModels.py`, `window_Main.py`

7. **GateTreeModel** (remplacer `gateListWidget` par `QTreeView`)
   - Chaque gate a un parent optionnel
   - Les enfants sont automatiquement gated sur le sous-ensemble du parent
   - Affichage hiérarchique (indentation parent/enfant)
   - Gate Statistics Table : affiche le % et count pour chaque gate dans la hiérarchie

8. **Boolean Gating**
   - Nouveau type : `BooleanGate(gates, operator)` avec AND, OR, NOT
   - Dialog de création de gates booléens
   - Affichage dans la hiérarchie avec logique visible

9. **Auto-gating** (optionnel, phase future)
   - Clustering automatique (k-means ou Gaussian Mixture)
   - Suggestion de gates basée sur les distributions

### Phase 4 : Radial Menu Contextuel
**Nouveaux fichiers :** `uiDesigns/RadialMenu.py`

10. **Menu radial sur les plots** (clic droit)
    - Options contextuelles selon le type de plot :
      - Changer type de plot
      - Ajouter/modifier gate
      - Changer échelle (Lin/Log/Logicle)
      - Modifier paramètres (axes)
      - Statistiques
      - Zoom / Auto-range
      - Exporter image
    - Implémentation : QWidget personnalisé avec QPainter (disposition circulaire)
    - Alternative pragmatique : QMenu stylisé avec icônes (plus simple, même UX)

### Phase 5 : Panneau Analysis List amélioré
**Fichiers impactés :** `uiDesigns/MainWindow_SmplSect.py`, `backend/qtModels.py`

11. **Analysis List enrichie**
    - Sections : Datasets, Protocoles, Composites
    - Icônes par type (fichier, protocole, composite)
    - Drag & drop de protocoles sur datasets
    - Multi-sélection pour batch
    - Attributes Pane : panneau détail du fichier sélectionné (paramètres, compensation, metadata)

### Phase 6 : Nouveaux types de plots
**Fichiers impactés :** `backend/plotWidgets.py`

12. **Contour Plot** : isolignes de densité (matplotlib `contour`/`contourf`)
13. **Overlay Plot** : superposition de plusieurs échantillons sur un même plot 2D
14. **Comparison Plot** (futur) : bar/line chart comparant une statistique entre populations
15. **Tree Plot** (futur) : visualisation combinatoire de phénotypes (complexe)

### Phase 7 : Fonctionnalités transversales

16. **Undo/Redo** : `QUndoStack` de Qt avec commandes pour chaque action
17. **Batch Processing** : fenêtre dédiée, sélection de fichiers + protocole, export automatique
18. **Statistiques intégrées** : table de stats dans le workspace (pas seulement fenêtre séparée)
19. **Amélioration cosmétique** : thème sombre optionnel, icônes modernes, fond noir des plots

---

## Architecture proposée

```
src/EasyFlowQ/
├── main.py
├── start.py
├── window_Main.py              # Refactoré : QMainWindow avec QDockWidgets + QMdiArea
├── window_Stats.py             # Intégrable comme widget dans le workspace
├── window_Settings.py
├── window_Comp.py
├── window_Protocol.py          # NOUVEAU : Éditeur/gestionnaire de protocoles
├── window_Batch.py             # NOUVEAU : Batch processing
├── backend/
│   ├── gates.py                # Étendu : GateNode (tree), BooleanGate
│   ├── gateTree.py             # NOUVEAU : Modèle hiérarchique de gates (QAbstractItemModel)
│   ├── plotWidgets.py          # Étendu : PlotWidget autonome (drag/resize), contour plot
│   ├── plotWorkspace.py        # NOUVEAU : QMdiArea/QGraphicsScene pour multi-plots
│   ├── protocols.py            # NOUVEAU : Protocol, ProtocolManager, sérialisation
│   ├── radialMenu.py           # NOUVEAU : Menu contextuel radial
│   ├── undoCommands.py         # NOUVEAU : QUndoCommand subclasses
│   ├── qtModels.py             # Étendu : AnalysisListModel (datasets + protocols)
│   ├── dataIO.py
│   ├── comp.py
│   ├── efio.py                 # Étendu : support protocoles
│   └── utils.py
├── uiDesigns/
│   ├── MainWindow.ui           # Refactoré : docks + mdi
│   ├── MainWindow_Ribbon.py    # NOUVEAU : Ribbon toolbar
│   ├── MainWindow_SmplSect.py  # Refactoré : Analysis List
│   ├── MainWindow_FigOptions.py # Intégré dans l'Attributes Pane
│   ├── ProtocolWindow.ui       # NOUVEAU
│   ├── BatchWindow.ui          # NOUVEAU
│   └── resource/
└── FlowCal/                    # Inchangé
```

### Diagramme d'architecture haut niveau

```
┌─────────────────────────────────────────────────────────────┐
│                     QMainWindow (mainUi)                     │
│  ┌──────────┐  ┌────────────────────────┐  ┌──────────────┐ │
│  │ DockLeft │  │   Central Workspace    │  │  DockRight   │ │
│  │          │  │                        │  │              │ │
│  │ Analysis │  │  ┌──────┐ ┌──────┐    │  │ Attributes   │ │
│  │ List     │  │  │Plot 1│ │Plot 2│    │  │ Pane         │ │
│  │          │  │  │      │ │      │    │  │ (context-    │ │
│  │ -Datasets│  │  └──────┘ └──────┘    │  │  sensitive)  │ │
│  │ -Protos  │  │  ┌──────┐ ┌──────┐    │  │              │ │
│  │ -Comps   │  │  │Plot 3│ │Stats │    │  │ Gate Tree    │ │
│  │          │  │  │      │ │Table │    │  │              │ │
│  │          │  │  └──────┘ └──────┘    │  │ Figure Opts  │ │
│  └──────────┘  │  [Sheet1][Sheet2]...  │  └──────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Ribbon Toolbar                            │ │
│  │  [Plots▼] [Gates▼] [Comp▼] [Stats] [Batch] [View▼]   │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Modèle de données pour les Protocoles

```python
# backend/protocols.py

class PlotConfig:
    plot_type: str          # "dot", "density", "histogram", "contour"
    x_channel: str
    y_channel: str | None
    x_scale: str            # "linear", "log", "logicle"
    y_scale: str
    input_gate: str | None  # UUID de la gate parente
    position: (int, int)    # Position dans la grille
    size: (int, int)

class GateNode:
    uuid: str
    name: str
    gate_type: str          # "polygon", "line", "quadrant", "boolean"
    gate_data: dict         # vertices, channels, operator...
    parent_uuid: str | None
    children: List[GateNode]

class Protocol:
    name: str
    version: str
    plots: List[PlotConfig]
    gate_tree: List[GateNode]  # Racines de la hiérarchie
    compensation: dict | None
    statistics: List[dict]
    channel_mapping: dict      # Mapping attendu des canaux

    def save(self, path): ...
    def load(cls, path) -> Protocol: ...
    def apply_to(self, dataset, channel_map=None): ...
    def is_compatible(self, dataset) -> bool: ...
```

### Modèle hiérarchique de Gates

```python
# backend/gateTree.py

class GateTreeModel(QAbstractItemModel):
    """Modèle Qt pour la hiérarchie de gates (remplace QListWidget)"""

    def __init__(self):
        self.root_gates: List[GateNode] = []

    # Standard Qt model methods: index, parent, rowCount, data, flags
    # + drag/drop pour réorganiser la hiérarchie

    def add_gate(self, gate, parent_gate=None): ...
    def remove_gate(self, gate_uuid): ...
    def get_gated_data(self, gate_uuid, fcs_data): ...
    def get_hierarchy_stats(self, fcs_data) -> DataFrame: ...
```

---

## Ordre de priorité recommandé

| Priorité | Phase | Impact UX | Effort |
|---|---|---|---|
| 1 | Phase 1 : Layout Docks + Multi-plots | Transformant | Élevé |
| 2 | Phase 3 : Hiérarchie de Gates | Majeur | Moyen |
| 3 | Phase 2 : Protocoles | Majeur | Moyen |
| 4 | Phase 4 : Radial Menu | Confort | Faible |
| 5 | Phase 5 : Analysis List | Modéré | Moyen |
| 6 | Phase 6 : Nouveaux plots | Enrichissement | Variable |
| 7 | Phase 7 : Undo/Batch/Cosmétique | Confort | Variable |

---

## Vérification

Pour chaque phase :
1. Lancer l'application avec `python main.py`
2. Charger un fichier FCS de test (disponible dans `test/`)
3. Vérifier que les fonctionnalités existantes ne sont pas cassées (regression)
4. Tester les nouvelles fonctionnalités (multi-plots, gates hiérarchiques, protocoles)
5. Vérifier la sauvegarde/chargement de session (compatibilité `.eflq`)
6. Tests unitaires existants dans `test/`

---

## Sources

- [Kaluza Analysis Software - Beckman Coulter](https://www.beckman.com/flow-cytometry/software/kaluza)
- [Kaluza Features](https://www.beckman.com/flow-cytometry/software/kaluza/features)
- [Kaluza Tree Plot](https://www.beckman.com/flow-cytometry/software/kaluza/learning-center/tree-plot)
- [Kaluza Statistics](https://www.mybeckman.pl/flow-cytometry/software/kaluza/learning-center/kaluza-statistic)
- [Kaluza Comparison Plot](https://www.beckman.com/flow-cytometry/software/kaluza/learning-center/comparison-plot)
- [Kaluza IFU (PDF)](https://qb3.berkeley.edu/wp-content/uploads/2020/07/Kaluza-Flow-Cytometry-Software-Guide-A75667AC.pdf)
