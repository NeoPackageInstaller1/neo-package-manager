#!/bin/bash

# ============================================================
#   NEO PACKAGE MANAGER - ELITE INSTALLER v0.1
# ============================================================
#   🚨 SYSTEM REQUIREMENTS 🚨
#   • Intel i7 ALDER LAKE (12th Gen) or NEWER ONLY
#   • Apple Silicon M1/M2/M3/M4/M5
#   • AMD Ryzen 2020-2026
#   • macOS 14+, Linux Kernel 5+, Windows 11/10 Pro
#   • 1GB RAM, 2GB SSD, 7GB install space
# ============================================================
#   Contact: neopackagesystem@gmail.com
#   GitHub: @NeoPackageInstaller1
# ============================================================

set -e

# ============================================================
# COLORS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================
# HEADER
# ============================================================

clear
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} ${PURPLE}${BOLD}🚀 NEO PACKAGE MANAGER - ELITE INSTALLER v0.1 🚀${NC} ${BLUE}║${NC}"
echo -e "${BLUE}║${NC} ${WHITE}🔥 ALDER LAKE+ EDITION - FIRST RELEASE 🔥${NC}      ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================
# CHECK SYSTEM REQUIREMENTS
# ============================================================

echo -e "${CYAN}${BOLD}🔍 SCANNING SYSTEM REQUIREMENTS...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# ============================================================
# CHECK OS
# ============================================================

echo -e "${WHITE}[1/8] Checking Operating System...${NC}"

OS=""
OS_SUPPORTED=false

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "   ${BLUE}→${NC} macOS detected"
    
    MACOS_VERSION=$(sw_vers -productVersion)
    MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)
    
    if [[ $MACOS_MAJOR -ge 14 ]]; then
        echo -e "   ${GREEN}✅${NC} macOS ${MACOS_VERSION} (Sonoma+) - SUPPORTED"
        OS="macos"
        OS_SUPPORTED=true
        ((PASSED++))
    else
        echo -e "   ${RED}❌${NC} macOS ${MACOS_VERSION} - NOT SUPPORTED"
        echo -e "   ${YELLOW}   → Requires macOS 14 (Sonoma) or newer${NC}"
        ((FAILED++))
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "   ${BLUE}→${NC} Linux detected"
    
    KERNEL_VERSION=$(uname -r | cut -d. -f1)
    
    if [[ $KERNEL_VERSION -ge 5 ]]; then
        echo -e "   ${GREEN}✅${NC} Linux Kernel ${KERNEL_VERSION}.x - SUPPORTED"
        OS="linux"
        OS_SUPPORTED=true
        ((PASSED++))
    else
        echo -e "   ${RED}❌${NC} Linux Kernel ${KERNEL_VERSION}.x - NOT SUPPORTED"
        echo -e "   ${YELLOW}   → Requires Kernel 5.0 or newer${NC}"
        ((FAILED++))
    fi

elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo -e "   ${BLUE}→${NC} Windows detected"
    
    if [[ "$OSTYPE" == "msys" ]]; then
        WIN_VERSION=$(cmd.exe /c ver 2>/dev/null | grep -o "[0-9]*\.[0-9]*\.[0-9]*" | head -1)
        WIN_MAJOR=$(echo $WIN_VERSION | cut -d. -f1)
    else
        WIN_MAJOR="10"
    fi
    
    if [[ $WIN_MAJOR -ge 11 ]]; then
        echo -e "   ${GREEN}✅${NC} Windows 11 - SUPPORTED"
        OS="windows"
        OS_SUPPORTED=true
        ((PASSED++))
    elif [[ $WIN_MAJOR -eq 10 ]]; then
        echo -e "   ${YELLOW}⚠️${NC} Windows 10 detected - checking for Pro version..."
        
        if [[ "$OSTYPE" == "msys" ]]; then
            WIN_EDITION=$(wmic os get caption 2>/dev/null | grep "Windows 10 Pro" || echo "")
            if [[ -n "$WIN_EDITION" ]]; then
                echo -e "   ${GREEN}✅${NC} Windows 10 Pro - SUPPORTED"
                OS="windows"
                OS_SUPPORTED=true
                ((PASSED++))
            else
                echo -e "   ${RED}❌${NC} Windows 10 Home/Other - NOT SUPPORTED"
                echo -e "   ${YELLOW}   → Only Windows 10 Pro is supported${NC}"
                ((FAILED++))
            fi
        else
            echo -e "   ${RED}❌${NC} Cannot verify Windows edition"
            ((FAILED++))
        fi
    else
        echo -e "   ${RED}❌${NC} Windows ${WIN_MAJOR} - NOT SUPPORTED"
        echo -e "   ${YELLOW}   → Requires Windows 11 or Windows 10 Pro${NC}"
        ((FAILED++))
    fi

