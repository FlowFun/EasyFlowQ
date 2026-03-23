# ADR-001: Upstream Contribution Strategy

**Statut**: Accepte
**Date**: 2026-03-23
**Decideurs**: Equipe FlowFun & Claude Code

---

## Contexte et Probleme

EasyFlowQ est un logiciel open-source publie sous licence MIT sur GitHub
(`https://github.com/ym3141/EasyFlowQ`, auteur : Yitong Ma, publication
PLoS One 2024, DOI: 10.1371/journal.pone.0308873).

Notre equipe souhaite developper de nouvelles fonctionnalites inspirees de
Kaluza (Beckman Coulter), detaillees dans `PLAN_GUI_KALUZA.md`. La question
est : comment organiser ce travail pour que les developpements puissent etre
partages avec l'equipe originale et integres dans le projet officiel ?

Deux risques principaux :
1. Developper en vase clos → code incompatible, impossible a merger
2. Soumettre un gros refactoring → trop complexe a relire, refuse par le mainteneur

## Decision

Tous les developpements suivent une **strategie de contribution incrementale
et compatible avec l'upstream**, en trois principes :

### Principe 1 : Issue avant code (pour les changements architecturaux)

Avant de coder toute fonctionnalite qui modifie l'architecture existante
(systeme de gates, format de session, fenetre principale), ouvrir un GitHub
Issue sur `ym3141/EasyFlowQ` pour presenter l'idee et recueillir l'avis du
mainteneur. On ne code pas quelque chose que le mainteneur n'acceptera pas.

### Principe 2 : Contribution atomique

Chaque Pull Request sur l'upstream ne porte qu'**une seule fonctionnalite
independante**. Ordre de priorite etabli dans `CLAUDE.md` :

1. Contour plot (self-contained, aucun risque de regression)
2. Overlay plot (extension naturelle du systeme existant)
3. Menu contextuel sur les plots (QMenu, non-destructif)
4. Hierarchie de gates (discussion Issue d'abord obligatoire)
5. Systeme de protocoles (discussion Issue d'abord obligatoire)
6. Workspace multi-plots (refactor majeur, accord upstream obligatoire)

### Principe 3 : Compatibilite non-negociable

Les contraintes suivantes ne peuvent jamais etre violees dans une contribution :
- Les sessions `.eflq` existantes doivent rester chargeables
- `FlowCal/` (bibliotheque externe) ne doit pas etre modifie
- Aucune nouvelle dependance sans accord explicite du mainteneur
- Tous les tests existants (`test/`) doivent passer

- **Perimetre** : tout developpement dans ce depot
- **Regle formelle** : avant toute soumission PR, la checklist dans `specs.md`
  (section "Contribution Upstream") doit etre completee

## Validation (Definition of Done)

- [ ] CLAUDE.md contient la section "Contribution Strategy" avec le workflow complet
- [ ] specs.md contient la checklist pre-Pull Request
- [ ] Chaque nouvelle fonctionnalite est dans une branche `feature/<nom>` independante
- [ ] La premiere contribution (contour plot) est soumise comme PR sur ym3141/EasyFlowQ

---

## Consequences

### Avantages (+)

- Le travail de l'equipe profite a toute la communaute EasyFlowQ
- Le code reste maintenu sur le long terme (pas un fork abandonne)
- La revue du mainteneur ameliore la qualite du code
- Les futures versions d'EasyFlowQ incluront nos ameliorations
- Visibilite scientifique pour l'equipe (contribution citee)

### Inconvenients & Risques (-)

- Delai supplementaire : il faut attendre la validation du mainteneur
  - **Attenuation** : commencer par des fonctionnalites autonomes (contour plot)
    qui ne necessitent pas de discussion prealable
- Risque de refus par le mainteneur pour certaines fonctionnalites majeures
  - **Attenuation** : ouvrir un Issue avant de coder les changements architecturaux
- Le mainteneur peut ne pas repondre rapidement
  - **Attenuation** : on continue le travail local ; la PR reste ouverte

---

## Alternatives Considerees

1. **Fork prive sans contribution** : developper EasyFlowQ en interne sans
   partager. Rejete car cela cree un fork mort qui diverge du projet officiel
   et n'est pas maintenu.

2. **Refactoring complet en une seule PR** : soumettre tout le plan Kaluza
   en une fois. Rejete car une PR de 5000+ lignes ne sera jamais acceptee
   par un mainteneur solo.

3. **Creer un nouveau projet independant** : partir d'EasyFlowQ comme base
   et creer un nouveau logiciel. Rejete car cela duplique l'effort de
   maintenance et fragmente la communaute.

---

## Notes d'Implementation

**Fichiers cles** :
- `CLAUDE.md` — section "Contribution Strategy: Contributing Back to Upstream"
- `specs.md` — section "Contribution Upstream : Regles supplementaires"
- `PLAN_GUI_KALUZA.md` — plan detaille des fonctionnalites a contribuer

**Dépôt upstream** : `https://github.com/ym3141/EasyFlowQ`

**Vigilance** : ne jamais pousser directement sur le depot upstream sans PR.
Toujours passer par le mecanisme de Pull Request pour permettre la revue.

---

**Reversibilite** : NON — cette decision definit la philosophie de travail
de l'equipe. Elle peut etre amendee par une nouvelle ADR si le contexte change
(ex: le mainteneur abandonne le projet, ou notre equipe en devient co-mainteneur).
