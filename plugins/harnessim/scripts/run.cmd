@echo off
rem run.cmd <entry> [args...] - run.sh for Windows cmd.exe (0.7.2).
rem
rem Claude Code runs an MCP headersHelper through cmd.exe on Windows, where
rem `sh` is usually not on PATH, so the helper's command falls back to this
rem file when `sh` cannot be found. Same choice as run.sh: HARNESSIM_RUNTIME,
rem then Bun, then Node, and whichever it is runs the prebuilt node\ bundles,
rem never src\ (the published plugin has none; 0.7.5).
rem With neither it prints one line to stderr and exits 0; the headers helper
rem still prints {} so the MCP connection goes ahead. No labels, so the file
rem behaves the same with LF or CRLF line endings.
setlocal
set "root=%~dp0.."
set "name=%~1"
set "known="
for %%e in (session-start prompt-submit post-set-identity post-tool watch channel-server headers-helper waiting) do if /i "%name%"=="%%e" set "known=1"
if not defined known exit /b 0
set "runtime="
if defined HARNESSIM_RUNTIME set "runtime=%HARNESSIM_RUNTIME%"
if not defined runtime where bun >nul 2>&1 && set "runtime=bun"
if not defined runtime if exist "%USERPROFILE%\.bun\bin\bun.exe" set "runtime=%USERPROFILE%\.bun\bin\bun.exe"
if not defined runtime where node >nul 2>&1 && set "runtime=node"
if not defined runtime (
  if /i "%name%"=="headers-helper" echo {}
  echo HarnessIM plugin: neither bun nor node is on PATH, so %name% did not run. Install Node.js or Bun. 1>&2
  exit /b 0
)
"%runtime%" "%root%\node\%name%.mjs" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%
