# specs.md — EasyFlowQ Development Specification

## Development Mode: Test-Driven Development (TDD)

Tout developpement dans EasyFlowQ suit le cycle **TDD strict** :
une fonction a la fois, tests d'abord, commit atomique.

---

## Cycle de developpement

Pour **chaque fonction ou methode** a implementer :

### 1. RED — Ecrire les tests d'abord

- Ecrire **tous** les tests necessaires pour la fonction **avant** toute implementation
- Les tests doivent couvrir :
  - Cas nominal (happy path)
  - Cas limites (edge cases : valeurs vides, None, listes vides, 0 events)
  - Cas d'erreur (exceptions attendues, inputs invalides)
  - Interactions avec le systeme existant (si applicable)
- Executer les tests : ils doivent **tous echouer** (red)
- Si un test passe deja, c'est qu'il ne teste rien de nouveau — le revoir

### 2. GREEN — Implementer le minimum

- Ecrire le code **minimum** pour faire passer tous les tests
- Pas d'optimisation, pas de refactoring, pas de features supplementaires
- Executer les tests : ils doivent **tous passer** (green)
- Si un test echoue, corriger l'implementation (pas le test, sauf bug dans le test)

### 3. REFACTOR — Ameliorer le code

- Refactorer le code **sans changer le comportement**
- Verifier que tous les tests passent toujours
- Appliquer les conventions du projet (voir CLAUDE.md)

### 4. COMMIT — Commit atomique

- Un commit par fonction implementee
- Format Conventional Commits : `feat(scope): description`
- Le commit ne contient **que** les fichiers lies a cette fonction :
  - Le fichier source modifie
  - Le fichier test correspondant
  - Les fichiers de support si necessaire (fixtures, conftest)

---

## Regles strictes

### Granularite

- **UNE** fonction/methode par cycle TDD
- Ne jamais implementer 2 fonctions avant de commiter
- Si une fonction est trop grosse, la decomposer en sous-fonctions testables

### Ordre des operations

```
1. Lire/comprendre la spec de la fonction
2. Ecrire les tests          → git status (rien de stage)
3. Verifier RED               → pytest test/test_<module>.py -v (echecs attendus)
4. Implementer                 → code minimum
5. Verifier GREEN              → pytest test/test_<module>.py -v (tout passe)
6. Refactorer si necessaire    → pytest test/ -v (regression check)
7. Commiter                    → git add <fichiers> && git commit
```

### Pas de raccourcis

- **JAMAIS** ecrire l'implementation avant les tests
- **JAMAIS** commiter du code sans tests qui passent
- **JAMAIS** regrouper plusieurs fonctions dans un seul commit
- **JAMAIS** modifier un test pour qu'il passe sans corriger le code

---

## Conventions de test EasyFlowQ

### Organisation des fichiers

```
test/
├── conftest.py              # Fixtures partagees (fcs_data, qtbot setup)
├── test_dataIO.py           # Tests pour backend/dataIO.py
├── test_gates.py            # Tests pour backend/gates.py
├── test_plotWidgets.py      # Tests pour backend/plotWidgets.py
├── test_qtModels.py         # Tests pour backend/qtModels.py
├── test_comp.py             # Tests pour backend/comp.py
├── test_efio.py             # Tests pour backend/efio.py
├── test_window_Main.py      # Tests pour window_Main.py
├── test_window_Settings.py  # Tests pour window_Settings.py
└── test_window_Stats.py     # Tests pour window_Stats.py
```

Nommage : `test_<module>.py` miroir de `src/EasyFlowQ/<module>.py`

### Patterns de test

#### Tests unitaires (fonctions pures, backend)

```python
import pytest
import numpy as np

def test_functionName_nominal():
    """Cas nominal avec entree valide."""
    result = functionName(valid_input)
    assert result == expected

def test_functionName_empty_input():
    """Cas limite : entree vide."""
    result = functionName([])
    assert result is None

def test_functionName_invalid_raises():
    """Cas erreur : leve ValueError sur input invalide."""
    with pytest.raises(ValueError, match="message attendu"):
        functionName(invalid_input)
```

#### Tests Qt (widgets, fenetres)

```python
def test_widgetBehavior(qtbot):
    """Test d'un widget PySide6 avec qtbot."""
    widget = MyWidget()
    qtbot.addWidget(widget)
    widget.show()

    assert widget.isVisible()
    # Interagir et verifier
    qtbot.mouseClick(widget.button, Qt.LeftButton)
    assert widget.state == expected_state
```

