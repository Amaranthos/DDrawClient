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

	public float sliderValue;

	this(Button handle, SDL_Rect bar, Colour barColour = Colour(255, 255, 255), float sliderValue = 0.5) {
		this.handle = handle;
		this.bar = bar;
		this.barColour = barColour;
		this.sliderValue = sliderValue;
	}

	public void HandleEvent(ref SDL_Event e) {
		int x,y = 0;
		if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT){
			writeln("Left button pressed!");
		 	if(MouseOver(x,y)) {
				//if(x > bar.x && x < bar.w) {
				//	if(y > bar.y && y < bar.h) {
				//	}
				//}
				writeln("X: ", x, " Y: ", y);
				sliderValue = (x - bar.x)/(bar.w - bar.x);
				//writeln((x - bar.x)/(bar.w - bar.x));
				writeln(x-bar.x);
			}
		}
		//writeln(sliderValue);
	}

	public void Render(Window window) {
		SDL_SetRenderDrawColor(window.renderer, barColour.r, barColour.g, barColour.b, barColour.a);
		SDL_RenderFillRect(window.renderer, &bar);

		handle.Render(window);
	}

	public bool MouseOver(ref int x, ref int y) {
		SDL_GetMouseState(&x, &y);

		bool isIn = true;

		if(x < bar.x) isIn = false;
		else if(x > bar.x + bar.w) isIn = false;
		else if (y < bar.y) isIn = false;
		else if (y > bar.y + bar.h) isIn = false;

		x -= bar.x;
		y -= bar.y;
	
		return isIn;
	}
}