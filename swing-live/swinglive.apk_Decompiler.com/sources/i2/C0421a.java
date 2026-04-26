package i2;

/* JADX INFO: renamed from: i2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0421a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f4487a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4488b;

    public C0421a(int i4, int i5) {
        this.f4487a = i4;
        this.f4488b = i5;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0421a)) {
            return false;
        }
        C0421a c0421a = (C0421a) obj;
        return this.f4487a == c0421a.f4487a && this.f4488b == c0421a.f4488b;
    }

    public final int hashCode() {
        return Integer.hashCode(this.f4488b) + (Integer.hashCode(this.f4487a) * 31);
    }

    public final String toString() {
        return "Event(data=" + this.f4487a + ", bufferLength=" + this.f4488b + ")";
    }
}
