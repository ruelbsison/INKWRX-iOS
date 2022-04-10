# Copyright 2015 Bugsee, Inc. All rights reserved.
#
# Usage:
#   * In the project editor, select your target.
#   * Click "Build Phases" at the top of the project editor.
#   * Click "+" button in the top left corner.
#   * Choose "New Run Script Phase."
#   * Uncomment and paste the following script.
#
# --- INVOCATION SCRIPT BEGIN ---
# # SKIP_SIMULATOR_BUILDS=1
# SCRIPT_SRC=$(find "$PROJECT_DIR" -name 'Bugsee_build_phase.sh' | head -1)
# if [ ! "${SCRIPT_SRC}" ]; then
#   echo "Error: Bugsee build phase script not found. Make sure that you're including Bugsee.bundle in your project directory"
#   exit 1
# fi
# source "${SCRIPT_SRC}"
# --- INVOCATION SCRIPT END ---

# Check for simulator builds
if [ "$EFFECTIVE_PLATFORM_NAME" == "-iphonesimulator" ]; then
  if [ "${SKIP_SIMULATOR_BUILDS}" ] && [ "${SKIP_SIMULATOR_BUILDS}" -eq 1 ]; then
    echo "Bugsee: Skipping simulator build"
    exit 0
  fi
fi

# Create temp directory if not exists
CURRENT_USER=$(whoami| tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
TEMP_ROOT="/tmp/Bugsee-${CURRENT_USER}"
if [ ! -d "${TEMP_ROOT}" ]; then
mkdir "${TEMP_ROOT}"
fi
TEMP_DIRECTORY="${TEMP_ROOT}/$EXECUTABLE_NAME"
if [ ! -d "${TEMP_DIRECTORY}" ]; then
mkdir "${TEMP_DIRECTORY}"
fi

# Check dSYM file
DSYM_PATH=${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}
DSYM_UUIDs=$(dwarfdump --uuid "${DSYM_PATH}" | cut -d' ' -f2)

# Check if UUIDs exists
DSYM_UUIDs_PATH="${TEMP_DIRECTORY}/UUIDs.dat"
if [ -f "${DSYM_UUIDs_PATH}" ]; then
    if grep -Fxq "${DSYM_UUIDs}" "${DSYM_UUIDs_PATH}"; then
        echo "Bugsee: dSYM file already uploaded."
        exit 0
    fi
fi

APP_TOKEN=$1

if [ ! "${APP_TOKEN}" ] || [ -z "${APP_TOKEN}" ]; then
  echo "Bugsee:  Not initialized with app token. Must be passed as a parameter to $0"
  exit 1
fi

echo "Bugsee: found APP_TOKEN=${APP_TOKEN}"

# Check internet connection
if [ ! "`ping -c 1 api.bugsee.com`" ]; then
  exit 0
fi

# Create dSYM .zip file
DSYM_PATH_ZIP="${TEMP_DIRECTORY}/$DWARF_DSYM_FILE_NAME.zip"
if [ ! -d "$DSYM_PATH" ]; then
  echo "Bugsee: err: dSYM not found: ${DSYM_PATH}"
  exit 0
fi

echo "Bugsee: Compressing dSYM file..."
(/usr/bin/zip --recurse-paths --quiet "${DSYM_PATH_ZIP}" "${DSYM_PATH}") || exit 0


# Upload dSYM
echo "Bugsee: Start uploading dSYM"
BASE_API="https://api.bugsee.com"
if [ $2 ]; then
    BASE_API=$2
fi
SYMBOLS="$TEMP_DIRECTORY/symbols.txt"
CFSVString=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}")
CFBundleVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}")

# Get symbol id and endpoint

echo "Bugsee: Get symbol_id and endpoint values..."
$(curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d "{\"version\": \"${CFSVString}\", \"build\":\"${CFBundleVersion}\"}" "${BASE_API}/apps/${APP_TOKEN}/symbols" --silent --output "${TEMP_DIRECTORY}/symbols.txt")

SYMBOL_ID=$(grep -o 'symbol_id\":\"[0-9a-zA-Z.:/?%&=\-]*\"' "$SYMBOLS" | cut -d \" -f 3)
ENDPOINT=$(grep -o 'endpoint\":\"[0-9a-zA-Z.:/?%&=\-]*' "$SYMBOLS" | cut -d \" -f 3)
echo "Bugsee: SYMBOLS : ${SYMBOL_ID} , ${ENDPOINT}"

echo "Bugsee: Uploading..."
STATUSU=$(curl -v -T "${DSYM_PATH_ZIP}" "${ENDPOINT}" --write-out %{http_code} --silent --output /dev/null)

if [ $STATUSU -ne 200 ]; then
  echo "Bugsee: err: dSYM archive not succesfully uploaded."
  echo "Bugsee: deleting temporary dSYM archive..."
  /bin/rm -f "${DSYM_PATH_ZIP}"
  exit 0
fi


echo "Bugsee: Send upload complete..."
STATUSC=$(curl -X POST "${BASE_API}/symbols/${SYMBOL_ID}/status" --write-out %{http_code} --silent --output /dev/null)

if [ $STATUSC -ne 200 ]; then
  echo "Bugsee: err: dSYM upload status not confirmed."
  echo "Bugsee: deleting temporary dSYM archive..."
  /bin/rm -f "${DSYM_PATH_ZIP}"
  exit 0
fi

# Remove temp dSYM archive
echo "Bugsee: deleting temporary dSYM archive..."
/bin/rm -f "${DSYM_PATH_ZIP}"

# Save UUIDs
echo "${DSYM_UUIDs}" >> "${DSYM_UUIDs_PATH}"

# Finalize
echo "Bugsee: dSYM upload complete."
if [ "$?" -ne 0 ]; then
  echo "Bugsee: err: an error was encountered uploading dSYM"
  exit 0
fi
