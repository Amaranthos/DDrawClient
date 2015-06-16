module button;

import std.stdio;


import derelict.sdl2.sdl;

import window;
import colour;
import texture;

class Button {
	public SDL_Rect pos;

	public Colour fillColour;
	public Colour outlineColour;
	public Colour selectColour;

	public Texture image = null;

	public bool isSelected = false;

	this(SDL_Rect pos = SDL_Rect(0,0,0,0), Colour fill = Colour(0,0,0), Colour outline = Colour(255, 255, 255), Colour select = Colour.Yellow) {
		this.pos = pos;
		fillColour = fill;
		outlineColour = outline;
		selectColour = select;
	}

	~this() {

	}

	public void HandleEvent(ref SDL_Event e) {

	}

	public bool LoadButtonImage(string path, Window window) {
		image = new Texture();
		return image.LoadFromFile(path, window);
	}

	public void Render(Window window) {
		SDL_SetRenderDrawColor(window.renderer, fillColour.r, fillColour.g, fillColour.b, fillColour.a);
		SDL_RenderFillRect(window.renderer, &pos);
		
		if(image)
			image.Render(pos.x, pos.y, window);
		if(isSelected)
			SDL_SetRenderDrawColor(window.renderer, selectColour.r, selectColour.g, selectColour.b, selectColour.a);
		else
			SDL_SetRenderDrawColor(window.renderer, outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a);
		SDL_RenderDrawRect(window.renderer, &pos);
	}

	public bool MouseOver(ref int x, ref int y) {
		SDL_GetMouseState(&x, &y);

		bool isIn = true;

		if(x < pos.x) isIn = false;
		else if(x > pos.x + pos.w) isIn = false;
		else if (y < pos.y) isIn = false;
		else if (y > pos.y + pos.h) isIn = false;

		x -= pos.x;
		y -= pos.y;
		
		return isIn;
	}
}