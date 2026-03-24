#!/bin/bash
set -euo pipefail

# =============================================================================
# new-pr-worktree.sh — Crée un worktree git pour préparer une PR upstream propre
#
# Usage : ./scripts/new-pr-worktree.sh <nom-de-branche>
#   Ex. : ./scripts/new-pr-worktree.sh feature/contour-plot
#
# Ce script :
#   1. Détecte la branche par défaut d'upstream automatiquement
#   2. Crée un worktree dans un dossier frère du repo principal
#   3. Crée des symlinks vers les fichiers personnels (config Claude Code, etc.)
#   4. Exclut ces fichiers du suivi git via .git/info/exclude
# =============================================================================

# --- Fichiers personnels à symlinker dans chaque worktree PR ---
# Ces fichiers sont nécessaires pour Claude Code mais ne doivent JAMAIS
# apparaître dans une PR upstream. Ajouter ici tout nouveau fichier personnel.
PERSONAL_FILES=(".claude" "CLAUDE.md" "specs.md" "PLAN_GUI_KALUZA.md")

# --- Vérification de l'argument ---
if [[ $# -lt 1 ]]; then
    echo "Usage : $0 <nom-de-branche>"
    echo "  Ex. : $0 feature/contour-plot"
    exit 1
fi

BRANCH_NAME="$1"

# --- Détection de la racine du worktree principal ---
# git rev-parse --show-toplevel donne la racine du repo courant
MAIN_WORKTREE="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_WORKTREE")"
PARENT_DIR="$(dirname "$MAIN_WORKTREE")"

echo "→ Worktree principal détecté : $MAIN_WORKTREE"

# --- Vérification que le remote 'upstream' existe ---
if ! git remote get-url upstream &>/dev/null; then
    echo "Erreur : le remote 'upstream' n'est pas configuré."
    echo "Ajoute-le avec :"
    echo "  git remote add upstream https://github.com/ym3141/EasyFlowQ.git"
    exit 1
fi

# --- Récupération des dernières modifications upstream ---
echo "→ Récupération des mises à jour depuis upstream..."
git fetch upstream

# --- Détection automatique de la branche par défaut d'upstream ---
# On utilise 'git remote show upstream' pour trouver la HEAD branch
# Cela rend le script robuste si upstream change sa branche par défaut
UPSTREAM_DEFAULT=$(git remote show upstream | grep 'HEAD branch' | awk '{print $NF}')
echo "→ Branche par défaut d'upstream détectée : $UPSTREAM_DEFAULT"

# --- Construction du nom du dossier worktree ---
# On extrait le suffixe après le dernier '/' du nom de branche
# feature/contour-plot → contour-plot
BRANCH_SUFFIX="${BRANCH_NAME##*/}"
WORKTREE_DIR="${PARENT_DIR}/${REPO_NAME}-pr-${BRANCH_SUFFIX}"

# --- Vérification que le worktree n'existe pas déjà ---
if [[ -d "$WORKTREE_DIR" ]]; then
    echo "Erreur : le dossier $WORKTREE_DIR existe déjà."
    echo "Supprime-le d'abord avec : ./scripts/remove-pr-worktree.sh $BRANCH_NAME"
    exit 1
fi

# --- Création du worktree ---
# La nouvelle branche est basée sur upstream/<branche-par-défaut>
echo "→ Création du worktree dans : $WORKTREE_DIR"
echo "  Branche : $BRANCH_NAME (basée sur upstream/$UPSTREAM_DEFAULT)"
git worktree add -b "$BRANCH_NAME" "$WORKTREE_DIR" "upstream/$UPSTREAM_DEFAULT"

# --- Création des symlinks vers les fichiers personnels ---
echo "→ Création des symlinks vers les fichiers personnels..."
for FILE in "${PERSONAL_FILES[@]}"; do
    SOURCE="${MAIN_WORKTREE}/${FILE}"
    TARGET="${WORKTREE_DIR}/${FILE}"

    if [[ -e "$SOURCE" || -L "$SOURCE" ]]; then
        # ln -sf : force l'écrasement si le lien existe déjà
        ln -sf "$SOURCE" "$TARGET"
        echo "  ✓ $FILE → $SOURCE"
    else
        echo "  ⚠ $FILE n'existe pas dans le worktree principal, symlink ignoré"
    fi
done

# --- Exclusion des fichiers personnels du suivi git ---
# On utilise .git/info/exclude plutôt que .gitignore pour que
# ces exclusions restent purement locales (jamais commitées)
#
# IMPORTANT : git lit info/exclude depuis le répertoire git COMMUN (git-common-dir),
# pas depuis le répertoire per-worktree. On écrit donc dans le .git/info/exclude partagé.
# Cela n'affecte PAS les fichiers déjà trackés sur main (gitignore ne s'applique
# qu'aux fichiers non trackés).
echo "→ Ajout des exclusions dans .git/info/exclude (répertoire commun)..."

GIT_COMMON_DIR="$(git -C "$WORKTREE_DIR" rev-parse --git-common-dir)"

# S'assurer que le dossier info/ existe
mkdir -p "${GIT_COMMON_DIR}/info"
EXCLUDE_FILE="${GIT_COMMON_DIR}/info/exclude"

# Créer le fichier exclude s'il n'existe pas
touch "$EXCLUDE_FILE"

for FILE in "${PERSONAL_FILES[@]}"; do
    # grep -qxF : cherche une ligne exacte (-x) en mode fixe (-F), silencieux (-q)
    # On n'ajoute que si la ligne n'est pas déjà présente (évite les doublons)
    if ! grep -qxF "$FILE" "$EXCLUDE_FILE"; then
        echo "$FILE" >> "$EXCLUDE_FILE"
        echo "  ✓ $FILE ajouté à l'exclusion"
    else
        echo "  · $FILE déjà exclu"
    fi
done

# --- Message de confirmation ---
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Worktree PR créé avec succès !"
echo ""
echo "  Dossier  : $WORKTREE_DIR"
echo "  Branche  : $BRANCH_NAME"
echo "  Base     : upstream/$UPSTREAM_DEFAULT"
echo ""
echo "  Pour commencer à travailler :"
echo "    cd $WORKTREE_DIR"
echo "    claude  # ← Claude Code verra .claude/ et CLAUDE.md via les symlinks"
echo ""
echo "  Les fichiers personnels sont symlinkés et exclus du suivi git."
echo "  Tout commit/push depuis ce worktree sera propre pour la PR upstream."
echo "════════════════════════════════════════════════════════════"
