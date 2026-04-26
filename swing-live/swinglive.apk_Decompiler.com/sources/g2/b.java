package g2;

import f2.EnumC0401a;
import f2.EnumC0402b;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class b extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4325c;

    /* JADX WARN: Illegal instructions before constructor call */
    public b(int i4) {
        EnumC0402b enumC0402b = EnumC0402b.f4286b;
        EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
        super(new f(enumC0402b, 2));
        this.f4325c = i4;
    }

    @Override // g2.o
    public final int b() {
        return 4;
    }

    @Override // g2.o
    public final g c() {
        return g.f4341d;
    }

    @Override // g2.o
    public final void d(InputStream inputStream) {
        J3.i.e(inputStream, "input");
        this.f4325c = AbstractC0752b.h(inputStream);
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        AbstractC0752b.s(byteArrayOutputStream, this.f4325c);
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        J3.i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    public final String toString() {
        return B1.a.l("Acknowledgement(sequenceNumber=", this.f4325c, ")");
    }
}
