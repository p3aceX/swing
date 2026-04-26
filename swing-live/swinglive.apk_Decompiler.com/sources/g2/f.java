package g2;

import X.N;
import f2.EnumC0402b;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final N f4336c = new N(14);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final EnumC0402b f4337a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4338b;

    public f(EnumC0402b enumC0402b, int i4) {
        J3.i.e(enumC0402b, "chunkType");
        this.f4337a = enumC0402b;
        this.f4338b = i4;
    }

    public final String toString() {
        return "BasicHeader chunkType: " + this.f4337a + ", chunkStreamId: " + this.f4338b;
    }
}
