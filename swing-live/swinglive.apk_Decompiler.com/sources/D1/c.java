package D1;

import J3.i;
import a.AbstractC0184a;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.SocketException;
import x3.AbstractC0726f;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class c extends C1.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f149b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f150c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C1.c f151d;
    public DatagramSocket e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f152f;

    public c(String str, int i4, C1.c cVar) {
        i.e(str, "host");
        this.f149b = str;
        this.f150c = i4;
        this.f151d = cVar;
        this.f152f = 1500;
    }

    @Override // C1.b
    public final Object a(InterfaceC0762c interfaceC0762c) {
        DatagramSocket datagramSocket = this.e;
        if (datagramSocket != null && !datagramSocket.isClosed()) {
            DatagramSocket datagramSocket2 = this.e;
            if (datagramSocket2 != null) {
                datagramSocket2.disconnect();
            }
            DatagramSocket datagramSocket3 = this.e;
            if (datagramSocket3 != null) {
                datagramSocket3.close();
            }
            this.e = null;
        }
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final Object b(InterfaceC0762c interfaceC0762c) throws SocketException {
        DatagramSocket datagramSocket;
        int iOrdinal = this.f151d.ordinal();
        if (iOrdinal == 0) {
            datagramSocket = new DatagramSocket();
        } else if (iOrdinal == 1) {
            datagramSocket = new MulticastSocket();
        } else {
            if (iOrdinal != 2) {
                throw new A0.b();
            }
            datagramSocket = new DatagramSocket();
            datagramSocket.setBroadcast(true);
        }
        datagramSocket.connect(InetAddress.getByName(this.f149b), this.f150c);
        datagramSocket.setReceiveBufferSize(this.f152f);
        datagramSocket.setSoTimeout((int) this.f125a);
        this.e = datagramSocket;
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final boolean d() {
        DatagramSocket datagramSocket = this.e;
        if (datagramSocket != null) {
            return datagramSocket.isConnected();
        }
        return false;
    }

    @Override // C1.b
    public final Object f(A3.c cVar) throws IOException {
        int i4 = this.f152f;
        DatagramPacket datagramPacket = new DatagramPacket(new byte[i4], i4);
        DatagramSocket datagramSocket = this.e;
        if (datagramSocket != null) {
            datagramSocket.receive(datagramPacket);
        }
        byte[] data = datagramPacket.getData();
        i.d(data, "getData(...)");
        return AbstractC0726f.k0(data, AbstractC0184a.Z(0, datagramPacket.getLength()));
    }

    @Override // C1.b
    public final Object j(byte[] bArr, A3.c cVar) throws IOException {
        DatagramPacket datagramPacket = new DatagramPacket(bArr, bArr.length);
        DatagramSocket datagramSocket = this.e;
        if (datagramSocket != null) {
            datagramSocket.send(datagramPacket);
        }
        return w3.i.f6729a;
    }
}
