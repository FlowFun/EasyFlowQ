# CLAUDE.md — EasyFlowQ

## Project Overview

EasyFlowQ is an open-source flow cytometry analysis application built with **PySide6** and **Matplotlib**.
It reads FCS files, provides interactive gating, compensation, and visualization tools.

- **Language**: Python 3.10+
- **GUI Framework**: PySide6 (Qt6)
- **Plotting**: Matplotlib (embedded via `FigureCanvasQTAgg`)
- **Data**: NumPy, Pandas, SciPy, SymPy (derived parameters)
- **FCS I/O**: Bundled FlowCal library (`src/EasyFlowQ/FlowCal/`)

## Development Mode: TDD Strict

**IMPORTANT**: Tout developpement suit le cycle TDD decrit dans `specs.md`.
Utiliser `/dev <description>` pour implementer une fonction avec le workflow automatise.
Ne jamais implementer de code sans ecrire les tests d'abord.

## Repository Structure

```
src/EasyFlowQ/
├── start.py              # App entry point, exception handling
├── window_Main.py        # Main window (central coordinator, ~1000 lines)
├── window_Stats.py       # Statistics window
├── window_Comp.py        # Compensation matrix editor
├── window_Settings.py    # Settings (localSettings)
├── wizard_Comp.py        # Compensation wizard
├── backend/
│   ├── gates.py          # Gate types: polygon, line, quadrant, split + editors
│   ├── plotWidgets.py    # plotCanvas (matplotlib rendering), toolbar
│   ├── qtModels.py       # Qt models: smplItem, subpopItem, chnlModel
│   ├── dataIO.py         # FCSData_ef (extended FCS data + derived params)
│   ├── comp.py           # Compensation table models
│   ├── efio.py           # Session save/load (.eflq JSON), FCS export
│   └── utils.py          # colorGenerator, utilities
├── uiDesigns/
│   ├── MainWindow.ui     # Main window layout (XML)
│   ├── MainWindow_FigOptions.py  # Figure options panel
│   ├── MainWindow_SmplSect.py    # Sample tree panel
│   └── *.ui              # Other dialog layouts
└── FlowCal/              # Bundled flow cytometry library (DO NOT MODIFY)
```

## Development Commands

```bash
# Run the application
python main.py

# Run with a session file
python main.py path/to/session.eflq

# Install in development mode
pip install -e .

# Run tests
python -m pytest test/
```

## Architecture Notes

- **Entry**: `main.py` → `start.startGUI()` → `mainUi(QMainWindow)`
- **Signal flow**: UI widgets emit signals → `handle_One()` is the central redraw handler
- **Data flow**: FCS file → `FCSData_ef` → `smplItem` (tree widget) → compensation → gating → `plotCanvas.redraw()`
- **Gate system**: Gates stored in `gateListWidget` (QListWidget), applied via `gateSmpls()` in `plotWidgets.py`
- **Sessions**: Saved as JSON (`.eflq`) via `sessionSave` class in `backend/efio.py`

## Coding Conventions

- Class names: `camelCase` (e.g., `mainUi`, `plotCanvas`, `smplItem`)
- Method names: `camelCase` (e.g., `handle_One`, `handle_LoadData`)
- Private methods: prefix with `_`
- UI files: PascalCase `.ui` files loaded via custom `UiLoader`
- Signals: prefixed with `signal_` (e.g., `signal_PlotRedraw`)
- Qt handlers: prefixed with `handle_` (e.g., `handle_AddGate`)

## Important Constraints

