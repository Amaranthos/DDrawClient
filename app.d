module app;

import std.stdio;
import std.socket;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import window;
import colour;
import packets;

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

	Socket sendSocket;
	Address sendAddress;

	//Member functions
	private this() {
		window = new Window();
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

		PacketBox box = PacketBox(3, 0, 0, 100, 100, 20 / 255.0f, 135 / 255.0f, 242 / 255.0f);
	
		PacketCircle circle = PacketCircle(4, 200, 155, 20, 42 / 255.0f, 74 / 255.0f, 323 / 255.0f);

		while(!quit) {
			stdout.flush();
			while(SDL_PollEvent(&event) != 0) {
				if(event.type == SDL_QUIT) quit = true;
				else if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE) quit = true;
				else if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_SPACE) SendPacket(box);
				else if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_RETURN) SendPacket (circle);
				window.HandleEvent(event);
			}

			window.Clear();

			DrawCanvas();


			window.Render();
		}
	}

	public void SendPacket(T)(ref T packet) {
		int res = sendSocket.sendTo(cast(void[])[packet],sendAddress);

		if(res == Socket.ERROR) writeln("Warning: Failed to send packet!");
		else writeln("Success: Packet size of ", res, " sent!");
	}

	public void InitialiseSocket(const char[] hostAddress, ushort port) {
		sendSocket = new UdpSocket();
		sendAddress = parseAddress(hostAddress, port);
	}

	private void DrawCanvas() {
		SDL_SetRenderDrawColor(window.renderer, canvasColour.r, canvasColour.g, canvasColour.b, canvasColour.a);
		SDL_RenderFillRect(window.renderer, &canvas);
	}

	public void Close() {
		TTF_Quit();
		SDL_Quit();
	}
}