package i0;

/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final f0.b f4465a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final b f4466b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final b f4467c;

    public c(f0.b bVar, b bVar2, b bVar3) {
        this.f4465a = bVar;
        this.f4466b = bVar2;
        this.f4467c = bVar3;
        int i4 = bVar.f4267c;
        int i5 = bVar.f4265a;
        int i6 = i4 - i5;
        int i7 = bVar.f4266b;
        if (i6 == 0 && bVar.f4268d - i7 == 0) {
            throw new IllegalArgumentException("Bounds must be non zero");
        }
        if (i5 != 0 && i7 != 0) {
            throw new IllegalArgumentException("Bounding rectangle must start at the top or left window edge for folding features");
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!c.class.equals(obj != null ? obj.getClass() : null)) {
            return false;
        }
        J3.i.c(obj, "null cannot be cast to non-null type androidx.window.layout.HardwareFoldingFeature");
        c cVar = (c) obj;
        return J3.i.a(this.f4465a, cVar.f4465a) && J3.i.a(this.f4466b, cVar.f4466b) && J3.i.a(this.f4467c, cVar.f4467c);
    }

    public final int hashCode() {
        return this.f4467c.hashCode() + ((this.f4466b.hashCode() + (this.f4465a.hashCode() * 31)) * 31);
    }

    public final String toString() {
        return c.class.getSimpleName() + " { " + this.f4465a + ", type=" + this.f4466b + ", state=" + this.f4467c + " }";
    }
}