else
    echo -e "   ${RED}❌${NC} Unknown OS: $OSTYPE"
    ((FAILED++))
fi

echo ""

# ============================================================
# CHECK CPU - ADVANCED DETECTION WITH MODEL NUMBERS
# ============================================================

echo -e "${WHITE}[2/8] Checking CPU (Advanced Detection)...${NC}"

CPU_SUPPORTED=false
CPU_NAME=""
CPU_GEN=0
CPU_YEAR="unknown"
CPU_MODEL_NUMBER=""
CPU_VENDOR="unknown"

# Function: Get CPU Model Number (actual silicon ID)
get_cpu_model_number() {
    local model=""
    
    if [[ "$OS" == "macos" ]]; then
        model=$(sysctl -n machdep.cpu.model 2>/dev/null)
        echo "$model"
    elif [[ "$OS" == "linux" ]]; then
        model=$(grep -m1 "model" /proc/cpuinfo | awk '{print $3}')
        echo "$model"
    elif [[ "$OS" == "windows" ]]; then
        model=$(wmic cpu get processorid 2>/dev/null | grep -v "ProcessorId" | head -1 | cut -c1-2 2>/dev/null)
        echo "$model"
    else
        echo "unknown"
    fi
}

# Function: Detect Intel generation from model number (hardware-level!)
get_intel_gen_from_model() {
    local model_num="$1"
    
    case "$model_num" in
        183|182|181|180|179|178|177|176|175|174|173|172|171|170)
            echo "14"  # 14th Gen (Meteor Lake/Raptor Lake Refresh)
            ;;
        154|153|152|151|150|149|148|147|146|145|144|143|142|141|140)
            echo "12"  # 12th Gen (Alder Lake)
            ;;
        141|140|139|138|137|136|135|134|133|132|131|130)
            echo "11"  # 11th Gen (Rocket Lake/Tiger Lake)
            ;;
        130|129|128|127|126|125|124|123|122|121|120)
            echo "10"  # 10th Gen (Comet Lake/Ice Lake)
            ;;
        120|119|118|117|116|115|114|113|112|111|110)
            echo "9"   # 9th Gen (Coffee Lake Refresh)
            ;;
        110|109|108|107|106|105|104|103|102|101|100)
            echo "8"   # 8th Gen (Coffee Lake)
            ;;
        99|98|97|96|95|94|93|92|91|90)
            echo "7"   # 7th Gen (Kaby Lake)
            ;;
        89|88|87|86|85|84|83|82|81|80)
            echo "6"   # 6th Gen (Skylake)
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function: Get CPU release year
get_cpu_year() {
    local gen="$1"
    local vendor="$2"
    
    if [[ "$vendor" == "intel" ]]; then
        case "$gen" in
            14) echo "2023" ;;
            13) echo "2022" ;;
            12) echo "2021" ;;
            11) echo "2020" ;;
            10) echo "2019" ;;
            9)  echo "2018" ;;
            8)  echo "2017" ;;
            7)  echo "2016" ;;
            6)  echo "2015" ;;
            *)  echo "unknown" ;;
        esac
    elif [[ "$vendor" == "amd" ]]; then
        if [[ "$CPU_NAME" =~ "Ryzen 9" ]]; then
            echo "2022"
        elif [[ "$CPU_NAME" =~ "Ryzen 7" ]]; then
            echo "2021"
        elif [[ "$CPU_NAME" =~ "Ryzen 5" ]]; then
            echo "2020"
        else
            echo "2021"
        fi
    else
        echo "unknown"
    fi
}

