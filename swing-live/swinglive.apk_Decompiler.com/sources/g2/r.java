package g2;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class r extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4406c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public q f4407d;

    @Override // g2.o
    public final int b() {
        return 5;
    }

    @Override // g2.o
    public final g c() {
        return g.f4343m;
    }

    @Override // g2.o
    public final void d(InputStream inputStream) throws IOException {
        Object next;
        J3.i.e(inputStream, "input");
        this.f4406c = AbstractC0752b.h(inputStream);
        byte b5 = (byte) inputStream.read();
        B3.b bVar = q.f4404d;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            } else {
                next = aVar.next();
                if (((q) next).f4405a == b5) {
                    break;
                }
            }
        }
        q qVar = (q) next;
        if (qVar == null) {
            throw new IOException(S.d(b5, "Unknown bandwidth type: "));
        }
        this.f4407d = qVar;
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        AbstractC0752b.s(byteArrayOutputStream, this.f4406c);
        byteArrayOutputStream.write(this.f4407d.f4405a);
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        J3.i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    public final String toString() {
        return "SetPeerBandwidth(acknowledgementWindowSize=" + this.f4406c + ", type=" + this.f4407d + ")";
    }
}
