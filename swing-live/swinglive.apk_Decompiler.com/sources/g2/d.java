package g2;

import com.google.crypto.tink.shaded.protobuf.S;
import f2.EnumC0401a;
import f2.EnumC0402b;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class d extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ int f4326c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Z1.a f4327d;

    /* JADX WARN: Illegal instructions before constructor call */
    public d(Z1.a aVar, int i4, int i5) {
        this.f4326c = i5;
        J3.i.e(aVar, "flvPacket");
        switch (i5) {
            case 1:
                EnumC0402b enumC0402b = EnumC0402b.f4286b;
                EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
                super(new f(enumC0402b, 6));
                this.f4327d = aVar;
                a().e = i4;
                a().f4372b = (int) aVar.f2594b;
                a().f4373c = aVar.f2595c;
                break;
            default:
                EnumC0402b enumC0402b2 = EnumC0402b.f4286b;
                EnumC0401a[] enumC0401aArr2 = EnumC0401a.f4285a;
                super(new f(enumC0402b2, 7));
                this.f4327d = aVar;
                a().e = i4;
                a().f4372b = (int) aVar.f2594b;
                a().f4373c = aVar.f2595c;
                break;
        }
    }

    @Override // g2.o
    public final int b() {
        switch (this.f4326c) {
        }
        return this.f4327d.f2595c;
    }

    @Override // g2.o
    public final g c() {
        switch (this.f4326c) {
            case 0:
                return g.f4344n;
            default:
                return g.f4345o;
        }
    }

    @Override // g2.o
    public final void d(InputStream inputStream) {
        switch (this.f4326c) {
            case 0:
                J3.i.e(inputStream, "input");
                break;
            default:
                J3.i.e(inputStream, "input");
                break;
        }
    }

    @Override // g2.o
    public final byte[] e() {
        switch (this.f4326c) {
        }
        return this.f4327d.f2593a;
    }

    public final String toString() {
        switch (this.f4326c) {
            case 0:
                return S.d(this.f4327d.f2595c, "Audio, size: ");
            default:
                return S.d(this.f4327d.f2595c, "Video, size: ");
        }
    }
}
