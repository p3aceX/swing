package l1;

/* JADX INFO: loaded from: classes.dex */
public final class i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final r f5609a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f5610b;

    public i(r rVar, boolean z4) {
        this.f5609a = rVar;
        this.f5610b = z4;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof i) {
            i iVar = (i) obj;
            if (iVar.f5609a.equals(this.f5609a) && iVar.f5610b == this.f5610b) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return ((this.f5609a.hashCode() ^ 1000003) * 1000003) ^ Boolean.valueOf(this.f5610b).hashCode();
    }
}
