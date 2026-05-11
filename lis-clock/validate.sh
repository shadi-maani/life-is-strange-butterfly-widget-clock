#!/usr/bin/env bash
# ═══════════════════════════════════════════════════
#  LiS Clock Widget — Validation & Lint Script
#  Catches common Plasma 6 QML widget errors
# ═══════════════════════════════════════════════════

WIDGET_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0
WARN=0

green()  { printf "\033[32m✔ %s\033[0m\n" "$1"; ((PASS++)) || true; }
red()    { printf "\033[31m✘ %s\033[0m\n" "$1"; ((FAIL++)) || true; }
yellow() { printf "\033[33m⚠ %s\033[0m\n" "$1"; ((WARN++)) || true; }

check_file() {
    if [ -f "$1" ]; then
        green "$2 exists"
    else
        red "$2 MISSING"
    fi
}

check_grep() {
    if grep -q "$1" "$2" 2>/dev/null; then
        green "$3"
    else
        red "$4"
    fi
}

echo "══════════════════════════════════════════"
echo "  LiS Clock Widget — Validation Suite"
echo "══════════════════════════════════════════"
echo ""

# ─── 1. Structure checks ───
echo "── Structure ──"
check_file "${WIDGET_DIR}/metadata.json"            "metadata.json"
check_file "${WIDGET_DIR}/contents/ui/main.qml"     "main.qml"
check_file "${WIDGET_DIR}/contents/config/main.xml" "config/main.xml"
check_file "${WIDGET_DIR}/contents/config/config.qml" "config/config.qml"
check_file "${WIDGET_DIR}/contents/ui/ConfigGeneral.qml" "ConfigGeneral.qml"
echo ""

# ─── 2. metadata.json validation ───
echo "── metadata.json ──"
META="${WIDGET_DIR}/metadata.json"
if [ -f "$META" ]; then
    if command -v python3 &>/dev/null; then
        if python3 -c "import json; json.load(open('$META'))" 2>/dev/null; then
            green "Valid JSON syntax"
        else
            red "Invalid JSON syntax"
        fi
    fi
    check_grep '"KPlugin"' "$META" "KPlugin wrapper present (Plasma 6)" "Missing KPlugin wrapper"
    check_grep '"Id"' "$META" "Plugin Id defined" "Plugin Id missing"
fi
echo ""

# ─── 3. main.xml (kcfg) → ConfigGeneral sync ───
echo "── Config Schema Sync ──"
KCFG="${WIDGET_DIR}/contents/config/main.xml"
MAIN_QML="${WIDGET_DIR}/contents/ui/main.qml"
CONFIG_QML="${WIDGET_DIR}/contents/ui/ConfigGeneral.qml"

if [ -f "$KCFG" ] && [ -f "$MAIN_QML" ] && [ -f "$CONFIG_QML" ]; then
    ENTRIES=$(grep -oP 'name="\K[^"]+' "$KCFG" | grep -v "General")

    for entry in $ENTRIES; do
        # Check main.qml uses this config
        if grep -q "Plasmoid.configuration.$entry" "$MAIN_QML"; then
            green "main.qml reads config '$entry'"
        else
            yellow "Config '$entry' defined but unused in main.qml"
        fi

        # Check ConfigGeneral has cfg_ alias
        if grep -q "cfg_$entry" "$CONFIG_QML"; then
            green "ConfigGeneral has cfg_$entry"
        else
            red "ConfigGeneral MISSING cfg_$entry"
        fi

        # Check ConfigGeneral has cfg_*Default (Plasma 6 requirement)
        if grep -q "cfg_${entry}Default" "$CONFIG_QML"; then
            green "ConfigGeneral has cfg_${entry}Default"
        else
            red "ConfigGeneral MISSING cfg_${entry}Default (Plasma 6 requires this!)"
        fi
    done
fi
echo ""

