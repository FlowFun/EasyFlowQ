# Architecture Decision Records (ADR)

Ce repertoire contient les decisions architecturales du projet EasyFlowQ,
documentees au format [MADR](https://adr.github.io/madr/).

## Index

| Numero | Titre | Statut | Date |
|---|---|---|---|
| [ADR-001](ADR-001-upstream-contribution-strategy.md) | Strategie de contribution upstream | Accepte | 2026-03-23 |

## Comment lire un ADR

Chaque ADR decrit :
- Le **contexte** et le probleme a resoudre
- La **decision** retenue et ses regles
- Les **consequences** (avantages et risques)
- Les **alternatives** qui ont ete considerees

## Creer un nouvel ADR

Utiliser la commande `/adr-create` dans Claude Code, ou suivre le template
dans `.claude/skills/adr-create/references/template.md`.

Convention de nommage : `ADR-{NNN}-{slug-en-minuscules}.md`
