module button;

import std.stdio;

import derelict.sdl2.sdl;

import window;
import colour;

class Button {
	public SDL_Rect pos;

	public Colour fillColour;
	public Colour outlineColour;

	this(SDL_Rect pos = SDL_Rect(0,0,0,0), Colour fill = Colour(0,0,0), Colour outline = Colour(255, 255, 255)) {
		this.pos = pos;
		fillColour = fill;
		outlineColour = outline;
	}

	~this() {

	}

	public void HandleEvent(ref SDL_Event e) {

	}

	public void Render(Window window) {

		SDL_SetRenderDrawColor(window.renderer, fillColour.r, fillColour.g, fillColour.b, fillColour.a);
		SDL_RenderFillRect(window.renderer, &pos);

		SDL_SetRenderDrawColor(window.renderer, outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a);
		SDL_RenderDrawRect(window.renderer, &pos);
	}

	public bool MouseOver() {
		int x, y = 0;

		SDL_GetMouseState(&x, &y);

		bool isIn = true;

		if(x < pos.x) isIn = false;
		else if(x > pos.x + pos.w) isIn = false;
		else if (y < pos.y) isIn = false;
		else if (y > pos.y + pos.h) isIn = false;

		return isIn;
	}
}