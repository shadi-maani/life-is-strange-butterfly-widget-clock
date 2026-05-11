#!/usr/bin/env bash
#
# install.sh — LiS Butterfly Clock Installer
# Supports most modern Linux distributions with KDE Plasma 6
#

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Variables ───────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIDGET_DIR="${SCRIPT_DIR}/lis-clock"
WIDGET_ID="com.shadi.lisclock"
WIDGET_NAME="LiS Butterfly Clock"

# Fonts bundled inside the widget assets
ASSETS_DIR="${WIDGET_DIR}/contents/assets"
FONTS=("CabinSketch-Bold.ttf" "DuduCalligraphy.ttf")
USER_FONT_DIR="${HOME}/.local/share/fonts"

# ─── Helper Functions ────────────────────────────────────
print_header() {
    echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}  🦋 ${WIDGET_NAME} — Installer${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

info()    { echo -e "${CYAN}[INFO]${NC}    $1"; }
success() { echo -e "${GREEN}[✔]${NC}      $1"; }
warn()    { echo -e "${YELLOW}[⚠]${NC}      $1"; }
error()   { echo -e "${RED}[✘]${NC}      $1"; }

# ─── Preflight Checks ───────────────────────────────────
check_plasma6() {
    if command -v kpackagetool6 &>/dev/null; then
        KPKG_TOOL="kpackagetool6"
        return 0
    fi

    if command -v kpackagetool5 &>/dev/null; then
        error "Only ${BOLD}kpackagetool5${NC} was found."
        error "This widget requires ${BOLD}KDE Plasma 6${NC} and is not compatible with Plasma 5."
        echo ""
        warn "Plasma 6 uses a different QML API (PlasmoidItem, JSON metadata)."
        warn "Please upgrade to Plasma 6 to use this widget."
        exit 1
    fi

    error "${BOLD}kpackagetool6${NC} not found."
    error "Please ensure KDE Plasma 6 is installed."
    echo ""
    info "On most distributions, install it with:"
    echo -e "    ${BOLD}Arch/Manjaro:${NC}     sudo pacman -S plasma-sdk"
    echo -e "    ${BOLD}Fedora/RHEL:${NC}      sudo dnf install plasma-sdk"
    echo -e "    ${BOLD}openSUSE:${NC}         sudo zypper install plasma6-sdk"
    echo -e "    ${BOLD}Debian/Ubuntu:${NC}    sudo apt install plasma-sdk"
    echo -e "    ${BOLD}Nix:${NC}              nix-env -iA nixpkgs.plasma5Packages.plasma-sdk"
    exit 1
}

check_files() {
    if [[ ! -d "${WIDGET_DIR}" ]]; then
        error "Widget directory not found: ${WIDGET_DIR}"
        error "Make sure you're running this script from the project root."
        exit 1
    fi

    for font in "${FONTS[@]}"; do
        if [[ ! -f "${ASSETS_DIR}/${font}" ]]; then
            warn "Font file not found: ${ASSETS_DIR}/${font}"
            warn "The widget may not display correctly without it."
        fi
    done
}

# ─── Install Fonts ───────────────────────────────────────
install_fonts() {
    info "Installing fonts..."
    mkdir -p "${USER_FONT_DIR}"

    for font in "${FONTS[@]}"; do
        if [[ ! -f "${ASSETS_DIR}/${font}" ]]; then
            warn "Skipping ${font} — file not found."
            continue
        fi

        if [[ -f "${USER_FONT_DIR}/${font}" ]]; then
            warn "${font} already installed, skipping."
        else
            cp "${ASSETS_DIR}/${font}" "${USER_FONT_DIR}/"
            success "Installed ${font}"
        fi
    done

    if command -v fc-cache &>/dev/null; then
        fc-cache -f "${USER_FONT_DIR}" 2>/dev/null
        success "Font cache refreshed."
    else
        warn "fc-cache not found. Log out/in for fonts to take effect."
    fi
}

# ─── Install Widget ─────────────────────────────────────
install_widget() {
    info "Installing widget: ${BOLD}${WIDGET_NAME}${NC}"

    if ${KPKG_TOOL} -t Plasma/Applet -u "${WIDGET_DIR}" >/dev/null 2>&1; then
        success "Widget upgraded successfully."
    elif ${KPKG_TOOL} -t Plasma/Applet -i "${WIDGET_DIR}" >/dev/null 2>&1; then
        success "Widget installed successfully."
    else
        error "Failed to install the widget."
        echo ""
        info "Try removing the old version first:"
        echo -e "    ${KPKG_TOOL} -t Plasma/Applet -r ${WIDGET_ID}"
        echo -e "    Then re-run this script."
        exit 1
    fi
}

# ─── Uninstall ───────────────────────────────────────────
uninstall_widget() {
    print_header
    info "Uninstalling widget: ${BOLD}${WIDGET_NAME}${NC}"

    if command -v kpackagetool6 &>/dev/null; then
        KPKG_TOOL="kpackagetool6"
    else
        error "kpackagetool6 not found."
        exit 1
    fi

    if ${KPKG_TOOL} -t Plasma/Applet -r "${WIDGET_ID}" 2>/dev/null; then
        success "Widget removed."
    else
        warn "Widget was not installed or already removed."
    fi

    # Optionally remove fonts
    for font in "${FONTS[@]}"; do
        if [[ -f "${USER_FONT_DIR}/${font}" ]]; then
            read -rp "$(echo -e "${YELLOW}[?]${NC}      Remove ${font}? (y/N): ")" remove_font
            if [[ "${remove_font}" =~ ^[Yy]$ ]]; then
                rm -f "${USER_FONT_DIR}/${font}"
                success "${font} removed."
            fi
        fi
    done

    if command -v fc-cache &>/dev/null; then
        fc-cache -f "${USER_FONT_DIR}" 2>/dev/null
    fi

    echo ""
    success "Uninstall complete. Please restart Plasma or log out/in."
    exit 0
}

# ─── Main ────────────────────────────────────────────────
main() {
    if [[ "${1:-}" == "--uninstall" || "${1:-}" == "-u" ]]; then
        uninstall_widget
    fi

    print_header

    info "Checking requirements..."
    check_plasma6
    check_files

    echo ""
    install_fonts
    echo ""
    install_widget

    echo ""
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}  ✔ Installation complete!${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    info "To add the widget:"
    echo -e "    1. Right-click your desktop → ${BOLD}Add Widgets${NC}"
    echo -e "    2. Search for \"${BOLD}LiS Butterfly Clock${NC}\""
    echo -e "    3. Drag it to your desktop"
    echo ""
    info "To customize: right-click the widget → ${BOLD}Configure${NC}"
    echo ""
    info "To uninstall later, run:"
    echo -e "    ${BOLD}./install.sh --uninstall${NC}"
    echo ""
}

main "$@"
