module comms;

import std.stdio;
import std.socket;

import packets;

class Comms {
	public Socket sendSocket;
	public Address sendAddress;

	this () {

	}

	public void InitialiseSocket(const char[] hostAddress, ushort port) {
		sendSocket = new UdpSocket();
		sendAddress = parseAddress(hostAddress, port);
	}

	public void SendPacket(T)(ref T packet, bool doPrint = true) {
		int res = sendSocket.sendTo(cast(void[])[packet], sendAddress);

		if(res == Socket.ERROR) writeln("Warning: Failed to send packet!");
		else if(doPrint) writeln("Success: Packet size of ", res, " sent!");
	}

	public byte[] RecievePacket(bool doPrint = true) {
		SocketSet sockets = new SocketSet();
		sockets.add(sendSocket);

		byte[] buffer = new byte[1024];

		if(Socket.select(sockets, null, null) == 1) {

			int res = sendSocket.receive(buffer);

			if(res == Socket.ERROR && doPrint) writeln("Warning: Failed to read/receive packet!");
			else if(doPrint) writeln("Success: Packet Received: ", buffer[0..res]);
		}
		return buffer;
	}
}

public int GetInt(byte[] buffer, int index) {
	return (cast(int[])buffer)[index];
}

public ushort GetUShort(byte[] buffer, int index) {
	return (cast(ushort[])buffer)[index];
}

