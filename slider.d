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

	private bool isClicked = false;
	private int mouseX = 0;

	this(Button handle, SDL_Rect bar, Colour barColour = Colour(255, 255, 255), float sliderValue = 0.5) {
		this.handle = handle;
		this.bar = bar;
		this.barColour = barColour;
		this.sliderValue = sliderValue;
		this.handle.pos.y = (bar.y + bar.h)/2 - this.handle.pos.h/2;
	}

	public void HandleEvent(ref SDL_Event e) {
		int y = 0;
		if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT && handle.MouseOver(mouseX, y) && !isClicked) {
				handle.isSelected = true;
				isClicked = true;
		}
		if(e.type == SDL_MOUSEBUTTONUP && e.button.button == SDL_BUTTON_LEFT && isClicked){
			int x = 0;
			SDL_GetMouseState(&x, null);
			float dX =  (mouseX - x) / bar.w;
			sliderValue = 1 * dX;

			handle.pos.x = cast(int)((bar.x + bar.w) * sliderValue - handle.pos.w/2);

			handle.isSelected = false;
			isClicked = false;
		}
	}

	public void Render(Window window) {
		SDL_SetRenderDrawColor(window.renderer, barColour.r, barColour.g, barColour.b, barColour.a);
		SDL_RenderFillRect(window.renderer, &bar);

		handle.Render(window);
	}
}