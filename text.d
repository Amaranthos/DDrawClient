module text;

import std.stdio;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import window;
import colour;
import font;

class RenderText {
	private int width = 0;
	private int height = 0;

	SDL_Texture* image;

	this() {
		image = null;
	}

	~this() {
		Free();
	}

	public void Free() {
		if(image){
			SDL_DestroyTexture(image);
			image = null;
			width = 0;
			height = 0;
		}
	}

	public bool CreateText(string text, Colour colour, Window window, Font font) {
		Free();

		SDL_Color temp = SDL_Color(colour.r, colour.g, colour.b);
		SDL_Surface* textImage = TTF_RenderUTF8_Blended(font.font, text.toStringz, temp);

		if(textImage) {
			image = SDL_CreateTextureFromSurface(window.renderer, textImage);

			if(image) {
				width = textImage.w;
				height = textImage.h;
			}
			else writeln("Warning: Unable to create texture from text! SDL Error: ", SDL_GetError());

			SDL_FreeSurface(textImage);
		}
		else writeln("Warning: Unable to render text! SDL_TTF Error: ", TTF_GetError());

		return !!image;
	}

	public void Render(int x, int y, Window window){
		SDL_Rect temp = SDL_Rect(x, y, width, height);
		SDL_RenderCopy(window.renderer, image, null, &temp);
	}

	public int Height() @property {
		return height;
	}

	public int Width() @property {
		return width;
	}
}