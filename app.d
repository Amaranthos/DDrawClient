module app;

import std.stdio;
import std.socket;

import derelict.sdl2.sdl;

import window;
import colour;
import packets;

class App{
	//Member variables
	static App inst;

	static const WIDTH = 720;
	static const HEIGHT = 720;

	Window window;

	Socket sendSocket;
	Address sendAddress;

	//Member functions
	private this() {
		window = new Window();
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
				
				InitialiseSocket("127.0.0.1", 1300);
			}
		}
		return success;
	}

	public void Update() {
		bool quit = false;

		SDL_Event event;

		PacketBox box = PacketBox(3, 0, 0, 100, 100, 20 / 255.0f, 135 / 255.0f, 242 / 255.0f);
		//box.x = 0;
		//box.y = 0;
		//box.w = 100;
		//box.h = 100;
		//box.r = 20 / 255.0f;
		//box.g = 135 / 255.0f;
		//box.b = 242 / 255.0f;

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

	public void Close() {
		SDL_Quit();
	}
}