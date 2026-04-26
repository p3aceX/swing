package N1;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1125a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1126b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1127c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f1128d;

    public a(int i4, int i5, int i6, int i7) {
        this.f1125a = i4;
        this.f1126b = i5;
        this.f1127c = i6;
        this.f1128d = i7;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof a)) {
            return false;
        }
        a aVar = (a) obj;
        return this.f1125a == aVar.f1125a && this.f1126b == aVar.f1126b && this.f1127c == aVar.f1127c && this.f1128d == aVar.f1128d;
    }

    public final int hashCode() {
        return Integer.hashCode(this.f1128d) + B1.a.h(this.f1127c, B1.a.h(this.f1126b, Integer.hashCode(this.f1125a) * 31, 31), 31);
    }

    public final String toString() {
        return "ViewPort(x=" + this.f1125a + ", y=" + this.f1126b + ", width=" + this.f1127c + ", height=" + this.f1128d + ")";
    }
}
