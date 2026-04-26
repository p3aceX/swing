package i2;

import J3.i;
import com.google.crypto.tink.shaded.protobuf.S;
import f2.EnumC0401a;
import f2.EnumC0402b;
import g2.f;
import g2.g;
import g2.o;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import y1.AbstractC0752b;

/* JADX INFO: renamed from: i2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0423c extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public EnumC0422b f4494c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0421a f4495d;
    public int e;

    /* JADX WARN: Illegal instructions before constructor call */
    public C0423c(EnumC0422b enumC0422b, C0421a c0421a) {
        i.e(enumC0422b, "type");
        i.e(c0421a, "event");
        EnumC0402b enumC0402b = EnumC0402b.f4286b;
        EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
        super(new f(enumC0402b, 2));
        this.f4494c = enumC0422b;
        this.f4495d = c0421a;
        this.e = 6;
    }

    @Override // g2.o
    public final int b() {
        return this.e;
    }

    @Override // g2.o
    public final g c() {
        return g.e;
    }

    @Override // g2.o
    public final void d(InputStream inputStream) throws IOException {
        Object next;
        i.e(inputStream, "input");
        this.e = 0;
        int iG = AbstractC0752b.g(inputStream);
        B3.b bVar = EnumC0422b.f4492f;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            } else {
                next = aVar.next();
                if (((EnumC0422b) next).f4493a == iG) {
                    break;
                }
            }
        }
        EnumC0422b enumC0422b = (EnumC0422b) next;
        if (enumC0422b == null) {
            throw new IOException(S.d(iG, "unknown user control type: "));
        }
        this.f4494c = enumC0422b;
        this.e += 2;
        int iH = AbstractC0752b.h(inputStream);
        this.e += 4;
        this.f4495d = this.f4494c == EnumC0422b.f4489b ? new C0421a(iH, AbstractC0752b.h(inputStream)) : new C0421a(iH, -1);
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        AbstractC0752b.r(byteArrayOutputStream, this.f4494c.f4493a);
        AbstractC0752b.s(byteArrayOutputStream, this.f4495d.f4487a);
        int i4 = this.f4495d.f4488b;
        if (i4 != -1) {
            AbstractC0752b.s(byteArrayOutputStream, i4);
        }
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    public final String toString() {
        EnumC0422b enumC0422b = this.f4494c;
        C0421a c0421a = this.f4495d;
        int i4 = this.e;
        StringBuilder sb = new StringBuilder("UserControl(type=");
        sb.append(enumC0422b);
        sb.append(", event=");
        sb.append(c0421a);
        sb.append(", bodySize=");
        return B1.a.n(sb, i4, ")");
    }
}
