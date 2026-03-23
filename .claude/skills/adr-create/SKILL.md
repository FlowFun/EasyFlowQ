# Skill: adr-create

Genere une Architecture Decision Record (ADR) conforme au format MADR (Markdown Architecture Decision Records).

## Declencheurs

- L'utilisateur demande de creer/documenter une decision architecturale
- L'utilisateur mentionne "ADR", "decision record", "documenter une decision"
- Une discussion technique aboutit a une decision structurante

## Workflow

### Etape 1: Localiser le repertoire ADR

```bash
# Chercher le repertoire ADR existant
find . -type d -name "adr" -path "*/docs/*" 2>/dev/null | head -1
```

Si absent, proposer de creer `docs/adr/`.

### Etape 2: Determiner le prochain numero ADR

```bash
# Compter les ADRs existantes et incrementer
ls docs/adr/ADR-*.md 2>/dev/null | wc -l
```

Le prochain numero = count + 1, formate sur 3 chiffres (ex: `017` → `018`).

### Etape 3: Collecter les informations

Demander a l'utilisateur (si non fournies):
1. **Titre court** de la decision
2. **Contexte/Probleme** : Pourquoi cette decision est-elle necessaire ?
3. **Decision retenue** : Quelle solution est choisie ?
4. **Alternatives rejetees** : Qu'est-ce qui a ete considere et pourquoi rejete ?

### Etape 4: Generer le fichier ADR

Creer le fichier `docs/adr/ADR-{NNN}-{slug}.md` en utilisant le template dans `references/template.md`.

**Convention de nommage du slug**:
- Tout en minuscules
- Mots separes par des tirets
- Pas d'accents, pas de caracteres speciaux
- Exemple: `configuration-externalisee-yaml`

### Etape 5: Mettre a jour l'index (si existant)

Si `docs/adr/README.md` existe, proposer d'ajouter une ligne dans la section appropriee.

---

## Regles de Redaction

### Langue

Adapter a la langue du projet (francais ou anglais). Par defaut, suivre la langue des ADRs existantes.

### Style

- **Concis** : aller droit au but
- **Factuel** : eviter les opinions, se baser sur des preuves
- **Actionnable** : inclure des exemples de code quand pertinent

### Categorisation (si index existe)

| Categorie | Criteres |
|-----------|----------|
| **Critique** | Affecte validite des donnees, securite, conformite |
| **Majeure** | Affecte architecture globale, interoperabilite |
| **Standard** | Decision technique sans impact critique |

### Statuts

| Statut | Signification |
|--------|---------------|
| `Propose` | En discussion, peut etre modifiee |
| `Accepte` | Decision validee, implementation en cours ou terminee |
| `Obsolete` | Remplacee par une nouvelle ADR (necessite justification) |

---

## Slugification

| Titre original | Slug |
|----------------|------|
| Centralisation des Utilitaires | `centralisation-utilitaires` |
| Use PostgreSQL for Storage | `use-postgresql-for-storage` |
| API Versioning Strategy | `api-versioning-strategy` |

**Regles**:
1. Tout en minuscules
2. Espaces → tirets
3. Supprimer accents (e→e, a→a)
4. Supprimer articles courts si possible (de, the, a)
5. Garder mots-cles techniques

---

## Checklist avant validation

### Structure
- [ ] Numero ADR sequentiel correct (pas de doublon)
- [ ] Fichier nomme `ADR-{NNN}-{slug}.md`
- [ ] Toutes les sections obligatoires presentes
- [ ] Date au format `YYYY-MM-DD`

### Contenu
- [ ] Contexte explique le "pourquoi"
- [ ] Decision est claire et actionnable
- [ ] Au moins 2 alternatives considerees
- [ ] Consequences negatives identifiees avec mitigation

### Qualite
- [ ] Code syntaxiquement correct
- [ ] References verifiables

---

## References

- [MADR - Markdown Architecture Decision Records](https://adr.github.io/madr/)
- [ADR GitHub Repository](https://github.com/joelparkerhenderson/architecture-decision-record)
- [Documenting Architecture Decisions (Nygard)](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
