# Berusky 1.7.2 Release 1 — ArcaOS Port

Berusky is a 2D logic game based on the classic Sokoban puzzle, originally
written by Martin Stransky (AnakreoN). This release is an ArcaOS/OS2 port
that migrates the game from SDL1 to SDL2 and adapts it to run natively on
ArcaOS 5.1.

## Changes in version 1.7.2 Release 1 (ArcaOS port)

### SDL1 to SDL2 migration

The game was originally built against SDL 1.x. This release ports the entire
rendering and input pipeline to SDL2:

- Replaced `SDL_Surface`-based screen with a SDL2 window, renderer, and
  streaming texture. The game still renders internally into a shadow surface
  (`SDL_CreateRGBSurface`), which is uploaded to the GPU texture each frame
  via `SDL_UpdateTexture`.
- Replaced `SDL_SetAlpha` with `SDL_SetSurfaceAlphaMod`.
- Replaced `SDL_GetKeyState` (keycode-indexed in SDL1) with
  `SDL_GetKeyboardState` (scancode-indexed in SDL2). Key mappings now convert
  SDLK keycodes to scancodes via `SDL_GetScancodeFromKey` before indexing the
  keyboard state array.
- Replaced `SDL_Keycode`/`SDL_Keymod` typedefs throughout `input.h`.
- Added OS/2 module definition file (`berusky.def`) with `WINDOWAPI` to
  suppress the VIO console window.

### Build system

- Added `src/makefile.os2` and `src/compile.cmd` for building under ArcaOS
  with GCC 9.2 / EMX / InnoTekLIBC.
- Compiler flags: `-D__OS2__`, `-DPACKAGE_DATA_DIR="."`, SDL2 via
  `sdl2-config`.
- Linker flags: `-Zomf -Zhigh-mem -Zmap`, `berusky.def`.
- Required environment variables: `EMXOMFLD_TYPE=WLINK`,
  `EMXOMFLD_LINKER=wl.exe`, `EMXOMFLD_PRELINK=0`.

### Data path resolution (OS/2)

On Linux the game uses absolute install paths (`/usr/share/berusky/...`).
On OS/2 these paths are invalid. The `dir_list::load` function in `utils.cpp`
now includes an `#ifdef __OS2__` block that extracts the last path component
from any absolute Unix path read from the INI file and converts it to a
relative path (`./ComponentName`). This makes the game work correctly
regardless of what paths are stored in `berusky.ini`.

The deployment layout expected on ArcaOS:

```
berusky.exe
berusky\berusky.ini
GameData\
Graphics\
Levels\
```

### Display and scaling

- The game opens a **1024×768** window by default in windowed mode,
  regardless of the internal game resolution (640×480 in original-size mode,
  1280×900 in double-size mode). The game image is scaled to fit with correct
  aspect ratio and letterboxed as needed.
- In fullscreen mode (`SDL_WINDOW_FULLSCREEN_DESKTOP`) the image is scaled to
  fill the desktop resolution with the same letterbox logic.
- Scaling uses `SDL_GetRendererOutputSize` queried each frame so that the
  correct physical pixel dimensions are always used without caching stale
  values.

### Mouse coordinate mapping

Mouse events from SDL carry physical screen coordinates. A
`window_to_logical` function in `2d_graph.h` converts physical coordinates
to the game's 640×480 (or 1280×900) logical space by computing the scale
factor and viewport offset from the renderer output size. This conversion
is applied to all `SDL_MOUSEMOTION`, `SDL_MOUSEBUTTONDOWN`, and
`SDL_MOUSEBUTTONUP` events.

### Keyboard shortcuts

- **Alt+Enter**: toggle between fullscreen and windowed mode at runtime.
  When returning to windowed mode the window is repositioned to the center
  of the desktop so the title bar is always accessible.

## Requirements

- ArcaOS 5.1 or eComStation 2.x
- SDL2 for OS/2 (and SDL2_image)
- GCC 9.2 / EMX toolchain (build only)

## Building

```
cd src
compile.cmd
```

The compiled `berusky.exe` must be run from the directory that contains the
`berusky\`, `GameData\`, `Graphics\`, and `Levels\` subdirectories.

## Original authors

- Martin Stransky &lt;stransky@anakreon.cz&gt; (original game, GPL v2+)

## License

GNU General Public License version 2 or later. See source files for the
full license text.

## Links
- https://github.com/OS2World/GAME-SDL-PUZZLE-Berusky
- https://www.anakreon.cz/berusky1.html
