module app;

import std.stdio;
import std.socket;
import std.math;
import std.conv;
import std.array;

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
	
	SDL_Rect colourPicker;
	Colour drawColour = Colour(0, 0, 0);

	int lineX = 0;
	int lineY = 0;
	int linePosSet = 0;

	Font font;
	Font smallFont;
	RenderText choices;
	RenderText colourTitle;
	RenderText redField;
	RenderText greenField;
	RenderText blueField;

	bool dRed = false;
	bool dGreen = false;
	bool dBlue = false;
	//bool 

	Socket sendSocket;
	Address sendAddress;

	Colour white = Colour(255, 255, 255);

	//Member functions
	private this() {
		//Fonts
		font = new Font();
		smallFont = new Font();
		window = new Window();

		//Text
		choices = new RenderText();
		colourTitle = new RenderText();
		redField = new RenderText();
		greenField = new RenderText();
		blueField = new RenderText();

		// Rects
		canvas = SDL_Rect((WIDTH - CANVAS_WIDTH)/2, (HEIGHT - CANVAS_HEIGHT)/2, CANVAS_WIDTH, CANVAS_HEIGHT);
		colourPicker = SDL_Rect(canvas.x/2 - 16, HEIGHT/4, 32, 32);
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

				CheckForChangedText(event);
			}

			window.Clear();

			UpdateText();

			DrawCanvas();
			DrawColourPicker();
			DrawText();

			window.Render();
		}
	}

	private void CreateText() {
		font.LoadFont("arial.ttf", 18);
		smallFont.LoadFont("arial.ttf", 12);
		choices.CreateText("~ Press 1 for pixels :: Press 2 for lines :: Press 3 for boxes :: Press 4 for circles ~", white, window, font);
		colourTitle.CreateText("Colour", white, window, font);
		redField.CreateText("Red: " ~ to!string(drawColour.r), white, window, smallFont);
		greenField.CreateText("Green: " ~ to!string(drawColour.g), white, window, smallFont);
		blueField.CreateText("Blue: " ~ to!string(drawColour.b), white, window, smallFont);
	}

	private void UpdateText() {
		if(dRed) {
			redField.CreateText("Red: " ~ to!string(drawColour.r), white, window, smallFont);
			dRed = false;
		}

		if(dGreen){
			greenField.CreateText("Green: " ~ to!string(drawColour.g), white, window, smallFont);
			dGreen = false;
		}

		if(dBlue) {
			blueField.CreateText("Blue: " ~ to!string(drawColour.b), white, window, smallFont);
			dBlue = false;
		}
	}

	private void CheckForChangedText(ref SDL_Event e) {
		if(e.type == SDL_MOUSEBUTTONDOWN && SDL_BUTTON(SDL_BUTTON_LEFT)) {

			if(MouseOverRect(redField.pos))
				if(GetInputString(e, drawColour.r)) 
					dRed = true;
			else if(MouseOverRect(greenField.pos))
				if(GetInputString(e, drawColour.g)) 
					dGreen = true;
			else if(MouseOverRect(blueField.pos))
				if(GetInputString(e, drawColour.b)) 
					dBlue = true;
		}
	}

	private bool GetInputString(ref SDL_Event e, ref ubyte colourChannel) {

		string text = to!string(colourChannel);
	
		bool ret = false;

		if(e.type == SDL_KEYDOWN) {
			if(e.key.keysym.sym == SDLK_BACKSPACE && text.length > 0) {
				text.popBack();
				ret = true;
			}
			if((e.key.keysym.unicode >= cast(ushort)'0') && (e.key.keysym.unicode <= cast(ushort)'9')){
				text ~= cast(ubyte)e.key.keysym.unicode;
				ret = true;
			}
		}
		
		if(ret) colourChannel = to!ubyte(text);
		return ret;
	}

	private void DrawPixel(ref SDL_Event e){
		if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT && MouseOverRect(canvas)){
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
			if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT && MouseOverRect(canvas)){
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
			if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT && MouseOverRect(canvas)){
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
			if(e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT && MouseOverRect(canvas)){
			int x, y = 0;

			MousePosOnCanvas(x, y);

			circle.x = x;
			circle.y = y;

			circle.r = drawColour.r / 255.0f;
			circle.g = drawColour.g / 255.0f;
			circle.b = drawColour.b / 255.0f;

			SendPacket(circle);
		}
	}

	private bool MouseOverRect(ref SDL_Rect rect){
		int x, y = 0;

		SDL_GetMouseState(&x, &y);

		bool isIn = true;

		if(x < rect.x) isIn = false;
		else if(x > rect.x + rect.w) isIn = false;
		else if (y < rect.y) isIn = false;
		else if (y > rect.y + rect.h) isIn = false;

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

	private void DrawColourPicker() {
		SDL_SetRenderDrawColor(window.renderer, drawColour.r, drawColour.g, drawColour.b, drawColour.a);
		SDL_RenderFillRect(window.renderer, &colourPicker);

		SDL_SetRenderDrawColor(window.renderer, white.r, white.g, white.b, white.a);
		SDL_RenderDrawRect(window.renderer, &colourPicker);
	}

	private void DrawText() {
		int padding_1 = 10;
		choices.Render(WIDTH/2 - choices.pos.w/2, canvas.y/2 - choices.pos.h/2, window);
		colourTitle.Render(canvas.x/2 - colourTitle.pos.w/2, colourPicker.y + colourPicker.h + colourTitle.pos.h/2, window);
		redField.Render(canvas.x/2 - colourTitle.pos.w/2, colourPicker.y + colourPicker.h + colourTitle.pos.h + redField.pos.h/2 + padding_1, window);
		greenField.Render(canvas.x/2 - colourTitle.pos.w/2, colourPicker.y + colourPicker.h + colourTitle.pos.h + redField.pos.h + greenField.pos.h/2 + padding_1, window);
		blueField.Render(canvas.x/2 - colourTitle.pos.w/2, colourPicker.y + colourPicker.h + colourTitle.pos.h + redField.pos.h + greenField.pos.h + blueField.pos.h/2 + padding_1, window);
	}

	public void Close() {
		TTF_Quit();
		SDL_Quit();
	}
}