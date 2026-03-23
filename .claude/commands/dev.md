---
name: dev
description: Implemente une fonction en TDD strict (tests → code → commit)
allowed-tools:
  - Task
---

# /dev — Developpement TDD

Lance le subagent `tdd-dev` qui implemente une fonction en suivant le cycle TDD strict defini dans `specs.md` :

1. **RED** — Ecrit les tests (nominal + edge + error), verifie qu'ils echouent
2. **GREEN** — Implemente le minimum pour faire passer les tests
3. **REFACTOR** — Ameliore sans changer le comportement
4. **COMMIT** — Commit atomique (une fonction = un commit)

**Usage** : `/dev <description de la fonction a implementer>`

**Exemples** :
- `/dev ajouter methode applyGate() dans backend/gates.py qui filtre les events selon un polygone`
- `/dev ajouter export CSV dans backend/efio.py`
