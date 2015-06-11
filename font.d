module font;

import std.stdio;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

class Font {
	public TTF_Font* font;

	public this() {
		font = null;
	}

	public ~this() {
	
	}

	public void LoadFont(string path, int size) {
		font = TTF_OpenFont(path.toStringz, size);

		if(font) writeln("Success: Loaded font '", path, "'!");
		else writeln("Warning: Unable to laod font '", path, "' SDL_TTF Error: ", TTF_GetError());
	}
}