- **FlowCal/**: Bundled external library — do NOT modify these files
- **Backward compatibility**: `.eflq` session files must remain loadable
- **PySide6**: All Qt imports must use PySide6, NOT PyQt6
- **Matplotlib**: Plots use matplotlib's Qt backend (`FigureCanvasQTAgg`)
- **Performance**: Large FCS files (>1M events) — use subsampling in performance mode

## Git & Shell Safety

- Never use compound bash commands for Git (e.g., avoid `cd dir && git status`). Use the `-C` flag instead: `git -C <path> <command>`
- For navigation, execute separate commands rather than chaining with `&&`

## Claude Code Configuration

```
.claude/
├── settings.json           # Permissions and env vars
├── agents/
│   ├── commit-writer.md    # Automated commit agent (Haiku)
│   └── tdd-dev.md          # TDD development agent (Sonnet)
├── commands/
│   ├── commit.md           # /commit — stage + commit via agent
│   ├── dev.md              # /dev — TDD cycle (tests → code → commit)
│   ├── analyze-gate.md     # /analyze-gate — gating hierarchy analysis
│   ├── check-compat.md     # /check-compat — .eflq backward compat
│   ├── run.md              # /run — launch app
│   ├── test.md             # /test — run pytest
│   └── plan-status.md      # /plan-status — GUI redesign progress
└── skills/
    └── adr-create/         # Architecture Decision Records generator
        ├── SKILL.md
        └── references/
            └── template.md
```

## Current GUI Redesign Plan

See `PLAN_GUI_KALUZA.md` for the comprehensive plan to redesign the interface
inspired by Kaluza (Beckman Coulter). Key phases:

1. Layout refactoring (QDockWidgets + QMdiArea multi-plots)
2. Gate hierarchy (QTreeView + GateTreeModel)
3. Protocol system (.efqp files)
4. Radial context menu
5. Enhanced Analysis List
6. New plot types (contour, overlay, comparison)
7. Undo/redo, batch processing, dark theme

---

## Contribution Strategy: Contributing Back to Upstream

All developments in this project are intended to be contributed back to the
original EasyFlowQ repository maintained by Yitong Ma:
**https://github.com/ym3141/EasyFlowQ**

### Guiding Principles

- **Every feature must be mergeable**: write clean, focused code that the
  original maintainer can review and accept without needing to understand our
  full refactoring plan.
- **Prefer small contributions over large ones**: a 200-line contour plot PR
  is infinitely more likely to be merged than a 5000-line GUI refactor.
- **Never break existing users**: `.eflq` session files must remain loadable,
  existing gating logic must not regress.
- **Language**: commit messages, PR titles, and code comments must be in
  **English** (the project's language), even if we discuss internally in French.

### Workflow per Feature

```
1. DISCUSS    → Open a GitHub Issue on ym3141/EasyFlowQ to propose the feature
2. BRANCH     → Work on a local feature branch: feature/<short-name>
3. DEVELOP    → TDD cycle (see specs.md): tests first, then implementation
4. VALIDATE   → All tests pass, no regression on existing test suite
5. PULL REQUEST → Open PR on ym3141/EasyFlowQ with description + test plan
6. ITERATE    → Address maintainer review feedback
7. MERGE      → Feature integrated upstream
```

### What to Contribute (Priority Order)

Based on the feasibility analysis of `PLAN_GUI_KALUZA.md`, contribute in this order:

| Priority | Feature | Why first |
|---|---|---|
| 1 | **Contour plot** | Self-contained, no regression risk, 1–2 days |
| 2 | **Overlay plot** | Extends existing multi-sample logic |
| 3 | **Context menu on plots** | Non-destructive QMenu, no architecture change |
| 4 | **Gate hierarchy** | Requires upstream discussion first (Issue) |
| 5 | **Protocol system** | Requires upstream agreement on file format |
| 6 | **Multi-plot workspace** | Major refactor — upstream agreement mandatory |

### Pull Request Checklist

Before opening a PR on ym3141/EasyFlowQ:

- [ ] All existing tests pass (`python -m pytest test/`)
- [ ] New tests written for the new feature
- [ ] No modification to `FlowCal/` (bundled external library)
- [ ] `.eflq` session backward compatibility preserved
- [ ] PR description includes: what, why, how to test
- [ ] Code follows project conventions (see Coding Conventions above)
- [ ] Commit messages in English, Conventional Commits format

### GitHub Issue First (for architectural changes)

For any change that modifies existing architecture (gate system, session
format, main window layout), **open a GitHub Issue before coding**:
- Describe the problem and proposed solution
- Ask for maintainer feedback
- Avoid investing weeks of work on something the maintainer won't accept

### Branch Naming

- Feature branches: `feature/<short-name>` (e.g., `feature/contour-plot`)
- Bug fixes: `fix/<issue-number>-<short-name>`
- Always branch from the latest `pyside6` branch of the upstream repo
