package g2;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import y1.AbstractC0752b;

/* JADX INFO: renamed from: g2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0408a extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4324c;

    @Override // g2.o
    public final int b() {
        return 4;
    }

    @Override // g2.o
    public final g c() {
        return g.f4340c;
    }

    @Override // g2.o
    public final void d(InputStream inputStream) {
        J3.i.e(inputStream, "input");
        this.f4324c = AbstractC0752b.h(inputStream);
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        AbstractC0752b.s(byteArrayOutputStream, this.f4324c);
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        J3.i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    public final String toString() {
        return B1.a.l("Abort(chunkStreamId=", this.f4324c, ")");
    }
}
