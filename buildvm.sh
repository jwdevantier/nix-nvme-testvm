#!/usr/bin/env sh

git add -u; nix build .#vm && nix run .#make-overlay overlay.img
