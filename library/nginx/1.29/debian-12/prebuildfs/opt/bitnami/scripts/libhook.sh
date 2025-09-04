#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Library to use for scripts expected to be used as Kubernetes lifecycle hooks

# shellcheck disable=SC1091

# Load generic libraries
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libos.sh

# Override functions that log to stdout/stderr of the current process, so they print to process 1
for function_to_override in stderr_print debug_execute; do
  # Output is sent to output of process 1 and thus end up in the container log
  # The hook output in general isn't saved
  eval "$(declare -f "$function_to_override") >/proc/1/fd/1 2>/proc/1/fd/2"
done
