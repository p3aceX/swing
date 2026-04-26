package k2;

import J3.i;
import f2.EnumC0401a;
import f2.EnumC0402b;
import g2.f;
import g2.g;
import g2.o;
import java.io.InputStream;

/* JADX INFO: renamed from: k2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0512a extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ int f5558c;

    /* JADX WARN: Illegal instructions before constructor call */
    public C0512a(int i4) {
        this.f5558c = i4;
        EnumC0402b enumC0402b = EnumC0402b.f4286b;
        EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
        super(new f(enumC0402b, 2));
    }

    @Override // g2.o
    public final int b() {
        throw new H3.a();
    }

    @Override // g2.o
    public final g c() {
        switch (this.f5558c) {
            case 0:
                return g.f4350t;
            default:
                return g.f4347q;
        }
    }

    @Override // g2.o
    public final void d(InputStream inputStream) {
        i.e(inputStream, "input");
        throw new H3.a();
    }

    @Override // g2.o
    public final byte[] e() {
        throw new H3.a();
    }
}
