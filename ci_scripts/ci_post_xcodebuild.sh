#!/bin/bash
#
# Xcode Cloud runs this after every build action. After an archive that is
# signed for App Store Connect, it writes the TestFlight "What to Test" note,
# so each build on the phone says which pull request or branch it came from.
#
# Xcode Cloud reads the note from TestFlight/WhatToTest.<locale>.txt next to
# GustavWeights.xcodeproj. The folder is created here only, it is not in git.

set -euo pipefail

# Only archives that go to TestFlight, not test or analyze actions.
if [[ -z "${CI_APP_STORE_SIGNED_APP_PATH:-}" || ! -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
    exit 0
fi

REPO_PATH="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
NOTES_DIR="$REPO_PATH/TestFlight"
mkdir -p "$NOTES_DIR"

COMMIT="${CI_PULL_REQUEST_SOURCE_COMMIT:-${CI_COMMIT:-HEAD}}"
SHORT_COMMIT="$(git -C "$REPO_PATH" rev-parse --short "$COMMIT" 2>/dev/null || echo "${COMMIT:0:7}")"
SUBJECT="$(git -C "$REPO_PATH" log -1 --format=%s "$COMMIT" 2>/dev/null || true)"

if [[ -n "${CI_PULL_REQUEST_NUMBER:-}" ]]; then
    HEADER="PR #$CI_PULL_REQUEST_NUMBER · ${CI_PULL_REQUEST_SOURCE_BRANCH:-unknown branch} → ${CI_PULL_REQUEST_TARGET_BRANCH:-unknown}"
else
    HEADER="Branch ${CI_BRANCH:-${CI_TAG:-unknown}}"
fi

{
    echo "$HEADER"
    if [[ -n "$SUBJECT" ]]; then
        echo "$SUBJECT ($SHORT_COMMIT)"
    else
        echo "Commit $SHORT_COMMIT"
    fi
    echo "Xcode Cloud build ${CI_BUILD_NUMBER:-?}"
} > "$NOTES_DIR/WhatToTest.en-US.txt"

echo "TestFlight note:"
cat "$NOTES_DIR/WhatToTest.en-US.txt"
