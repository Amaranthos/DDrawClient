module heatmap;

import std.stdio;
import std.string;

import derelict.sdl2.sdl;

import colour;

class HeatMap {
	public Colour[] mousePositions;

	private int width;
	private int height;

	this(int width, int height) {
		mousePositions = new Colour[width*height];
		this.width = width;
		this.height = height;
		for(int i = 0; i < width * height; i++) mousePositions[i] = Colour(0,0,0);
	}

	~this() {

	}

	public void SetMousePosition() {
		int x,y = 0;

		SDL_GetMouseState(&x, &y);

		for(int j = -1; j < 1; j++) {
			for(int k = -1; k < 1; k++) {
				if(((x + j) + (y + k) * width) > 0 && ((x + j) + (y + k) * width) < width * height) {
					Colour temp = mousePositions[(x + j) + (y + k) * width];

					int red = temp.r;
					red +=20;
					if(red > 255) red = 255;

					temp.r = cast(ubyte) red;

					mousePositions[(x + j) + (y + k) * width] = Colour(temp.r, temp.g, temp.b, temp.a);
				}
			}
		}
		//int blue = temp.b;
		//blue -=1;
		//if(blue > 255) blue = 255;

		//temp.b = cast(ubyte) blue;

		//int green = temp.g;
		//green -=5;
		//if(green > 255) green = 255;

		//temp.g = cast(ubyte) green;
	}

	void SaveHeatMap(string path) {

		SDL_Surface* outSurface = SDL_CreateRGBSurface(0, width, height, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);

		if(outSurface){
			uint* pixels = cast(uint*)outSurface.pixels;
			for (int i  = 0; i <  width * height; i++) {
				pixels[i] = SDL_MapRGB(outSurface.format, mousePositions[i].r, mousePositions[i].g, mousePositions[i].b);

				//for(int j = -1; j < 1; j++) {
				//	for(int k = -1; k < 1; k++) {
				//		if((i+j+k*width) > 0 && (i+j+k*width) < width * height)	pixels[i+j+k*width] = SDL_MapRGB(outSurface.format, mousePositions[i].r, mousePositions[i].g, mousePositions[i].b);
				//	}
				//}
			}
		}

		SDL_SaveBMP(outSurface, path.toStringz);

		SDL_FreeSurface(outSurface);
	}
}		