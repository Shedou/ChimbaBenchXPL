#!/usr/bin/env bash
if [ -e "/etc/os-release" ]; then
	source "/etc/os-release"
	echo "$PRETTY_NAME"
fi