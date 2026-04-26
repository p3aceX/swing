package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class c0 {
    public static b0 a(Object obj) {
        AbstractC0209u abstractC0209u = (AbstractC0209u) obj;
        b0 b0Var = abstractC0209u.unknownFields;
        if (b0Var != b0.f2954f) {
            return b0Var;
        }
        b0 b0Var2 = new b0(0, new int[8], new Object[8], true);
        abstractC0209u.unknownFields = b0Var2;
        return b0Var2;
    }

    public static boolean b(int i4, C0199j c0199j, Object obj) throws C0213y, com.google.crypto.tink.shaded.protobuf.A {
        int i5 = c0199j.f2994b;
        int i6 = i5 >>> 3;
        int i7 = i5 & 7;
        T0.d dVar = (T0.d) c0199j.e;
        if (i7 == 0) {
            c0199j.P(0);
            ((b0) obj).c(i6 << 3, Long.valueOf(dVar.v()));
            return true;
        }
        if (i7 == 1) {
            c0199j.P(1);
            ((b0) obj).c((i6 << 3) | 1, Long.valueOf(dVar.s()));
            return true;
        }
        if (i7 == 2) {
            ((b0) obj).c((i6 << 3) | 2, c0199j.h());
            return true;
        }
        if (i7 != 3) {
            if (i7 == 4) {
                return false;
            }
            if (i7 != 5) {
                throw C0213y.b();
            }
            c0199j.P(5);
            ((b0) obj).c(5 | (i6 << 3), Integer.valueOf(dVar.r()));
            return true;
        }
        b0 b0Var = new b0(0, new int[8], new Object[8], true);
        int i8 = i6 << 3;
        int i9 = i8 | 4;
        int i10 = i4 + 1;
        if (i10 >= 100) {
            throw new C0213y("Protocol message had too many levels of nesting.  May be malicious.  Use setRecursionLimit() to increase the recursion depth limit.");
        }
        while (c0199j.a() != Integer.MAX_VALUE && b(i10, c0199j, b0Var)) {
        }
        if (i9 != c0199j.f2994b) {
            throw new C0213y("Protocol message end-group tag did not match expected tag.");
        }
        if (b0Var.e) {
            b0Var.e = false;
        }
        ((b0) obj).c(i8 | 3, b0Var);
        return true;
    }
}
