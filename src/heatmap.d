module heatmap;

import std.stdio;
import std.string;

import derelict.sdl2.sdl;

import colour;

class HeatMap {
	public float[] mousePositions;

	private int width;
	private int height;

	this(int width, int height) {
		mousePositions = new float[width*height];
		this.width = width;
		this.height = height;
		for(int i = 0; i < width * height; i++) mousePositions[i] = 0.0;
	}

	~this() {

	}

	public void SetMousePosition() {
		int x,y = 0;

		SDL_GetMouseState(&x, &y);

		for(int j = -3; j <= 3; j++) {
			for(int k = -3; k <= 3; k++) {
				if(((x + j) + (y + k) * width) > 0 && ((x + j) + (y + k) * width) < width * height){
					if((j == -3 || j == 3) && (k == -3 || k == 3))
						mousePositions[(x + j) + (y + k) * width] += 0.125;
					else
						mousePositions[(x + j) + (y + k) * width] += 0.25;
				}	
			}
		}


		for(int j = -2; j <= 2; j++) {
			for(int k = -2; k <= 2; k++) {
				if(((x + j) + (y + k) * width) > 0 && ((x + j) + (y + k) * width) < width * height){
					if((j == -2 || j == 2) && (k == -2 || k == 2))
						mousePositions[(x + j) + (y + k) * width] += 0.25;
					else
						mousePositions[(x + j) + (y + k) * width] += 0.5;
				}	
			}
		}

		for(int j = -1; j <= 1; j++) {
			for(int k = -1; k <= 1; k++) {
				if(((x + j) + (y + k) * width) > 0 && ((x + j) + (y + k) * width) < width * height){
					if((j == -1 || j == 1) && (k == -1 || k == 1))
						mousePositions[(x + j) + (y + k) * width] += 0.5;
					else
						mousePositions[(x + j) + (y + k) * width] += 1;
				}	
			}
		}

		mousePositions[x + y * width] += 2;
	}

	void SaveHeatMap(string path) {

		SDL_Surface* outSurface = SDL_CreateRGBSurface(0, width, height, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);

		if(outSurface){
			uint* pixels = cast(uint*)outSurface.pixels;
			float greatest = HeatMapGreatest();
			for (int i  = 0; i <  width * height; i++) {
				Colour temp = Colour.Lerp(Colour.Blue, Colour.Red, Scale(greatest, i));
				pixels[i] = SDL_MapRGB(outSurface.format, temp.r, temp.g, temp.b);
			}
		}

		SDL_SaveBMP(outSurface, path.toStringz);

		SDL_FreeSurface(outSurface);
	}

	private float HeatMapGreatest() {
		float greatest = 0.0;

		for (int i = 0; i < mousePositions.length; i++){
			if(mousePositions[i] > greatest)
				greatest = mousePositions[i];
		}

		return greatest;
	}

	private float Scale(float greatest, int index) {
		return mousePositions[index]/(0.1 * greatest);
	}
}