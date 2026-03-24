#!/bin/bash
set -euo pipefail

# =============================================================================
# remove-pr-worktree.sh — Supprime proprement un worktree PR
#
# Usage : ./scripts/remove-pr-worktree.sh <nom-de-branche> [--delete-branch]
#   Ex. : ./scripts/remove-pr-worktree.sh feature/contour-plot
#   Ex. : ./scripts/remove-pr-worktree.sh feature/contour-plot --delete-branch
#
# Options :
#   --delete-branch, -D : Supprime aussi la branche locale après le worktree
# =============================================================================

# --- Vérification de l'argument ---
if [[ $# -lt 1 ]]; then
    echo "Usage : $0 <nom-de-branche|chemin-du-worktree> [--delete-branch|-D]"
    echo "  Ex. : $0 feature/contour-plot"
    echo "  Ex. : $0 feature/contour-plot --delete-branch"
    echo "  Ex. : $0 /chemin/vers/EasyFlowQ-pr-contour-plot"
    exit 1
fi

INPUT="$1"
DELETE_BRANCH=false

# --- Parsing des options ---
for arg in "$@"; do
    case "$arg" in
        --delete-branch|-D)
            DELETE_BRANCH=true
            ;;
    esac
done

# --- Détection de la racine du worktree principal ---
MAIN_WORKTREE="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_WORKTREE")"
PARENT_DIR="$(dirname "$MAIN_WORKTREE")"

# --- Résolution du chemin et du nom de branche ---
# L'utilisateur peut fournir soit un nom de branche, soit un chemin
if [[ -d "$INPUT" ]]; then
    # L'entrée est un chemin existant → on l'utilise directement
    WORKTREE_DIR="$(cd "$INPUT" && pwd)"
    # On récupère le nom de la branche depuis git
    BRANCH_NAME="$(git -C "$WORKTREE_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
else
    # L'entrée est un nom de branche → on calcule le chemin du worktree
    BRANCH_NAME="$INPUT"
    BRANCH_SUFFIX="${BRANCH_NAME##*/}"
    WORKTREE_DIR="${PARENT_DIR}/${REPO_NAME}-pr-${BRANCH_SUFFIX}"
fi

echo "→ Worktree à supprimer : $WORKTREE_DIR"
if [[ -n "$BRANCH_NAME" ]]; then
    echo "  Branche : $BRANCH_NAME"
fi

# --- Vérification que le worktree existe ---
if [[ ! -d "$WORKTREE_DIR" ]]; then
    echo "Erreur : le dossier $WORKTREE_DIR n'existe pas."
    echo "Worktrees actifs :"
    git worktree list
    exit 1
fi

# --- Vérification qu'on ne supprime pas le worktree principal ---
if [[ "$WORKTREE_DIR" == "$MAIN_WORKTREE" ]]; then
    echo "Erreur : impossible de supprimer le worktree principal !"
    exit 1
fi

# --- Suppression du worktree ---
echo "→ Suppression du worktree..."
git worktree remove "$WORKTREE_DIR" --force

echo "  ✓ Worktree supprimé : $WORKTREE_DIR"

# --- Nettoyage des métadonnées orphelines ---
git worktree prune

# --- Suppression optionnelle de la branche locale ---
if [[ "$DELETE_BRANCH" == true && -n "$BRANCH_NAME" ]]; then
    echo "→ Suppression de la branche locale '$BRANCH_NAME'..."
    # On utilise -d (pas -D) pour vérifier que la branche est mergée
    # Si la branche n'est pas mergée, git affichera un avertissement
    if git branch -d "$BRANCH_NAME" 2>/dev/null; then
        echo "  ✓ Branche '$BRANCH_NAME' supprimée"
    else
        echo "  ⚠ La branche '$BRANCH_NAME' n'est pas entièrement mergée."
        echo "    Utilisez 'git branch -D $BRANCH_NAME' pour forcer la suppression."
    fi
else
    if [[ -n "$BRANCH_NAME" ]]; then
        echo "  ℹ La branche '$BRANCH_NAME' a été conservée."
        echo "    Pour la supprimer : git branch -d $BRANCH_NAME"
    fi
fi

# --- Résumé ---
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Nettoyage terminé !"
echo ""
echo "  Worktree supprimé : $WORKTREE_DIR"
if [[ "$DELETE_BRANCH" == true && -n "$BRANCH_NAME" ]]; then
    echo "  Branche supprimée : $BRANCH_NAME"
fi
echo "════════════════════════════════════════════════════════════"