#### Fixtures

```python
@pytest.fixture
def fcs_data():
    """Charge un fichier FCS de demo."""
    from src.EasyFlowQ.backend.dataIO import FCSData_ef
    return FCSData_ef('./demo_sample/01-Well-A1.fcs')

@pytest.fixture
def sample_gate():
    """Cree un gate polygonal de test."""
    from src.EasyFlowQ.backend.gates import polygonGate
    return polygonGate(vertices=[(0,0), (1,0), (1,1), (0,1)], channels=('FSC-A', 'SSC-A'))
```

### Assertions

- Egalite standard : `assert x == y`
- Numerique (numpy) : `np.testing.assert_array_equal(a, b)` ou `assert_allclose(a, b, rtol=1e-5)`
- Exceptions : `pytest.raises(ExceptionType, match="pattern")`
- Warnings : `pytest.warns(WarningType)`
- Qt visibility : `assert widget.isVisible()`

### Execution

```bash
# Tests d'un seul module (pendant le cycle TDD)
python -m pytest test/test_<module>.py -v

# Tous les tests (avant commit, regression check)
python -m pytest test/ -v

# Un seul test specifique
python -m pytest test/test_<module>.py::test_functionName -v
```

---

## Checklist pre-commit

Avant chaque commit, verifier :

- [ ] Tous les tests de la fonction passent (`pytest -v`)
- [ ] Aucune regression sur les autres tests (`pytest test/ -v`)
- [ ] Le code respecte les conventions (camelCase, PySide6, pas de PyQt6)
- [ ] Pas de fichiers non lies dans le staging area
- [ ] Message de commit au format Conventional Commits
- [ ] Un seul cycle TDD par commit (une fonction)

---

## Contraintes specifiques EasyFlowQ

- **Qt headless** : les tests tournent avec `QT_QPA_PLATFORM=offscreen`
- **Demo data** : utiliser les fichiers dans `./demo_sample/` pour les fixtures
- **FlowCal** : ne jamais modifier `src/EasyFlowQ/FlowCal/` — mocker si besoin
- **Settings** : utiliser `localSettings(testMode=True)` pour isoler les tests
- **Backward compat** : tout changement de `efio.py` doit inclure un test de chargement des anciens `.eflq`

---

## Contribution Upstream : Regles supplementaires

Toute fonctionnalite developpee ici a vocation a etre soumise au depot officiel
`https://github.com/ym3141/EasyFlowQ` sous forme de Pull Request.

### Contraintes supplementaires pour les contributions

- **Langue du code** : commentaires, docstrings et messages de commit en **anglais**
  (meme si on discute en francais en interne)
- **Atomicite renforcee** : chaque PR ne doit porter qu'une seule fonctionnalite
  independante — ne pas grouper plusieurs ameliorations dans une meme PR
- **Pas de dependances nouvelles** sauf accord explicite du mainteneur
  (`pyproject.toml` ne doit pas changer sans discussion GitHub Issue)
- **Regression zero** : la suite de tests existante (`test/`) doit passer
  entierement avant toute soumission
- **Tests obligatoires** : une fonctionnalite sans test ne sera pas soumise

### Checklist supplementaire pre-Pull Request

En plus de la checklist pre-commit, avant d'ouvrir une PR sur GitHub :

- [ ] Un GitHub Issue a ete ouvert pour discuter la fonctionnalite (si architectural)
- [ ] Les tests existants passent tous (`python -m pytest test/ -v`)
- [ ] La description de la PR inclut : objectif, usage, plan de test manuel
- [ ] La compatibilite `.eflq` est preservee (test de chargement inclus si efio.py touche)
- [ ] `FlowCal/` n'a pas ete modifie
- [ ] Aucune nouvelle dependance ajoutee sans accord
- [ ] Les messages de commit sont en anglais, format Conventional Commits

### Cycle complet avec contribution upstream

```
LOCAL (nous)                          UPSTREAM (ym3141/EasyFlowQ)
-----------                           -----------------------
1. GitHub Issue                  →    Mainteneur confirme l'interet
2. feature/xxx branch
3. TDD: tests → code → commit
4. pytest test/ (zero regression)
5. Push feature branch
6. Pull Request                  →    Mainteneur relit
7. Corrections si demandees
8. Merge                         →    Fonctionnalite integree officiellement
```
