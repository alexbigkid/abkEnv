#!/bin/bash

set -eu

echo ""
echo "-> $0 ($@)"
echo ""

echo "path contains following:"
echo "------------------------"
echo "${PATH//:/$'\n'}"
EXIT_CODE=$?

echo ""
echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
