module heatmap;

import std.stiod;

import derelict.sdl2.sdl;

import window;
import colour;

class HeatMap {
	public Colour[] mousePositions;

	private int width;
	private int height;

	this(int width, int height) {
		surface = null;
		mousePositions = new Colour[width*height];
		this.width = width;
		this.height = height;
	}

	~this() {

	}

	public void SetMousePosition() {
		int x,y = 0;

		SDL_GetMouseState(&x, &y);

		mousePositions[x + y * width] = ;
	}

	void SaveHeatMap(string path, Window window) {
		SDL_Renderer* tempRenderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

		SDL_Surface* saveSurface = null;
		SDL_Surface* infoSurface = SDL_GetWindowSurface(window.window);

		if(infoSurface != null) {
			ubyte* pixels = new ubyte[infoSurface.w * infoSurface.h * infoSurface.format.BytesPerPixel];

			if(pixels != 0){
				if(!SDL_RenderReadPixels)
			}
			else writeln("Warning: Failed to allocate memory for pixel data!");
		}
		else writeln("Warning: Failed to create info surface to save: ", path);
	}
}		