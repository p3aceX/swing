package com.google.crypto.tink.shaded.protobuf;

import androidx.datastore.preferences.protobuf.C0199j;
import androidx.datastore.preferences.protobuf.C0212x;

/* JADX INFO: loaded from: classes.dex */
public final class g0 {
    public static f0 a(Object obj) {
        AbstractC0316v abstractC0316v = (AbstractC0316v) obj;
        f0 f0Var = abstractC0316v.unknownFields;
        if (f0Var != f0.f3785f) {
            return f0Var;
        }
        f0 f0VarC = f0.c();
        abstractC0316v.unknownFields = f0VarC;
        return f0VarC;
    }

    public static boolean b(Object obj, C0199j c0199j) throws B, C0212x {
        int i4 = c0199j.f2994b;
        int i5 = i4 >>> 3;
        int i6 = i4 & 7;
        T0.d dVar = (T0.d) c0199j.e;
        if (i6 == 0) {
            c0199j.P(0);
            ((f0) obj).d(i5 << 3, Long.valueOf(dVar.v()));
            return true;
        }
        if (i6 == 1) {
            c0199j.P(1);
            ((f0) obj).d((i5 << 3) | 1, Long.valueOf(dVar.s()));
            return true;
        }
        if (i6 == 2) {
            ((f0) obj).d((i5 << 3) | 2, c0199j.i());
            return true;
        }
        if (i6 != 3) {
            if (i6 == 4) {
                return false;
            }
            if (i6 != 5) {
                throw B.c();
            }
            c0199j.P(5);
            ((f0) obj).d((i5 << 3) | 5, Integer.valueOf(dVar.r()));
            return true;
        }
        f0 f0VarC = f0.c();
        int i7 = i5 << 3;
        int i8 = i7 | 4;
        while (c0199j.a() != Integer.MAX_VALUE && b(f0VarC, c0199j)) {
        }
        if (i8 != c0199j.f2994b) {
            throw new B("Protocol message end-group tag did not match expected tag.");
        }
        f0VarC.e = false;
        ((f0) obj).d(i7 | 3, f0VarC);
        return true;
    }
}
