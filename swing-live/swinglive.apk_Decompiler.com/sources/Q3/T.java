package Q3;

/* JADX INFO: loaded from: classes.dex */
public final class T implements InterfaceC0124d0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f1599a;

    public T(boolean z4) {
        this.f1599a = z4;
    }

    @Override // Q3.InterfaceC0124d0
    public final boolean b() {
        return this.f1599a;
    }

    @Override // Q3.InterfaceC0124d0
    public final s0 d() {
        return null;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("Empty{");
        sb.append(this.f1599a ? "Active" : "New");
        sb.append('}');
        return sb.toString();
    }
}
