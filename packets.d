module packets;

struct CursorInfo {
	public uint x;
	public uint y;
	public char data;
}

struct PacketPixel {
	private int type = 1;
	public int x;
	public int y;
	public float r;
	public float g;
	public float b;
}

struct PacketLine {
	private int type = 2;
	public int x1;
	public int y1;
	public int x2;
	public int y2;
	public float r;
	public float g;
	public float b;
}

struct PacketBox {
	private int type = 3;
	public int x;
	public int y;
	public int w;
	public int h;
	public float r;
	public float g;
	public float b;
}

struct PacketCircle {
	private int type = 4;
	public int x;
	public int y;
	public int radius;
	public float r;
	public float g;
	public float b;
}