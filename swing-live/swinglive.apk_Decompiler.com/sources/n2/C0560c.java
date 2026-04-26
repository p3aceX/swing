package n2;

import J3.i;
import java.util.Arrays;

/* JADX INFO: renamed from: n2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0560c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f5870a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final EnumC0562e f5871b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f5872c;

    public C0560c(byte[] bArr, EnumC0562e enumC0562e, boolean z4) {
        w2.b bVar = w2.b.f6713b;
        i.e(bArr, "buffer");
        this.f5870a = bArr;
        this.f5871b = enumC0562e;
        this.f5872c = z4;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0560c)) {
            return false;
        }
        C0560c c0560c = (C0560c) obj;
        if (!i.a(this.f5870a, c0560c.f5870a) || this.f5871b != c0560c.f5871b) {
            return false;
        }
        w2.b bVar = w2.b.f6713b;
        return this.f5872c == c0560c.f5872c;
    }

    public final int hashCode() {
        return Boolean.hashCode(this.f5872c) + ((w2.b.f6713b.hashCode() + ((this.f5871b.hashCode() + (Arrays.hashCode(this.f5870a) * 31)) * 31)) * 31);
    }

    public final String toString() {
        return "MpegTsPacket(buffer=" + Arrays.toString(this.f5870a) + ", type=" + this.f5871b + ", packetPosition=" + w2.b.f6713b + ", isKey=" + this.f5872c + ")";
    }
}