# ─── 4. QML structure checks ───
echo "── QML Lint ──"
if [ -f "$MAIN_QML" ]; then
    check_grep "PlasmoidItem" "$MAIN_QML" \
        "Uses PlasmoidItem (Plasma 6)" "Missing PlasmoidItem root"

    check_grep "fullRepresentation" "$MAIN_QML" \
        "fullRepresentation defined" "Missing fullRepresentation"

    check_grep "backgroundHints" "$MAIN_QML" \
        "backgroundHints set" "backgroundHints not set"

    # Scope check: find IDs inside fullRepresentation and verify
    # they are NOT referenced from root scope
    FULL_REP_LINE=$(grep -n "fullRepresentation" "$MAIN_QML" | head -1 | cut -d: -f1)
    if [ -n "$FULL_REP_LINE" ]; then
        # IDs defined inside fullRepresentation
        INNER_IDS=$(tail -n +"$FULL_REP_LINE" "$MAIN_QML" | grep -oP '^\s+id:\s+\K\w+' || true)
        # Root-level code (before fullRepresentation)
        ROOT_CODE=$(head -n "$FULL_REP_LINE" "$MAIN_QML")

        SCOPE_OK=1
        for iid in $INNER_IDS; do
            # Check if root code references this ID (not in comments/id: lines)
            HITS=$(echo "$ROOT_CODE" | grep -v "^\s*//" | grep -v "id:" | grep -cw "$iid" || true)
            if [ "$HITS" -gt 0 ]; then
                red "SCOPE BUG: '$iid' used in root scope but defined inside fullRepresentation"
                SCOPE_OK=0
            fi
        done
        if [ "$SCOPE_OK" -eq 1 ]; then
            green "No cross-scope reference errors"
        fi
    fi
fi
echo ""

# ─── 5. Asset checks ───
echo "── Assets ──"
ASSETS_DIR="${WIDGET_DIR}/contents/assets"
ASSET_REFS=$(grep -rohP 'source:\s*"\.\.\/assets\/\K[^"]+' "${WIDGET_DIR}/contents/ui/"*.qml 2>/dev/null | sort -u || true)

if [ -z "$ASSET_REFS" ]; then
    yellow "No asset references found in QML files"
else
    for asset in $ASSET_REFS; do
        if [ -f "${ASSETS_DIR}/$asset" ]; then
            SIZE=$(stat -c%s "${ASSETS_DIR}/$asset")
            green "Asset '$asset' (${SIZE} bytes)"
        else
            red "Asset '$asset' referenced but FILE NOT FOUND"
        fi
    done
fi
echo ""

# ─── 6. Animation sanity ───
echo "── Animations ──"
if [ -f "$MAIN_QML" ]; then
    # Arithmetic in duration without Math.max protection
    UNSAFE=$(grep -nP 'duration:\s*root\.\w+\s*[-+]' "$MAIN_QML" | grep -v "Math.max" || true)
    if [ -z "$UNSAFE" ]; then
        green "All arithmetic durations protected (Math.max)"
    else
        while IFS= read -r line; do
            red "Unprotected duration arithmetic: $line"
        done <<< "$UNSAFE"
    fi

    # Count Animation on vs IDs
    ANIM_ON=$(grep -c "Animation on" "$MAIN_QML" || true)
    ANIM_WITH_ID=0
    while IFS= read -r linenum; do
        PREV_LINE=$((linenum - 1))
        if sed -n "${PREV_LINE}p" "$MAIN_QML" | grep -q "id:"; then
            ((ANIM_WITH_ID++)) || true
        elif sed -n "${linenum}p" "$MAIN_QML" | grep -q "id:"; then
            ((ANIM_WITH_ID++)) || true
        fi
    done <<< "$(grep -n "Animation on" "$MAIN_QML" | cut -d: -f1)"

    if [ "$ANIM_ON" -gt 0 ]; then
        if [ "$ANIM_WITH_ID" -ge "$ANIM_ON" ]; then
            green "All $ANIM_ON 'Animation on' blocks have IDs (restartable)"
        else
            yellow "$ANIM_ON animations, only $ANIM_WITH_ID have IDs — config changes may not apply"
        fi
    fi
fi
echo ""

# ─── Summary ───
echo "══════════════════════════════════════════"
TOTAL=$((PASS + FAIL + WARN))
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings (of $TOTAL checks)"
if [ "$FAIL" -gt 0 ]; then
    printf "  \033[31mFIX %d ERROR(S) BEFORE DEPLOYMENT\033[0m\n" "$FAIL"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    printf "  \033[33mWidget OK with %d warning(s)\033[0m\n" "$WARN"
else
    printf "  \033[32mAll checks passed! ✨\033[0m\n"
fi
echo "══════════════════════════════════════════"
