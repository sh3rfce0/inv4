# Vendored upstreams

This directory contains imported copies of upstream repositories used by the
installer, without their `.git` metadata. The goal is to make the project
self-contained before replacing old GitHub raw URLs with the new owner account.

## Imported from sh3rfce0

- `sh3rfce0/api-Sherif` -> `vendor/sh3rfce0/api-Sherif`
- `sh3rfce0/izin` -> `vendor/sh3rfce0/izin`

## Notes

- The main `sh3rfce0/inv4` repository is the current repository root.
- `_upstreams/` contains temporary full clones used for inspection only.
- Runtime scripts still need their raw GitHub URLs changed before the installer
  is independent from the old account.
