module app;

import std.stdio;

import derelict.sdl2.sdl;

import window;
import colour;

class App{
	//Member variables
	static App inst;

	static const WIDTH = 720;
	static const HEIGHT = 720;

	Window window;

	//Member functions
	private this() {
		
	}

	static public App Inst() {
		if(!inst) inst = new App();
		return inst;
	}

	public bool Init() {
		bool success = true;

		if(SDL_Init(SDL_INIT_EVERYTHING) <0) {
			writeln("Warning: SDL could not initialise! SDL Error: %s\n", SDL_GetError);
			success = false;
		}
		else {
			if(!SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1")) writeln("Warning: Linear texture filtering not enabled!\n");

			if(!window.Init(WIDTH, HEIGHT, "Draw Client", Colour(0,0,0))) success = false;
		}
		return success;
	}

	public void Update() {

	}

	public void Close() {
		SDL_Quit();
	}
}