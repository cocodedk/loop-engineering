#!/bin/sh
set -eu
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath .githooks
echo "Hooks installed — commit-msg and pre-push (owner-locked to cocodedk) are active."
