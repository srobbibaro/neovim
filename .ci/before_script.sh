#!/usr/bin/env bash

set -e
set -o pipefail

if [[ -n "${CI_TARGET}" ]]; then
  exit
fi

CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${CI_DIR}/common/build.sh"

# Test some of the configuration variables.
if [[ -n "${GCOV}" ]] && [[ ! $(type -P "${GCOV}") ]]; then
  echo "\$GCOV: '${GCOV}' is not executable."
  exit 1
fi
if [[ -n "${LLVM_SYMBOLIZER}" ]] && [[ ! $(type -P "${LLVM_SYMBOLIZER}") ]]; then
  echo "\$LLVM_SYMBOLIZER: '${LLVM_SYMBOLIZER}' is not executable."
  exit 1
fi

if [[ "${TRAVIS_OS_NAME}" == osx ]]; then
  # Adds user to a dummy group.
  # That allows to test changing the group of the file by `os_fchown`.
  sudo dscl . -create /Groups/chown_test
  sudo dscl . -append /Groups/chown_test GroupMembership "${USER}"
else
  # Compile dependencies.
  build_deps
fi

rm -rf "${LOG_DIR}"
mkdir -p "${LOG_DIR}"
