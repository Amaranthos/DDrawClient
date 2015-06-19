module slider;

import std.stdio;

import derelict.sdl2.sdl;

import texture;
import button;
import colour;
import window;

class Slider{
	public Button handle;
	public SDL_Rect bar;

	public Colour barColour;
	public Colour outlineColour;

	public float sliderValue;

	this(SDL_Rect bar, Colour barColour = Colour.Black, Colour outlineColour = Colour.Silver, float sliderValue = 0.5) {
		this.bar = bar;
		this.barColour = barColour;
		this.outlineColour = outlineColour;
		this.sliderValue = sliderValue;
		handle = new Button(SDL_Rect(cast(int)(sliderValue * bar.w + bar.x), bar.y, bar.h, bar.h), Colour.Black, Colour.Silver);
	}

	public void HandleEvent(ref SDL_Event e) {
		int x,y = 0;
		uint mouseState = SDL_GetMouseState(null, null);
		//if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT){
		if(SDL_GetMouseState(null, null) & SDL_BUTTON(SDL_BUTTON_LEFT)){
		 	if(MouseOver(x,y)) {
				sliderValue = (cast(float)x - cast(float)bar.x) / cast(float)bar.w;
				handle.pos.x = (cast(int)(sliderValue * bar.w + bar.x));
			}
		}
	}

	public void Render(Window window) {
		SDL_SetRenderDrawColor(window.renderer, barColour.r, barColour.g, barColour.b, barColour.a);
		SDL_RenderFillRect(window.renderer, &bar);

		SDL_SetRenderDrawColor(window.renderer, outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a);
		SDL_RenderDrawRect(window.renderer, &bar);

		handle.Render(window);
	}

	public bool MouseOver(ref int x, ref int y) {
		SDL_GetMouseState(&x, &y);

		bool isIn = true;

		if(x < bar.x) isIn = false;
		else if(x > bar.x + bar.w) isIn = false;
		else if (y < bar.y) isIn = false;
		else if (y > bar.y + bar.h) isIn = false;

		//x -= bar.x;
		//y -= bar.y;
	
		return isIn;
	}
}