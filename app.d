module app;

import std.stdio;
import std.socket;
import std.math;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import window;
import colour;
import packets;
import font;
import text;

class App{
	//Member variables
	static App inst;

	static const WIDTH = 720;
	static const HEIGHT = 720;

	static const CANVAS_WIDTH = 512;
	static const CANVAS_HEIGHT = 512;

	Window window;

	SDL_Rect canvas;
	Colour canvasColour = Colour(255, 255, 255);

	PacketPixel pixel = PacketPixel(1, 0, 0, 0, 0, 0);
	PacketLine line = PacketLine(2, 0, 0, 0, 0, 0, 0, 0);
	PacketBox box = PacketBox(3, 0, 0, 50, 50, 0, 0, 0);
	PacketCircle circle = PacketCircle(4, 0, 0, 50, 0, 0, 0);
	Colour drawColour = Colour(0, 0, 0);

	int lineX = 0;
	int lineY = 0;
	int linePosSet = 0;

	RenderText choices;

	Socket sendSocket;
	Address sendAddress;

	//Member functions
	private this() {
		window = new Window();
		choices = new RenderText();
		canvas = SDL_Rect((WIDTH - CANVAS_WIDTH)/2, (HEIGHT - CANVAS_HEIGHT)/2, CANVAS_WIDTH, CANVAS_HEIGHT);
	}

	static public App Inst() {
		if(!inst) inst = new App();
		return inst;
	}

	public bool Init() {
		bool success = true;

		if(SDL_Init(SDL_INIT_EVERYTHING) <0) {
			writeln("Warning: SDL could not initialise! SDL Error: ", SDL_GetError());
			success = false;
		}
		else {
			if(!SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1")) writeln("Warning: Linear texture filtering not enabled!");

			if(!window.Init(WIDTH, HEIGHT, "Draw Client", Colour(0,0,0))) success = false;
			else {
				if(TTF_Init() == -1) {
					writeln("Warning: SDL_TTF could not initialise! SDL_TTF Error: ", TTF_GetError());
					success = false;
				}
				else writeln("Success: SDL_TTF initialised!");

				InitialiseSocket("127.0.0.1", 1300);
			}
		}
		return success;
	}

	public void Update() {
		bool quit = false;

		SDL_Event event;

		int toolChoice= 1;

		CreateText();

		while(!quit) {
			stdout.flush();
			while(SDL_PollEvent(&event) != 0) {
				if(event.type == SDL_QUIT) quit = true;
				else if (event.type == SDL_KEYDOWN) {
					switch(event.key.keysym.sym){
						case SDLK_1:
							toolChoice = 1;
							break;

						case SDLK_2:
							toolChoice = 2;
							break;

						case SDLK_3:
							toolChoice = 3;
							break;

						case SDLK_4:
							toolChoice = 4;
							break;

						case SDLK_ESCAPE:
							quit = true;
							break;

						default:
							break;
					}
				}
				window.HandleEvent(event);

				switch(toolChoice) {
					case 1:
						DrawPixel(event);
						break;

					case 2:
						DrawLine(event);
						break;

					case 3:
						DrawBox(event);
						break;

					case 4:
						DrawCircle(event);
						break;

					default:
						break;
				}
			}

			window.Clear();

			DrawCanvas();

			DrawText();

			window.Render();
		}
	}

	private void CreateText() {
		choices.CreateText("~ Press 1 for pixels :: Press 2 for lines :: Press 3 for boxes :: Press 4 for circles ~", Colour(255, 255, 255), window);
	}

	private void DrawPixel(ref SDL_Event e){
		if(e.type == SDL_MOUSEBUTTONDOWN && SDL_BUTTON(SDL_BUTTON_LEFT) && MouseOverCanvas){
			int x, y = 0;

			MousePosOnCanvas(x, y);

			pixel.x = x;
			pixel.y = y;

			pixel.r = drawColour.r / 255.0f;
			pixel.g = drawColour.g / 255.0f;
			pixel.b = drawColour.b / 255.0f;

			SendPacket(pixel);
		}
	}

	private void DrawLine(ref SDL_Event e){
			if(e.type == SDL_MOUSEBUTTONDOWN && SDL_BUTTON(SDL_BUTTON_LEFT) && MouseOverCanvas){
			int x, y = 0;

			MousePosOnCanvas(x, y);

			if(linePosSet == 0) {
				lineX = x;
				lineY = y;
				
			}
			else {
				line.x1 = lineX;
				line.y1 = lineY;

				line.x2 = x;
				line.y2 = y;

				line.r = drawColour.r / 255.0f;
				line.g = drawColour.g / 255.0f;
				line.b = drawColour.b / 255.0f;

				SendPacket(line);
			}			
			linePosSet = 1 - linePosSet;
		}
	}

	private void DrawBox(ref SDL_Event e){
			if(e.type == SDL_MOUSEBUTTONDOWN && SDL_BUTTON(SDL_BUTTON_LEFT) && MouseOverCanvas){
			int x, y = 0;

			MousePosOnCanvas(x, y);

			box.x = x - box.w/2;
			box.y = y - box.h/2;

			box.r = drawColour.r / 255.0f;
			box.g = drawColour.g / 255.0f;
			box.b = drawColour.b / 255.0f;

			SendPacket(box);
		}
	}

	private void DrawCircle(ref SDL_Event e){
			if(e.type == SDL_MOUSEBUTTONDOWN && SDL_BUTTON(SDL_BUTTON_LEFT) && MouseOverCanvas){
			int x, y = 0;

			MousePosOnCanvas(x, y);

			circle.x = x - circle.radius/2;
			circle.y = y - circle.radius/2;

			circle.r = drawColour.r / 255.0f;
			circle.g = drawColour.g / 255.0f;
			circle.b = drawColour.b / 255.0f;

			SendPacket(circle);
		}
	}

	private bool MouseOverCanvas(){
		int x, y = 0;

		SDL_GetMouseState(&x, &y);

		bool isIn = true;

		if(x < canvas.x) isIn = false;
		else if(x > canvas.x + canvas.w) isIn = false;
		else if (y < canvas.y) isIn = false;
		else if (y > canvas.y + canvas.h) isIn = false;

		return isIn;
	}

	private void MousePosOnCanvas(ref int x, ref int y) {
		SDL_GetMouseState(&x, &y);
		x -= canvas.x;
		y -= canvas.y;
	}

	private void SendPacket(T)(ref T packet) {
		int res = sendSocket.sendTo(cast(void[])[packet],sendAddress);

		if(res == Socket.ERROR) writeln("Warning: Failed to send packet!");
		else writeln("Success: Packet size of ", res, " sent!");
	}

	private void InitialiseSocket(const char[] hostAddress, ushort port) {
		sendSocket = new UdpSocket();
		sendAddress = parseAddress(hostAddress, port);
	}

	private void DrawCanvas() {
		SDL_SetRenderDrawColor(window.renderer, canvasColour.r, canvasColour.g, canvasColour.b, canvasColour.a);
		SDL_RenderFillRect(window.renderer, &canvas);
	}

	private void DrawText() {
		choices.Render(WIDTH/2 - choices.Width/2, HEIGHT/2 - choices.Height/2, window);
	}

	public void Close() {
		TTF_Quit();
		SDL_Quit();
	}
}