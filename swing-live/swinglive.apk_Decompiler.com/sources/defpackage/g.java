package defpackage;

import F3.a;
import J3.i;
import O2.q;
import e1.k;
import java.nio.ByteBuffer;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class g extends q {
    @Override // O2.q
    public final Object f(byte b5, ByteBuffer byteBuffer) {
        i.e(byteBuffer, "buffer");
        if (b5 == -127) {
            Object objE = e(byteBuffer);
            List list = objE instanceof List ? (List) objE : null;
            if (list != null) {
                return new b((Boolean) list.get(0));
            }
        } else {
            if (b5 != -126) {
                return super.f(b5, byteBuffer);
            }
            Object objE2 = e(byteBuffer);
            List list2 = objE2 instanceof List ? (List) objE2 : null;
            if (list2 != null) {
                return new a((Boolean) list2.get(0));
            }
        }
        return null;
    }

    @Override // O2.q
    public final void k(a aVar, Object obj) {
        if (obj instanceof b) {
            aVar.write(129);
            k(aVar, k.x(((b) obj).f3203a));
        } else if (!(obj instanceof a)) {
            super.k(aVar, obj);
        } else {
            aVar.write(130);
            k(aVar, k.x(((a) obj).f2627a));
        }
    }
}
