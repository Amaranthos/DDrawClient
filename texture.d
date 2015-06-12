module texture;

import std.stdio;

import derelict.sdl2.sdl;

class Texture{
	public SDL_Texture* texture;
	public void* pixels;

	public int pitch, width, height;

	this() {

	}

	~this() {
		Free();
	}

	//void LoadFromFile() {

	//}

	//void Render() {

	//}

	void CreateBlank(int width, int height, Window window, SDL_TextureAcess access = SDL_TEXTUREACCESS_STREAMING){
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
			pixels = nullptr;
			pitch = 0;
		}
		return success;
	}

	void* Pixels() {
		return pixels;
	}

	void Free() {
		if (texture) {
			SDL_DestroyTexture (texture);
			texture = nullptr;
			width = 0;
			height = 0;
		}
	}
}