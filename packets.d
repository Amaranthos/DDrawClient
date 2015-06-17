module packets;

align(1) struct CursorInfo {
	public ushort x;
	public ushort y;
	public byte data;
}

align(1) struct PacketPixel {
	private int type = 1;
	public int x;
	public int y;
	public float r;
	public float g;
	public float b;
}

align(1) struct PacketLine {
	private int type = 2;
	public int x1;
	public int y1;
	public int x2;
	public int y2;
	public float r;
	public float g;
	public float b;
}

align(1) struct PacketBox {
	private int type = 3;
	public int x;
	public int y;
	public int w;
	public int h;
	public float r;
	public float g;
	public float b;
}

align(1) struct PacketCircle {
	private int type = 4;
	public int x;
	public int y;
	public int radius;
	public float r;
	public float g;
	public float b;
}

align(1) struct PacketClientAnnounce {
	private int type = 5;
}

align(1) struct PacketClientCursor {
	private int type = 6;
	public CursorInfo cursor;
}

align(1) struct PacketServerInfo {
	private int type = 7;
	public ushort w;
	public ushort h;
}

align(1) struct PacketServerCursors {
	private int type = 8;
	public ushort count;
	CursorInfo[1] cursor;
}