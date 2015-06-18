module colour;

struct Colour {
	public ubyte r = 255;
	public ubyte g = 255;
	public ubyte b = 255;
	public ubyte a = 255;

	static Colour White() @property {
		return Colour(255, 255, 255);
	}

	static Colour Black() @property {
		return Colour(0, 0, 0);
	}

	static Colour Grey() @property {
		return Colour(128, 128, 128);
	}

	static Colour Silver() @ property {
		return Colour(192, 192, 192);
	}

	static Colour Red() @property {
		return Colour(255, 0, 0);
	}

	static Colour Blue() @property {
		return Colour(0, 0, 255);
	}

	static Colour Green() @property {
		return Colour(0, 255, 0);
	}

	static Colour Yellow() @property {
		return Colour(255, 255, 0);
	}
	static Colour Lerp(Colour c1, Colour c2, float step) {
		if(step < 0)
			return c1;
		else if(step > 1)
			return c2;
		return(Colour(cast(ubyte)(c1.r + (c2.r - c1.r)*step), cast(ubyte)(c1.g + (c2.g - c1.g)*step), cast(ubyte)(c1.b + (c2.b - c1.b)*step), cast(ubyte)(c1.a + (c2.a - c1.a)*step)));
	}
}