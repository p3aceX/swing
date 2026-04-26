package k3;

import O2.q;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: k3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0514b extends q {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0514b f5561d = new C0514b();

    @Override // O2.q
    public final Object f(byte b5, ByteBuffer byteBuffer) {
        if (b5 != -127) {
            return super.f(b5, byteBuffer);
        }
        Object objE = e(byteBuffer);
        if (objE == null) {
            return null;
        }
        return EnumC0515c.values()[((Long) objE).intValue()];
    }

    @Override // O2.q
    public final void k(F3.a aVar, Object obj) {
        if (!(obj instanceof EnumC0515c)) {
            super.k(aVar, obj);
        } else {
            aVar.write(129);
            k(aVar, obj == null ? null : Integer.valueOf(((EnumC0515c) obj).f5563a));
        }
    }
}
