#!/bin/bash

killall waybar 2>/dev/null || true
waybar >/dev/null 2>&1 &
