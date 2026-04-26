package androidx.datastore.preferences.protobuf;

import a.AbstractC0184a;
import java.io.Serializable;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Locale;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0196g implements Iterable, Serializable {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0196g f2968c = new C0196g(AbstractC0211w.f3036b);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0194e f2969d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2970a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f2971b;

    static {
        f2969d = AbstractC0192c.a() ? new C0194e(1) : new C0194e(0);
    }

    public C0196g(byte[] bArr) {
        bArr.getClass();
        this.f2971b = bArr;
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

    public static C0196g h(byte[] bArr, int i4, int i5) {
        byte[] bArrCopyOfRange;
        g(i4, i4 + i5, bArr.length);
        switch (f2969d.f2965a) {
            case 0:
                bArrCopyOfRange = Arrays.copyOfRange(bArr, i4, i5 + i4);
                break;
            default:
                bArrCopyOfRange = new byte[i5];
                System.arraycopy(bArr, i4, bArrCopyOfRange, 0, i5);
                break;
        }
        return new C0196g(bArrCopyOfRange);
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0196g) || size() != ((C0196g) obj).size()) {
            return false;
        }
        if (size() == 0) {
            return true;
        }
        if (!(obj instanceof C0196g)) {
            return obj.equals(this);
        }
        C0196g c0196g = (C0196g) obj;
        int i4 = this.f2970a;
        int i5 = c0196g.f2970a;
        if (i4 != 0 && i5 != 0 && i4 != i5) {
            return false;
        }
        int size = size();
        if (size > c0196g.size()) {
            throw new IllegalArgumentException("Length too large: " + size + size());
        }
        if (size > c0196g.size()) {
            StringBuilder sbI = com.google.crypto.tink.shaded.protobuf.S.i("Ran off end of other: 0, ", size, ", ");
            sbI.append(c0196g.size());
            throw new IllegalArgumentException(sbI.toString());
        }
        int iJ = j() + size;
        int iJ2 = j();
        int iJ3 = c0196g.j();
        while (iJ2 < iJ) {
            if (this.f2971b[iJ2] != c0196g.f2971b[iJ3]) {
                return false;
            }
            iJ2++;
            iJ3++;
        }
        return true;
    }

    public byte f(int i4) {
        return this.f2971b[i4];
    }

    public final int hashCode() {
        int i4 = this.f2970a;
        if (i4 != 0) {
            return i4;
        }
        int size = size();
        int iJ = j();
        int i5 = size;
        for (int i6 = iJ; i6 < iJ + size; i6++) {
            i5 = (i5 * 31) + this.f2971b[i6];
        }
        if (i5 == 0) {
            i5 = 1;
        }
        this.f2970a = i5;
        return i5;
    }

    public void i(byte[] bArr, int i4) {
        System.arraycopy(this.f2971b, 0, bArr, 0, i4);
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        return new C0193d(this);
    }

    public int j() {
        return 0;
    }

    public byte k(int i4) {
        return this.f2971b[i4];
    }

    public int size() {
        return this.f2971b.length;
    }

    public final String toString() {
        C0196g c0195f;
        String string;
        Locale locale = Locale.ROOT;
        String hexString = Integer.toHexString(System.identityHashCode(this));
        int size = size();
        if (size() <= 50) {
            string = AbstractC0184a.D(this);
        } else {
            StringBuilder sb = new StringBuilder();
            int iG = g(0, 47, size());
            if (iG == 0) {
                c0195f = f2968c;
            } else {
                c0195f = new C0195f(this.f2971b, j(), iG);
            }
            sb.append(AbstractC0184a.D(c0195f));
            sb.append("...");
            string = sb.toString();
        }
        StringBuilder sb2 = new StringBuilder("<ByteString@");
        sb2.append(hexString);
        sb2.append(" size=");
        sb2.append(size);
        sb2.append(" contents=\"");
        return com.google.crypto.tink.shaded.protobuf.S.h(sb2, string, "\">");
    }
}
