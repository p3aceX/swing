package S3;

/* JADX INFO: loaded from: classes.dex */
public final class k extends l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Throwable f1852a;

    public k(Throwable th) {
        this.f1852a = th;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof k) {
            return J3.i.a(this.f1852a, ((k) obj).f1852a);
        }
        return false;
    }

    public final int hashCode() {
        Throwable th = this.f1852a;
        if (th != null) {
            return th.hashCode();
        }
        return 0;
    }

    @Override // S3.l
    public final String toString() {
        return "Closed(" + this.f1852a + ')';
    }
}
