package o3;

import java.io.Closeable;
import u3.AbstractC0692a;

/* JADX INFO: renamed from: o3.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0596d implements Closeable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Z3.a f6084a;

    public /* synthetic */ C0596d(Z3.a aVar) {
        this.f6084a = aVar;
    }

    public static final byte[] a(Z3.a aVar, String str) {
        byte[] bArr;
        J3.i.e(str, "hashName");
        synchronized (aVar) {
            M1.b bVar = new M1.b(str, 2);
            Z3.d dVarA = aVar.a();
            try {
                Object objInvoke = bVar.invoke(dVarA);
                dVarA.close();
                bArr = (byte[]) objInvoke;
            } finally {
            }
        }
        J3.i.d(bArr, "synchronized(...)");
        return bArr;
    }

    public static final void b(Z3.a aVar, Z3.a aVar2) {
        synchronized (aVar) {
            if (aVar2.w()) {
                return;
            }
            AbstractC0692a.d(aVar, aVar2.a());
        }
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
        this.f6084a.getClass();
    }

    public final boolean equals(Object obj) {
        if (obj instanceof C0596d) {
            return J3.i.a(this.f6084a, ((C0596d) obj).f6084a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f6084a.hashCode();
    }

    public final String toString() {
        return "Digest(state=" + this.f6084a + ')';
    }
}