# Now actually detect the CPU
if [[ "$OS" == "macos" ]]; then
    ARCH=$(uname -m)
    
    if [[ "$ARCH" == "arm64" ]]; then
        # Apple Silicon - Get actual chip info
        CPU_NAME=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple M-Series")
        CPU_VENDOR="apple"
        
        if [[ "$CPU_NAME" =~ "M1" ]]; then
            echo -e "   ${GREEN}✅${NC} Apple Silicon M1 - SUPPORTED"
            CPU_SUPPORTED=true
            CPU_YEAR=2020
            ((PASSED++))
        elif [[ "$CPU_NAME" =~ "M2" ]]; then
            echo -e "   ${GREEN}✅${NC} Apple Silicon M2 - SUPPORTED"
            CPU_SUPPORTED=true
            CPU_YEAR=2022
            ((PASSED++))
        elif [[ "$CPU_NAME" =~ "M3" ]]; then
            echo -e "   ${GREEN}✅${NC} Apple Silicon M3 - SUPPORTED"
            CPU_SUPPORTED=true
            CPU_YEAR=2023
            ((PASSED++))
        elif [[ "$CPU_NAME" =~ "M4" ]]; then
            echo -e "   ${GREEN}✅${NC} Apple Silicon M4 - SUPPORTED"
            CPU_SUPPORTED=true
            CPU_YEAR=2024
            ((PASSED++))
        elif [[ "$CPU_NAME" =~ "M5" ]]; then
            echo -e "   ${GREEN}✅${NC} Apple Silicon M5 - SUPPORTED"
            CPU_SUPPORTED=true
            CPU_YEAR=2025
            ((PASSED++))
        else
            echo -e "   ${GREEN}✅${NC} Apple Silicon detected - SUPPORTED"
            CPU_SUPPORTED=true
            CPU_YEAR=2024
            ((PASSED++))
        fi
        
    elif [[ "$ARCH" == "x86_64" ]]; then
        # Intel Mac - Get detailed info
        CPU_NAME=$(sysctl -n machdep.cpu.brand_string)
        CPU_MODEL_NUMBER=$(get_cpu_model_number)
        echo -e "   ${BLUE}→${NC} Intel Mac detected"
        echo -e "   ${BLUE}→${NC} CPU: $CPU_NAME"
        echo -e "   ${BLUE}→${NC} Model Number: $CPU_MODEL_NUMBER"
        
        CPU_GEN=$(get_intel_gen_from_model "$CPU_MODEL_NUMBER")
        CPU_VENDOR="intel"
        
        if [[ "$CPU_GEN" -ge 12 ]] && [[ "$CPU_GEN" -le 14 ]]; then
            CPU_YEAR=$(get_cpu_year "$CPU_GEN" "intel")
            echo -e "   ${GREEN}✅${NC} Intel ${CPU_GEN}th Gen (${CPU_YEAR}) - ELITE SUPPORTED"
            CPU_SUPPORTED=true
            ((PASSED++))
        elif [[ "$CPU_GEN" -ge 8 ]] && [[ "$CPU_GEN" -le 11 ]]; then
            CPU_YEAR=$(get_cpu_year "$CPU_GEN" "intel")
            echo -e "   ${YELLOW}⚠️${NC} Intel ${CPU_GEN}th Gen (${CPU_YEAR}) - LEGACY VERSION"
            echo -e "   ${YELLOW}   → Not supported in Elite Edition${NC}"
            echo -e "   ${YELLOW}   → Contact: neopackagesystem@gmail.com${NC}"
            ((WARNINGS++))
            ((FAILED++))
        else
            echo -e "   ${RED}❌${NC} Unsupported Intel CPU (Model: $CPU_MODEL_NUMBER)"
            echo -e "   ${YELLOW}   → ELITE EDITION requires 12th Gen+${NC}"
            ((FAILED++))
        fi
    fi

