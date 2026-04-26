package z1;

import J3.i;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Arrays;

/* JADX INFO: renamed from: z1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0786a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f6983a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f6984b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f6985c;

    public C0786a(byte[] bArr, byte[] bArr2, byte[] bArr3) {
        this.f6983a = bArr;
        this.f6984b = bArr2;
        this.f6985c = bArr3;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0786a)) {
            return false;
        }
        C0786a c0786a = (C0786a) obj;
        return i.a(this.f6983a, c0786a.f6983a) && i.a(this.f6984b, c0786a.f6984b) && i.a(this.f6985c, c0786a.f6985c);
    }

    public final int hashCode() {
        int iHashCode = Arrays.hashCode(this.f6983a) * 31;
        byte[] bArr = this.f6984b;
        return Arrays.hashCode(this.f6985c) + ((iHashCode + (bArr == null ? 0 : Arrays.hashCode(bArr))) * 31);
    }

    public final String toString() {
        String string = Arrays.toString(this.f6983a);
        String string2 = Arrays.toString(this.f6984b);
        String string3 = Arrays.toString(this.f6985c);
        StringBuilder sb = new StringBuilder("Obu(header=");
        sb.append(string);
        sb.append(", leb128=");
        sb.append(string2);
        sb.append(", data=");
        return S.h(sb, string3, ")");
    }
}
