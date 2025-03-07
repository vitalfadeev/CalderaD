// Copyright Danny Arends 2021
// Distributed under the GNU General Public License, Version 3
// See accompanying file LICENSE.txt or copy at https://www.gnu.org/licenses/gpl-3.0.en.html

import calderad;

void initSDL(ref App app) {
  loadSDL();
  toStdout("SDL loaded %d", loadedSDLVersion);
  auto initSDL = SDL_Init(SDL_INIT_EVERYTHING);
  toStdout("SDL initialized: %d", initSDL);

  auto loadTTF = loadSDLTTF();
  toStdout("TTF loaded: %d", loadTTF);
  auto initTTF = TTF_Init();
  toStdout("TTF init: %d", initTTF);

  auto loadImage = loadSDLImage();
  toStdout("IMAGE loaded %d", loadImage);
  auto initImage = IMG_Init(app.imageflags);
  toStdout("IMAGE init: %d", initImage);

  auto loadMixer = loadSDLMixer();
  toStdout("MIXER loaded %d", loadMixer);
  auto initMixer = Mix_Init(0);
  toStdout("MIXER init: %d", initMixer);
}

void createWindow(ref App app) {
  version(Android) {
    SDL_DisplayMode displayMode;
    if ( SDL_GetCurrentDisplayMode( 0, &displayMode ) == 0 ) {
      app.width = displayMode.w;
      app.height = displayMode.h;
    }
  }
  toStdout("Window Dimensions: %dx%d", app.width, app.height);
  app.ptr = SDL_CreateWindow(app.info.pApplicationName, app.pos[0], app.pos[1], app.width, app.height, app.flags);
  loadGlobalLevelFunctions(cast(PFN_vkGetInstanceProcAddr)SDL_Vulkan_GetVkGetInstanceProcAddr());
  toStdout("loadGlobalLevelFunctions loaded using SDL Vulkan");
}