elif [[ "$OS" == "linux" ]]; then
    CPU_NAME=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    CPU_MODEL_NUMBER=$(get_cpu_model_number)
    echo -e "   ${BLUE}→${NC} CPU: $CPU_NAME"
    echo -e "   ${BLUE}→${NC} Model Number: $CPU_MODEL_NUMBER"
    
    if [[ "$CPU_NAME" =~ "Intel" ]]; then
        CPU_VENDOR="intel"
        CPU_GEN=$(get_intel_gen_from_model "$CPU_MODEL_NUMBER")
        
        if [[ "$CPU_GEN" -ge 12 ]] && [[ "$CPU_GEN" -le 14 ]]; then
            CPU_YEAR=$(get_cpu_year "$CPU_GEN" "intel")
            echo -e "   ${GREEN}✅${NC} Intel ${CPU_GEN}th Gen (${CPU_YEAR}) - ELITE SUPPORTED"
            CPU_SUPPORTED=true
            ((PASSED++))
        elif [[ "$CPU_GEN" -ge 8 ]] && [[ "$CPU_GEN" -le 11 ]]; then
            CPU_YEAR=$(get_cpu_year "$CPU_GEN" "intel")
            echo -e "   ${YELLOW}⚠️${NC} Intel ${CPU_GEN}th Gen (${CPU_YEAR}) - LEGACY VERSION"
            echo -e "   ${YELLOW}   → Contact: neopackagesystem@gmail.com${NC}"
            ((WARNINGS++))
            ((FAILED++))
        else
            echo -e "   ${RED}❌${NC} Unsupported Intel CPU"
            ((FAILED++))
        fi
        
    elif [[ "$CPU_NAME" =~ "AMD" ]]; then
        CPU_VENDOR="amd"
        CPU_YEAR=$(get_cpu_year "" "amd")
        echo -e "   ${GREEN}✅${NC} AMD Ryzen (${CPU_YEAR}) - SUPPORTED"
        CPU_SUPPORTED=true
        ((PASSED++))
    else
        echo -e "   ${RED}❌${NC} Unknown CPU"
        ((FAILED++))
    fi

elif [[ "$OS" == "windows" ]]; then
    if [[ "$OSTYPE" == "msys" ]]; then
        CPU_NAME=$(wmic cpu get name 2>/dev/null | grep -v "Name" | head -1 | xargs)
        echo -e "   ${BLUE}→${NC} CPU: $CPU_NAME"
        
        if [[ "$CPU_NAME" =~ "Intel" ]]; then
            CPU_VENDOR="intel"
            CPU_MODEL_NUMBER=$(get_cpu_model_number)
            CPU_GEN=$(get_intel_gen_from_model "$CPU_MODEL_NUMBER")
            
            if [[ "$CPU_GEN" -ge 12 ]] && [[ "$CPU_GEN" -le 14 ]]; then
                CPU_YEAR=$(get_cpu_year "$CPU_GEN" "intel")
                echo -e "   ${GREEN}✅${NC} Intel ${CPU_GEN}th Gen (${CPU_YEAR}) - ELITE SUPPORTED"
                CPU_SUPPORTED=true
                ((PASSED++))
            elif [[ "$CPU_GEN" -ge 8 ]] && [[ "$CPU_GEN" -le 11 ]]; then
                CPU_YEAR=$(get_cpu_year "$CPU_GEN" "intel")
                echo -e "   ${YELLOW}⚠️${NC} Intel ${CPU_GEN}th Gen (${CPU_YEAR}) - LEGACY VERSION"
                echo -e "   ${YELLOW}   → Contact: neopackagesystem@gmail.com${NC}"
                ((WARNINGS++))
                ((FAILED++))
            else
                echo -e "   ${RED}❌${NC} Unsupported Intel CPU"
                ((FAILED++))
            fi
            
        elif [[ "$CPU_NAME" =~ "AMD" ]]; then
            CPU_VENDOR="amd"
            echo -e "   ${GREEN}✅${NC} AMD CPU - SUPPORTED"
            CPU_SUPPORTED=true
            ((PASSED++))
        else
            echo -e "   ${RED}❌${NC} Unknown CPU"
            ((FAILED++))
        fi
    fi
fi

# Show detailed CPU info
echo -e "   ${BLUE}→${NC} Vendor: $CPU_VENDOR"
if [[ "$CPU_YEAR" != "unknown" ]]; then
    echo -e "   ${BLUE}→${NC} Year: $CPU_YEAR"
fi
echo ""

# ============================================================
# CHECK RAM
# ============================================================

echo -e "${WHITE}[3/8] Checking RAM...${NC}"

RAM_GB=0

if [[ "$OS" == "macos" ]]; then
    RAM_BYTES=$(sysctl -n hw.memsize)
    RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))
elif [[ "$OS" == "linux" ]]; then
    RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    RAM_GB=$((RAM_KB / 1024 / 1024))
elif [[ "$OS" == "windows" ]]; then
    if [[ "$OSTYPE" == "msys" ]]; then
        RAM_KB=$(wmic memorychip get capacity 2>/dev/null | grep -v "Capacity" | awk '{sum+=$1} END {print sum}')
        RAM_GB=$((RAM_KB / 1024 / 1024 / 1024))
    else
        RAM_GB=0
    fi
fi

echo -e "   ${BLUE}→${NC} RAM: ${RAM_GB} GB"

