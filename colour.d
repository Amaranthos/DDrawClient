module colour;

struct Colour {
	public ubyte r;
	public ubyte g;
	public ubyte b;
	public ubyte a;

	this(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255){
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	~this() {

	}
}