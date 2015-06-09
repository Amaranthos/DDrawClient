module main;

pragma(lib, "lib\\DerelictSDL2.lib");
pragma(lib, "lib\\DerelictUtil.lib");

import std.stdio;

import derelict.sdl2.sdl;

import app;

void main() {
	try{
		DerelictSDL2.load;

		if(!App.Inst.Init()) writeln("Warning: Draw Client failed to init!");
		else App.Inst.Update();

		App.Inst.Close();
	}
	catch(Exception e) {
		writeln("Exception %s", e.msg);
		throw(e);
	}
}