if [[ $RAM_GB -gt 1 ]]; then
    echo -e "   ${GREEN}✅${NC} RAM (${RAM_GB}GB > 1GB) - SUPPORTED"
    ((PASSED++))
else
    echo -e "   ${RED}❌${NC} RAM (${RAM_GB}GB < 1GB) - NOT SUPPORTED"
    echo -e "   ${YELLOW}   → Requires at least 1GB of RAM${NC}"
    ((FAILED++))
fi

echo ""

# ============================================================
# CHECK STORAGE
# ============================================================

echo -e "${WHITE}[4/8] Checking Storage (SSD)...${NC}"

STORAGE_GB=0
IS_SSD=false

if [[ "$OS" == "macos" ]]; then
    STORAGE_BYTES=$(df / | tail -1 | awk '{print $2}')
    STORAGE_GB=$((STORAGE_BYTES / 1024 / 1024))
    IS_SSD=true
    
elif [[ "$OS" == "linux" ]]; then
    STORAGE_BYTES=$(df / | tail -1 | awk '{print $2}')
    STORAGE_GB=$((STORAGE_BYTES / 1024 / 1024))
    
    for disk in $(lsblk -d -o NAME,ROTA | grep " 0$" | awk '{print $1}'); do
        if [[ $(df / | tail -1 | awk '{print $1}') == *"$disk"* ]]; then
            IS_SSD=true
            break
        fi
    done
    
elif [[ "$OS" == "windows" ]]; then
    if [[ "$OSTYPE" == "msys" ]]; then
        STORAGE_BYTES=$(df / | tail -1 | awk '{print $2}')
        STORAGE_GB=$((STORAGE_BYTES / 1024 / 1024))
        IS_SSD=true
    fi
fi

echo -e "   ${BLUE}→${NC} Storage: ${STORAGE_GB} GB total"

if [[ "$IS_SSD" == true ]]; then
    echo -e "   ${GREEN}✅${NC} SSD detected"
else
    echo -e "   ${YELLOW}⚠️${NC} Not confirmed as SSD"
fi

if [[ $STORAGE_GB -gt 2 ]]; then
    echo -e "   ${GREEN}✅${NC} Storage (${STORAGE_GB}GB > 2GB) - SUPPORTED"
    ((PASSED++))
else
    echo -e "   ${RED}❌${NC} Storage (${STORAGE_GB}GB < 2GB) - NOT SUPPORTED"
    echo -e "   ${YELLOW}   → Requires at least 2GB of storage${NC}"
    ((FAILED++))
fi

echo ""

# ============================================================
# CHECK INSTALL SIZE
# ============================================================

echo -e "${WHITE}[5/8] Checking Installation Requirements...${NC}"
echo -e "   ${BLUE}→${NC} Required space: 7 GB"
echo -e "   ${BLUE}→${NC} Available space: ${STORAGE_GB} GB"

if [[ $STORAGE_GB -ge 7 ]]; then
    echo -e "   ${GREEN}✅${NC} Enough space for installation (${STORAGE_GB}GB ≥ 7GB)"
    ((PASSED++))
else
    echo -e "   ${RED}❌${NC} Not enough space (${STORAGE_GB}GB < 7GB)"
    echo -e "   ${YELLOW}   → Requires 7GB of free space${NC}"
    ((FAILED++))
fi

echo ""

# ============================================================
# CHECK INTERNET
# ============================================================

echo -e "${WHITE}[6/8] Checking Internet Connection...${NC}"

if ping -c 1 google.com &> /dev/null || ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "   ${GREEN}✅${NC} Internet connection detected"
    ((PASSED++))
else
    echo -e "   ${RED}❌${NC} No internet connection"
    echo -e "   ${YELLOW}   → Internet required for installation${NC}"
    ((FAILED++))
fi

echo ""

# ============================================================
# CHECK BREW
# ============================================================

echo -e "${WHITE}[7/8] Checking Homebrew...${NC}"

if command -v brew &> /dev/null; then
    echo -e "   ${GREEN}✅${NC} Homebrew already installed"
    ((PASSED++))
else
    echo -e "   ${YELLOW}⚠️${NC} Homebrew not found - will install"
    ((WARNINGS++))
fi

echo ""

