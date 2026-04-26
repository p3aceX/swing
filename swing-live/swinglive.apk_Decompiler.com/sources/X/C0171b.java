package X;

/* JADX INFO: renamed from: X.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0171b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f2309a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0171b f2310b;

    public final int a(int i4) {
        C0171b c0171b = this.f2310b;
        if (c0171b == null) {
            return i4 >= 64 ? Long.bitCount(this.f2309a) : Long.bitCount(this.f2309a & ((1 << i4) - 1));
        }
        if (i4 < 64) {
            return Long.bitCount(this.f2309a & ((1 << i4) - 1));
        }
        return Long.bitCount(this.f2309a) + c0171b.a(i4 - 64);
    }

    public final boolean b(int i4) {
        if (i4 < 64) {
            return (this.f2309a & (1 << i4)) != 0;
        }
        if (this.f2310b == null) {
            this.f2310b = new C0171b();
        }
        return this.f2310b.b(i4 - 64);
    }

    public final void c() {
        this.f2309a = 0L;
        C0171b c0171b = this.f2310b;
        if (c0171b != null) {
            c0171b.c();
        }
    }

    public final String toString() {
        if (this.f2310b == null) {
            return Long.toBinaryString(this.f2309a);
        }
        return this.f2310b.toString() + "xx" + Long.toBinaryString(this.f2309a);
    }
}
