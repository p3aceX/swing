package Z1;

import J3.i;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f2593a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final long f2594b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f2595c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final b f2596d;

    public /* synthetic */ a() {
        this(new byte[0], 0L, 0, b.f2597a);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof a)) {
            return false;
        }
        a aVar = (a) obj;
        return i.a(this.f2593a, aVar.f2593a) && this.f2594b == aVar.f2594b && this.f2595c == aVar.f2595c && this.f2596d == aVar.f2596d;
    }

    public final int hashCode() {
        return this.f2596d.hashCode() + B1.a.h(this.f2595c, (Long.hashCode(this.f2594b) + (Arrays.hashCode(this.f2593a) * 31)) * 31, 31);
    }

    public final String toString() {
        return "FlvPacket(buffer=" + Arrays.toString(this.f2593a) + ", timeStamp=" + this.f2594b + ", length=" + this.f2595c + ", type=" + this.f2596d + ")";
    }

    public a(byte[] bArr, long j4, int i4, b bVar) {
        this.f2593a = bArr;
        this.f2594b = j4;
        this.f2595c = i4;
        this.f2596d = bVar;
    }
}
