module app;

import std.stdio;
import std.math;
import std.conv;
import std.array;
import std.algorithm;

import core.time;

import derelict.sdl2.sdl;

import window;
import colour;
import packets;
import font;
import text;
import button;
import heatmap;
import comms;

static string ip = "127.0.0.1";
//static string ip = "10.40.60.35";

static int PADDING = 200;

class App{
	//Member variables
	static App inst;

	Window window = new Window();;

	Comms comms = new Comms();

	PacketPixel pixel = PacketPixel(1, 0, 0, 0, 0, 0);
	PacketLine line = PacketLine(2, 0, 0, 0, 0, 0, 0, 0);
	PacketBox box = PacketBox(3, 0, 0, 0, 0, 0, 0, 0);
	PacketCircle circle = PacketCircle(4, 0, 0, 200, 0, 0, 0);
	PacketClientCursor cursor = PacketClientCursor(6, CursorInfo(0,0));
	PacketServerInfo serverInfo = PacketServerInfo(7, 512, 512);
	
	Colour drawColour = Colour(236, 85, 142);

	int lineX = 0;
	int lineY = 0;
	int firstPosSet = 0;

	bool dRed = false;
	bool dGreen = false;
	bool dBlue = false;

	bool dTool = false;
	bool dW = false;
	bool dH = false;
	bool dR = false;

	Button canvas;
	Button colourPicker;

	Button b_pixel;
	Button b_line;
	Button b_box;
	Button b_circle;

	HeatMap heatMap;

	//Member functions
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

			comms.InitialiseSocket(ip, 1300);

			PacketClientAnnounce announce;

			comms.SendPacket(announce);
			byte[] response = comms.RecievePacket();

			if(GetInt(response, 0) == 7) serverInfo = (cast(PacketServerInfo[])response)[0];

			if(!window.Init(serverInfo.w + PADDING, serverInfo.h + PADDING, "Draw Client", Colour(0,0,0))) success = false;
			else {
				CreateDrawElements();
				heatMap = new HeatMap(window.Width, window.Height);
			}
		}
		return success;
	}

	public void Update() {
			
		bool quit = false;
		SDL_Event event;
		int toolChoice= 1;

		
		
		while(!quit) {
			stdout.flush();
			while(SDL_PollEvent(&event) != 0) {
				if(event.type == SDL_QUIT) quit = true;
				else if (event.type == SDL_KEYDOWN) {
					switch(event.key.keysym.sym){
						case SDLK_1: toolChoice = 1; break;

						case SDLK_2: toolChoice = 2; break;

						case SDLK_3: toolChoice = 3; break;

						case SDLK_4: toolChoice = 4; break;

						case SDLK_ESCAPE: quit = true; break;

						default: break;
					}
				}
				window.HandleEvent(event);

				int x, y = 0;
				if(event.type == SDL_MOUSEBUTTONDOWN && event.button.button == SDL_BUTTON_LEFT && canvas.MouseOver(x,y)) {
					switch(toolChoice) {
						case 1: DrawPixel(x, y); break;

						case 2: DrawLine(x, y); break;

						case 3: DrawBox(x, y); break;

						case 4: DrawCircle(x, y); break;

						default: break;
					}
				}
			}
			window.Clear();

			DrawEverything();
			PerformActions();
	
			window.Render();
		}
		heatMap.SaveHeatMap("heatmap.bmp");
	}

	private void DrawEverything() {
		DrawButtons();
	}

	private void PerformActions() {
		int x,y = 0;
		SDL_GetMouseState(&x, &y);
		cursor.cursor = CursorInfo(x,y, drawColour.r);
		comms.SendPacket(cursor, false);

		byte[] serverResponse = comms.RecievePacket(false);
		heatMap.SetMousePosition();
	}

	private void CreateDrawElements() {
		canvas = new Button(SDL_Rect((window.Width - serverInfo.w)/2, (window.Height - serverInfo.h)/2, serverInfo.w, serverInfo.h), Colour.White, Colour(127, 127, 127));
		colourPicker = new Button(SDL_Rect(canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y, 32, 32), drawColour, Colour.White);

		int b_Padding_1 = 5;

		b_pixel = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 0 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);
		b_line = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 1 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);
		b_box = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 2 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);
		b_circle = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 3 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);;
	}

	private void DrawPixel(int x, int y){
			pixel.x = x;
			pixel.y = y;

			pixel.r = drawColour.r / 255.0f;
			pixel.g = drawColour.g / 255.0f;
			pixel.b = drawColour.b / 255.0f;

			comms.SendPacket(pixel);
	}

	private void DrawLine(int x, int y){
		if(firstPosSet == 0) {
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

			comms.SendPacket(line);
		}			
		firstPosSet = 1 - firstPosSet;
	}

	private void DrawBox(int x, int y){
		if(firstPosSet == 0){
			box.x = x;
			box.y = y;
		}
		else {
			box.w = x;
			box.h = y;

			box.r = drawColour.r / 255.0f;
			box.g = drawColour.g / 255.0f;
			box.b = drawColour.b / 255.0f;

			SDL_Rect temp = SDL_Rect(box.x, box.y, box.w, box.h);
			temp = BuildRect(temp);

			box.x = temp.x;
			box.y = temp.y;
			box.w = temp.w;
			box.h = temp.h;

			comms.SendPacket(box);
		}
		firstPosSet = 1 - firstPosSet;
	}

	private void DrawCircle(int x, int y){
		if(firstPosSet == 0){
			circle.x = x;
			circle.y = y;
		}
		else {
			int rad = cast(int) sqrt(cast(float)((x - circle.x) * (x - circle.x) + (y - circle.y) * (y- circle.y)));

			circle.radius = rad;

			circle.r = drawColour.r / 255.0f;
			circle.g = drawColour.g / 255.0f;
			circle.b = drawColour.b / 255.0f;

			comms.SendPacket(circle);
		}
		firstPosSet = 1 - firstPosSet;	
	}

	private void DrawButtons() {
		canvas.Render(window);
		colourPicker.Render(window);

		b_pixel.Render(window);
		b_line.Render(window);
		b_box.Render(window);
		b_circle.Render(window);
	}

	private SDL_Rect BuildRect (ref SDL_Rect rect) {
		int x = rect.x;
		int y = rect.y;
		int w = rect.w;
		int h = rect.h;

		rect.x = min(x, w);
		rect.w = max(x, w);

		rect.y = min(y, h);
		rect.h = max(y, h);

		return rect;
	}

	public void Close() {
		SDL_Quit();
	}
}