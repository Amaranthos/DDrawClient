module app;

import std.stdio;
import std.math;
import std.conv;
import std.array;
import std.algorithm;
import std.file;
import std.string;

import core.time;
import core.thread;

import derelict.sdl2.sdl;

import window;
import colour;
import packets;
import button;
import heatmap;
import comms;
import texture;
import slider;

static int PADDING = 200;

static bool isLogging = true;

class App{
	//Member variables
	static App inst;

	string ip = "";

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

	Button canvas;
	Button colourPicker;

	Button b_pixel;
	Button b_line;
	Button b_box;
	Button b_circle;

	Slider s_red;
	Slider s_green;
	Slider s_blue;

	HeatMap heatMap;

	File file;

	//Member functions
	static public App Inst() {
		if(!inst) inst = new App();
		return inst;
	}

	public bool Init() {
		if(isLogging) file =  File("log.txt", "w");
		if(isLogging) file.writeln(stderr, "Initialising");

		bool success = true;

		if(SDL_Init(SDL_INIT_EVERYTHING) <0) {
			writeln("Warning: SDL could not initialise! SDL Error: ", SDL_GetError());
			success = false;
		}
		else {
			if(!SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1")) writeln("Warning: Linear texture filtering not enabled!");

			writeln("Input server ip (XXX.XXX.XXX.XXX): ");
			ip = strip(stdin.readln());

			comms.InitialiseSocket(ip, 1300);

			PacketClientAnnounce announce;

			comms.SendPacket(announce);
			byte[] response = comms.RecievePacket();

			if(GetInt(response, 0) == 7){
				serverInfo = (cast(PacketServerInfo[])response)[0];
				writeln("Success: Conncected to Draw Server!");
			}
				

			if(!window.Init(serverInfo.w + PADDING, serverInfo.h + PADDING, "Draw Client", Colour(0,0,0))) success = false;
			else {
				CreateDrawElements();
				heatMap = new HeatMap(window.Width, window.Height);
			}
		}

		if(isLogging) file.writeln(stderr, "Initialisation successful: ", success);

		return success;
	}

	public void Update() {
			
		bool quit = false;
		SDL_Event event;
		int toolChoice= 1;

		while(!quit) {
			stdout.flush();
			if(isLogging) file.writeln(stderr, "Polling events");
			while(SDL_PollEvent(&event) != 0) {
				if(event.type == SDL_QUIT) quit = true;
				else if (event.type == SDL_KEYDOWN) {
					switch(event.key.keysym.sym){
						case SDLK_ESCAPE: 
							quit = true; 
							break;

						default: break;
					}
				}

				if(isLogging) file.writeln(stderr, "Window handling events");
				window.HandleEvent(event);

				if(isLogging) file.writeln(stderr, "Sliders handling events");
				HandleSliderEvents(event);

				int x, y = 0;
				if(isLogging) file.writeln(stderr, "Checking input for tool change");
				if(event.type == SDL_MOUSEBUTTONDOWN && event.button.button == SDL_BUTTON_LEFT) {
					if(canvas.MouseOver(x,y)){
						switch(toolChoice) {
							case 1: DrawPixel(x, y); break;

							case 2: DrawLine(x, y); break;

							case 3: DrawBox(x, y); break;

							case 4: DrawCircle(x, y); break;

							default: break;
						}
					}
					else if(b_pixel.MouseOver(x,y)){
						if(isLogging) file.writeln(stderr, "Pixel tool selected");
						toolChoice = 1;
						b_pixel.isSelected = true;
						b_line.isSelected = false;
						b_box.isSelected = false;
						b_circle.isSelected = false;
					}
					else if(b_line.MouseOver(x,y)) {
						if(isLogging) file.writeln(stderr, "Line tool selected");
						toolChoice = 2;
						b_pixel.isSelected = false;
						b_line.isSelected = true;
						b_box.isSelected = false;
						b_circle.isSelected = false;
					}
					else if(b_box.MouseOver(x,y)) {
						if(isLogging) file.writeln(stderr, "Box tool selected");
						toolChoice = 3;
						b_pixel.isSelected = false;
						b_line.isSelected = false;
						b_box.isSelected = true;
						b_circle.isSelected = false;
					}
					else if(b_circle.MouseOver(x,y)) {
						if(isLogging) file.writeln(stderr, "Circle tool selected");
						toolChoice = 4;
						b_pixel.isSelected = false;
						b_line.isSelected = false;
						b_box.isSelected = false;
						b_circle.isSelected = true;
					}
				}
			}
			if(isLogging) file.writeln(stderr, "Clear Window");
			window.Clear();

			if(isLogging) file.writeln(stderr, "Drawing everything");
			DrawEverything();

			PerformActions();
			
			if(isLogging) file.writeln(stderr, "Rendering window");	
			window.Render();
		}
		if(isLogging) file.writeln(stderr, "Saving Heatmap");
		heatMap.SaveHeatMap("img/heatmap.bmp");
	}

	private void HandleSliderEvents(ref SDL_Event e){

		if(isLogging) file.writeln(stderr, "Handling red slider events");
		s_red.HandleEvent(e);

		if(isLogging) file.writeln(stderr, "Handling green slider events");
		s_green.HandleEvent(e);

		if(isLogging) file.writeln(stderr, "Handling blue slider events");
		s_blue.HandleEvent(e);

		if(isLogging) file.writeln(stderr, "Updating colour picker");
		colourPicker.fillColour = drawColour = Colour(cast(ubyte)(255 * s_red.sliderValue), cast(ubyte)(255 * s_green.sliderValue), cast(ubyte)(255 * s_blue.sliderValue));

		if(isLogging) file.writeln(stderr, "Changing slider bar colours");
		s_red.barColour = Colour(drawColour.r, 0, 0);
		s_green.barColour = Colour(0, drawColour.g, 0);
		s_blue.barColour = Colour(0, 0, drawColour.b);
	}

	private void DrawEverything() {
		DrawButtons();
		DrawSliders();
	}

	private void PerformActions() {
		if(isLogging) file.writeln(stderr, "Building CursorInfo");
		int x,y = 0;
		SDL_GetMouseState(&x, &y);

		cursor.cursor = CursorInfo(cast(ushort)x, cast(ushort)y, drawColour.r);
		if(isLogging) file.writeln(stderr, "Sending CursorInfo");
		comms.SendPacket(cursor, false);


		if(isLogging) file.writeln(stderr, "Recieving server cursors");
		byte[] serverResponse = comms.RecievePacket(false);

		if(GetInt(serverResponse, 0) == 8){
			auto count = GetUShort(serverResponse, 2);

			if(count > 0){
				auto cursorArray = (cast(CursorInfo*)(serverResponse.ptr + 6))[0..count];
				
				for(int i = 0; i < cursorArray.length; i++){
					auto cursor = cursorArray[i];
					if(cursor.x > 0  &&  cursor.x < window.Width){
						if(cursor.y > 0 && cursor.y < window.Height){
							SDL_Rect rect = SDL_Rect(cursor.x - 1, cursor.y - 1, 3, 3);

							SDL_SetRenderDrawColor(window.renderer, cursor.data, 0, 0, 255);
							SDL_RenderFillRect(window.renderer, &rect);
						}
					}
				}
			}
		}
		
		if(isLogging) file.writeln(stderr, "Updating heatmap with cursor position");
		heatMap.SetMousePosition();
	}

	private void CreateDrawElements() {
		if(isLogging) file.writeln(stderr, "Creating the gui");
		canvas = new Button(SDL_Rect((window.Width - serverInfo.w)/2, (window.Height - serverInfo.h)/2, serverInfo.w, serverInfo.h), Colour.White, Colour(127, 127, 127));
		colourPicker = new Button(SDL_Rect(canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y, 32, 32), drawColour, Colour.White);

		int b_Padding_1 = 5;
		int b_Padding_2 = 10;

		b_pixel = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 0 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);
		b_line = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 1 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);
		b_box = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 2 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);
		b_circle = new Button(SDL_Rect(window.Width - canvas.pos.x/2 - 16, canvas.pos.y/4 + canvas.pos.y + 3 * (32 + b_Padding_1), 32, 32), Colour.Grey, Colour.Silver);;

		b_pixel.isSelected = true;

		s_red = new Slider(SDL_Rect(10, canvas.pos.y/4 + canvas.pos.y + colourPicker.pos.h + b_Padding_2, canvas.pos.x - 20, 6), Colour.White, Colour.Silver, 0.0);
		s_green = new Slider(SDL_Rect(10, canvas.pos.y/4 + canvas.pos.y + colourPicker.pos.h + 2 * b_Padding_2 + s_red.bar.h, canvas.pos.x - 20, 6), Colour.White, Colour.Silver, 0.0);
		s_blue = new Slider(SDL_Rect(10, canvas.pos.y/4 + canvas.pos.y + colourPicker.pos.h + 3 * b_Padding_2 + s_red.bar.h + s_green.bar.h, canvas.pos.x - 20, 6), Colour.White, Colour.Silver, 0.0);

		if(isLogging) file.writeln(stderr, "Loading images");
		LoadImages();

		if(isLogging) file.writeln(stderr, "Draw elements created");
	}

	private void LoadImages() {
		b_pixel.LoadButtonImage("img/pixel.bmp", window);
		b_line.LoadButtonImage("img/line.bmp", window);
		b_box.LoadButtonImage("img/box.bmp", window);
		b_circle.LoadButtonImage("img/circle.bmp", window);
	}

	private void DrawPixel(int x, int y){
		if(isLogging) file.writeln(stderr, "Building pixel packet");
		pixel.x = x;
		pixel.y = y;

		pixel.r = drawColour.r / 255.0f;
		pixel.g = drawColour.g / 255.0f;
		pixel.b = drawColour.b / 255.0f;

		if(isLogging) file.writeln(stderr, "Sending pixel packet");
		comms.SendPacket(pixel);
	}

	private void DrawLine(int x, int y){
		if(firstPosSet == 0) {
			if(isLogging) file.writeln(stderr, "Saving line packet start position");
			lineX = x;
			lineY = y;
		}
		else {
			if(isLogging) file.writeln(stderr, "Building line packet");
			line.x1 = lineX;
			line.y1 = lineY;

			line.x2 = x;
			line.y2 = y;

			line.r = drawColour.r / 255.0f;
			line.g = drawColour.g / 255.0f;
			line.b = drawColour.b / 255.0f;

			if(isLogging) file.writeln(stderr, "Sending line packet");
			comms.SendPacket(line);
		}			
		firstPosSet = 1 - firstPosSet;
	}

	private void DrawBox(int x, int y){
		if(firstPosSet == 0){
			if(isLogging) file.writeln(stderr, "Saving box packet start position");
			box.x = x;
			box.y = y;
		}
		else {
			if(isLogging) file.writeln(stderr, "Building box packet");
			box.w = x;
			box.h = y;

			box.r = drawColour.r / 255.0f;
			box.g = drawColour.g / 255.0f;
			box.b = drawColour.b / 255.0f;

			if(isLogging) file.writeln(stderr, "Adjusting box rect");
			SDL_Rect temp = SDL_Rect(box.x, box.y, box.w, box.h);
			temp = BuildRect(temp);

			box.x = temp.x;
			box.y = temp.y;
			box.w = temp.w;
			box.h = temp.h;

			if(isLogging) file.writeln(stderr, "Sending box packet");
			comms.SendPacket(box);
		}
		firstPosSet = 1 - firstPosSet;
	}

	private void DrawCircle(int x, int y){
		if(firstPosSet == 0){
			if(isLogging) file.writeln(stderr, "Saving circle packet start position");
			circle.x = x;
			circle.y = y;
		}
		else {
			if(isLogging) file.writeln(stderr, "Building circle packet");
			int rad = cast(int) sqrt(cast(float)((x - circle.x) * (x - circle.x) + (y - circle.y) * (y- circle.y)));

			circle.radius = rad;

			circle.r = drawColour.r / 255.0f;
			circle.g = drawColour.g / 255.0f;
			circle.b = drawColour.b / 255.0f;

			if(isLogging) file.writeln(stderr, "Sending circle packet");
			comms.SendPacket(circle);
		}
		firstPosSet = 1 - firstPosSet;	
	}

	private void DrawButtons() {
		if(isLogging) file.writeln(stderr, "Drawing buttons");
		canvas.Render(window);
		colourPicker.Render(window);

		b_pixel.Render(window);
		b_line.Render(window);
		b_box.Render(window);
		b_circle.Render(window);
	}

	private void DrawSliders() {
		if(isLogging) file.writeln(stderr, "Drawing sliders");
		s_red.Render(window);
		s_green.Render(window);
		s_blue.Render(window);
	}

	private SDL_Rect BuildRect (ref SDL_Rect rect) {
		int x1 = rect.x;
		int y1 = rect.y;
		int x2 = rect.w;
		int y2 = rect.h;

		rect.x = min(x1, x2);
		rect.y = min(y1, y2);

		rect.w = max(x1, x2) - rect.x;
		rect.h = max(y1, y2) - rect.y;

		return rect;
	}

	public void Close() {
		if(isLogging) file.writeln(stderr, "Closing application");
		SDL_Quit();
	}
}