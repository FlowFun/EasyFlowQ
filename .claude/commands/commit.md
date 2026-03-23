---
name: commit
description: Stage et commit tous les changements avec un message genere par IA
disable-model-invocation: true
allowed-tools:
  - Task
---

# /commit - Stage et commit automatique

Lance le subagent `commit-writer` qui :
- Analyse les changements
- Stage tous les fichiers modifies
- Genere un message de commit conforme
- Cree le commit

Utilise le modele Haiku pour economiser les tokens.

**Usage** : `/commit`
