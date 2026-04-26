package com.google.crypto.tink.shaded.protobuf;

import java.io.IOException;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0296a implements P {
    protected int memoizedHashCode;

    public abstract int b(c0 c0Var);

    public final String c(String str) {
        return "Serializing " + getClass().getName() + " to a " + str + " threw an IOException (should never happen).";
    }

    public abstract AbstractC0314t d();

    public final byte[] e() {
        try {
            int iB = ((AbstractC0316v) this).b(null);
            byte[] bArr = new byte[iB];
            C0306k c0306k = new C0306k(bArr, iB);
            f(c0306k);
            if (iB - c0306k.f3815l == 0) {
                return bArr;
            }
            throw new IllegalStateException("Did not write as much data as expected.");
        } catch (IOException e) {
            throw new RuntimeException(c("byte array"), e);
        }
    }

    public abstract void f(C0306k c0306k);
}
