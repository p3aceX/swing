package M3;

/* JADX INFO: loaded from: classes.dex */
public final class f extends d {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final f f1102d = new f(1, 0, 1);

    @Override // M3.d
    public final boolean equals(Object obj) {
        if (!(obj instanceof f)) {
            return false;
        }
        if (isEmpty() && ((f) obj).isEmpty()) {
            return true;
        }
        f fVar = (f) obj;
        if (this.f1095a == fVar.f1095a) {
            return this.f1096b == fVar.f1096b;
        }
        return false;
    }

    @Override // M3.d
    public final int hashCode() {
        if (isEmpty()) {
            return -1;
        }
        return (this.f1095a * 31) + this.f1096b;
    }

    @Override // M3.d
    public final boolean isEmpty() {
        return this.f1095a > this.f1096b;
    }

    @Override // M3.d
    public final String toString() {
        return this.f1095a + ".." + this.f1096b;
    }
}
