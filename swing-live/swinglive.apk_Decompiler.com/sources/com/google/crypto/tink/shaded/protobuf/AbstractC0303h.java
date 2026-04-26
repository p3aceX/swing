package com.google.crypto.tink.shaded.protobuf;

import a.AbstractC0184a;
import java.io.Serializable;
import java.util.Arrays;
import java.util.Locale;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0303h implements Iterable, Serializable {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0302g f3791b = new C0302g(AbstractC0320z.f3840b);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0300e f3792c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f3793a;

    static {
        f3792c = AbstractC0298c.a() ? new C0300e(1) : new C0300e(0);
    }

    public static int g(int i4, int i5, int i6) {
        int i7 = i5 - i4;
        if ((i4 | i5 | i7 | (i6 - i5)) >= 0) {
            return i7;
        }
        if (i4 < 0) {
            throw new IndexOutOfBoundsException(B1.a.l("Beginning index: ", i4, " < 0"));
        }
        if (i5 < i4) {
            throw new IndexOutOfBoundsException(B1.a.k("Beginning index larger than ending index: ", i4, i5, ", "));
        }
        throw new IndexOutOfBoundsException(B1.a.k("End index: ", i5, i6, " >= "));
    }

    public static C0302g h(byte[] bArr, int i4, int i5) {
        byte[] bArrCopyOfRange;
        g(i4, i4 + i5, bArr.length);
        switch (f3792c.f3783a) {
            case 0:
                bArrCopyOfRange = Arrays.copyOfRange(bArr, i4, i5 + i4);
                break;
            default:
                bArrCopyOfRange = new byte[i5];
                System.arraycopy(bArr, i4, bArrCopyOfRange, 0, i5);
                break;
        }
        return new C0302g(bArrCopyOfRange);
    }

    public abstract byte f(int i4);

    public final int hashCode() {
        int i4 = this.f3793a;
        if (i4 != 0) {
            return i4;
        }
        int size = size();
        C0302g c0302g = (C0302g) this;
        int iK = c0302g.k();
        int i5 = size;
        for (int i6 = iK; i6 < iK + size; i6++) {
            i5 = (i5 * 31) + c0302g.f3790d[i6];
        }
        if (i5 == 0) {
            i5 = 1;
        }
        this.f3793a = i5;
        return i5;
    }

    public abstract void i(byte[] bArr, int i4);

    public final byte[] j() {
        int size = size();
        if (size == 0) {
            return AbstractC0320z.f3840b;
        }
        byte[] bArr = new byte[size];
        i(bArr, size);
        return bArr;
    }

    public abstract int size();

    public final String toString() {
        C0302g c0301f;
        String string;
        Locale locale = Locale.ROOT;
        String hexString = Integer.toHexString(System.identityHashCode(this));
        int size = size();
        if (size() <= 50) {
            string = AbstractC0184a.E(this);
        } else {
            StringBuilder sb = new StringBuilder();
            C0302g c0302g = (C0302g) this;
            int iG = g(0, 47, c0302g.size());
            if (iG == 0) {
                c0301f = f3791b;
            } else {
                c0301f = new C0301f(c0302g.f3790d, c0302g.k(), iG);
            }
            sb.append(AbstractC0184a.E(c0301f));
            sb.append("...");
            string = sb.toString();
        }
        StringBuilder sb2 = new StringBuilder("<ByteString@");
        sb2.append(hexString);
        sb2.append(" size=");
        sb2.append(size);
        sb2.append(" contents=\"");
        return S.h(sb2, string, "\">");
    }
}
