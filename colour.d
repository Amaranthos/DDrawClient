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
		return Colour(0, 255, 0);
	}

	static Colour Green() @property {
		return Colour(0, 0, 255);
	}

	static Colour Yellow() @property {
		return Colour(255, 255, 0);
	}
}