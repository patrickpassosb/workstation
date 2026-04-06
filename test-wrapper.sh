#!/bin/bash
# Minimal test output for Ralph

# Validation: Check if the scripts exist and have no syntax errors
if [[ -f "./setup.sh" ]]; then
    if bash -n "./setup.sh"; then
        echo "✓ setup.sh syntax OK"
    else
        echo "✗ setup.sh syntax failed"
        exit 1
    fi
fi

# Check for specific files in active-plan.md
if [[ -f "specs/implementation-plans/active-plan.md" ]]; then
    echo "✓ implementation plan found"
else
    echo "✗ implementation plan missing"
    exit 1
fi

echo "✓ All current validation tests passed"
exit 0
