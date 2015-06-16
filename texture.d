module texture;

import std.stdio;
import std.string;

import std.c.string;

import derelict.sdl2.sdl;

import window;

class Texture{
	public SDL_Texture* texture;
	public void* pixels;

	public int pitch, width, height;

	this() {

	}

	~this() {
		Free();
	}

	public bool LoadFromFile(string path, Window window) {
		Free();

		SDL_Texture* newTexture = null;

		SDL_Surface* load = SDL_LoadBMP(path.toStringz);

		if(load) {
			SDL_Surface* format = SDL_ConvertSurfaceFormat(load, SDL_PIXELFORMAT_RGBA8888, 0);
			if(format) {
				newTexture = SDL_CreateTexture(window.renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, format.w, format.h);

				if(newTexture) {
					SDL_SetTextureBlendMode(newTexture, SDL_BLENDMODE_BLEND);
					SDL_LockTexture(newTexture, null, &pixels, &pitch);
					memcpy(pixels, format.pixels, format.pitch * format.h);

					width = format.w;
					height = format.h;

					uint* pixelsTemp = cast(uint*)pixels;
					int pixelCount = (pitch / 4) * height;

					uint colorKey = SDL_MapRGB(format.format, 255, 0, 255);
					uint transparent = SDL_MapRGBA(format.format, 0, 255, 255, 0);

					for(int i = 0; i < pixelCount; ++i)
						if(pixelsTemp[i] == colorKey)
							pixelsTemp[i] = transparent;

					SDL_UnlockTexture(newTexture);
					pixels = null;
					writeln("Success: Loaded image: ", path);
				}
				else writeln("Warning: Unable to load image: ", path);
				SDL_FreeSurface(format);
			}
			SDL_FreeSurface(load);
		}
		texture = newTexture;
		return !!texture;
	}

	public void Render(int x, int y, Window window) {
		SDL_Rect quad = SDL_Rect(x, y, width, height);
		SDL_RenderCopyEx(window.renderer, texture, null, &quad, 0, null, SDL_FLIP_NONE);
	}

	public void CreateBlank(int width, int height, Window window, SDL_TextureAccess access = SDL_TEXTUREACCESS_STREAMING){
		texture = SDL_CreateTexture(window.renderer, SDL_PIXELFORMAT_RGBA8888, access, width, height);

		if(texture) {
			this.width = width;
			this.height = height;
		}
	}

	bool LockTexture() {
		bool success = true;
		if(pixels) success = false;
		else
			if(SDL_LockTexture(texture, null, &pixels, &pitch) != 0) success = false;
		return success;
	}

	bool UnlockTexture() {
		bool success = true;
		if (!pixels) success = false;
		else {
			SDL_UnlockTexture (texture);
			pixels = null;
			pitch = 0;
		}
		return success;
	}

	void Free() {
		if (texture) {
			SDL_DestroyTexture (texture);
			texture = null;
			width = 0;
			height = 0;
		}
	}
}