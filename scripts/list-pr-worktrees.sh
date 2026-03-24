#!/bin/bash
set -euo pipefail

# =============================================================================
# list-pr-worktrees.sh — Liste tous les worktrees PR actifs avec diagnostic
#
# Usage : ./scripts/list-pr-worktrees.sh
#
# Affiche pour chaque worktree PR :
#   - Le chemin du dossier
#   - La branche associée
#   - L'état des symlinks (intacts ou cassés)
# =============================================================================

# --- Fichiers personnels attendus (même liste que dans new-pr-worktree.sh) ---
PERSONAL_FILES=(".claude" "CLAUDE.md" "specs.md" "PLAN_GUI_KALUZA.md")

# --- Détection du nom du repo pour filtrer les worktrees PR ---
MAIN_WORKTREE="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_WORKTREE")"

# --- Récupération de la liste des worktrees ---
# Format de 'git worktree list' : /chemin/vers/worktree  HASH [branche]
WORKTREE_LIST="$(git worktree list)"

# --- Filtrage des worktrees PR (ceux dont le chemin contient '-pr-') ---
PR_WORKTREES="$(echo "$WORKTREE_LIST" | grep -E "${REPO_NAME}-pr-" || true)"

if [[ -z "$PR_WORKTREES" ]]; then
    echo "Aucun worktree PR actif."
    echo ""
    echo "Pour en créer un :"
    echo "  ./scripts/new-pr-worktree.sh feature/nom-de-la-feature"
    exit 0
fi

echo "════════════════════════════════════════════════════════════"
echo "  Worktrees PR actifs"
echo "════════════════════════════════════════════════════════════"
echo ""

# --- Parcours de chaque worktree PR ---
while IFS= read -r LINE; do
    # Extraction du chemin (premier champ)
    WT_PATH="$(echo "$LINE" | awk '{print $1}')"
    # Extraction de la branche (entre crochets)
    WT_BRANCH="$(echo "$LINE" | grep -oE '\[.*\]' | tr -d '[]')"

    echo "📁 $WT_PATH"
    echo "   Branche : $WT_BRANCH"

    # --- Vérification des symlinks ---
    SYMLINKS_OK=true
    for FILE in "${PERSONAL_FILES[@]}"; do
        TARGET="${WT_PATH}/${FILE}"
        if [[ -L "$TARGET" ]]; then
            # C'est bien un symlink — vérifier qu'il pointe vers une cible valide
            if [[ -e "$TARGET" ]]; then
                LINK_TARGET="$(readlink "$TARGET")"
                echo "   ✓ $FILE → $LINK_TARGET"
            else
                echo "   ✗ $FILE → symlink cassé (cible introuvable)"
                SYMLINKS_OK=false
            fi
        elif [[ -e "$TARGET" ]]; then
            # Le fichier existe mais n'est PAS un symlink (anormal)
            echo "   ⚠ $FILE existe mais n'est PAS un symlink (risque de commit !)"
            SYMLINKS_OK=false
        else
            # Le fichier n'existe pas du tout
            echo "   · $FILE absent (pas de symlink)"
        fi
    done

    if [[ "$SYMLINKS_OK" == true ]]; then
        echo "   État : OK"
    else
        echo "   État : ATTENTION — vérifier les symlinks"
    fi

    echo ""
done <<< "$PR_WORKTREES"