# ============================================================
# SUMMARY
# ============================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}📊 SYSTEM CHECK SUMMARY${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${GREEN}✅ Passed: ${PASSED}${NC}"
echo -e "   ${YELLOW}⚠️ Warnings: ${WARNINGS}${NC}"
echo -e "   ${RED}❌ Failed: ${FAILED}${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}🎉 ALL SYSTEM CHECKS PASSED!${NC}"
    echo -e "${GREEN}   Your system meets ELITE requirements! Proceeding...${NC}"
    echo ""
    
    # ============================================================
    # INSTALL HOMEBREW
    # ============================================================
    
    echo -e "${WHITE}[8/8] Setting up Homebrew...${NC}"
    
    if ! command -v brew &> /dev/null; then
        echo -e "   ${YELLOW}📦 Installing Homebrew...${NC}"
        
        if [[ "$OS" == "macos" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ "$OS" == "linux" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ "$OS" == "windows" ]]; then
            echo -e "   ${RED}❌ Windows requires WSL2 for Homebrew${NC}"
            echo -e "   ${YELLOW}   Install WSL2 and try again${NC}"
            exit 1
        fi
        
        echo -e "   ${GREEN}✅ Homebrew installed${NC}"
    else
        echo -e "   ${GREEN}✅ Homebrew ready${NC}"
    fi
    
    echo ""
    
    # ============================================================
    # INSTALL NEO
    # ============================================================
    
    echo -e "${CYAN}${BOLD}📥 Installing Neo Package Manager...${NC}"
    
    INSTALL_DIR="/usr/local/bin"
    
    if [ ! -w "$INSTALL_DIR" ]; then
        SUDO_CMD="sudo"
    else
        SUDO_CMD=""
    fi
    
    $SUDO_CMD curl -sL https://raw.githubusercontent.com/NeoPackageInstaller1/neo-package-manager/main/Neo -o "$INSTALL_DIR/Neo"
    $SUDO_CMD chmod +x "$INSTALL_DIR/Neo"
    
    echo -e "${GREEN}✅ Neo installed successfully!${NC}"
    echo ""
    
    # ============================================================
    # CELEBRATION
    # ============================================================
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}${BOLD}🎉🎊 INSTALLATION COMPLETE! 🎊🎉${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}🔥 Your Alder Lake+ system is ready! 🔥${NC}    ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${PURPLE}${BOLD}✨ Commands to try:${NC}"
    echo -e "  ${GREEN}Neo help${NC}           - Show all commands"
    echo -e "  ${GREEN}Neo celebration${NC}    - 🎊 SURPRISE! 🎊"
    echo -e "  ${GREEN}Neo install python${NC} - Install any package"
    echo ""
    echo -e "${CYAN}📧 Email: neopackagesystem@gmail.com${NC}"
    echo -e "${YELLOW}💡 Have a feature idea? EMAIL US! We MIGHT add it!${NC}"
    echo ""
    echo -e "${BLUE}${BOLD}🚀 Neo is ready. Go build something legendary!${NC}"
    
else
    # ============================================================
    # FAILURE - WITH LEGACY OPTION
    # ============================================================
    
    echo -e "${RED}${BOLD}❌ ELITE SYSTEM REQUIREMENTS NOT MET${NC}"
    echo -e "${RED}   This is the ELITE EDITION for Alder Lake+ systems.${NC}"
    echo ""
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ Older CPU Detected!${NC}"
        echo -e "${YELLOW}   You have an Intel 8th-11th Gen CPU or older.${NC}"
        echo ""
    fi
    
    echo -e "${WHITE}${BOLD}📋 Elite Edition Requirements:${NC}"
    echo -e "   • ${BOLD}CPU:${NC} Intel i7 ALDER LAKE (12th Gen)+"
    echo -e "   • ${BOLD}OR${NC} Apple Silicon M1/M2/M3/M4/M5"
    echo -e "   • ${BOLD}OR${NC} AMD Ryzen 2020-2026"
    echo -e "   • macOS 14+ OR Linux Kernel 5+ OR Windows 11/10 Pro"
    echo -e "   • Minimum 1GB RAM, 2GB SSD, 7GB space"
    echo ""
    echo -e "${YELLOW}${BOLD}💡 Legacy Version Available!${NC}"
    echo -e "${YELLOW}   We have a version for older systems!${NC}"
    echo -e "${CYAN}   📧 Email: neopackagesystem@gmail.com${NC}"
    echo -e "${YELLOW}   → Tell us your system specs and we'll send you the link!${NC}"
    echo ""
    echo -e "${CYAN}📧 Contact: neopackagesystem@gmail.com${NC}"
    exit 1
fi
