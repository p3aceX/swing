package q3;

import o3.C0599g;

/* JADX INFO: renamed from: q3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0637b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final EnumC0636a f6276a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final EnumC0642g f6277b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0599g f6278c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f6279d;

    public C0637b(EnumC0636a enumC0636a, EnumC0642g enumC0642g, C0599g c0599g) {
        this.f6276a = enumC0636a;
        this.f6277b = enumC0642g;
        this.f6278c = c0599g;
        this.f6279d = enumC0636a.name() + "with" + enumC0642g.name();
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0637b)) {
            return false;
        }
        C0637b c0637b = (C0637b) obj;
        return this.f6276a == c0637b.f6276a && this.f6277b == c0637b.f6277b && J3.i.a(this.f6278c, c0637b.f6278c);
    }

    public final int hashCode() {
        int iHashCode = (this.f6277b.hashCode() + (this.f6276a.hashCode() * 31)) * 31;
        C0599g c0599g = this.f6278c;
        return iHashCode + (c0599g == null ? 0 : c0599g.f6097a.hashCode());
    }

    public final String toString() {
        return "HashAndSign(hash=" + this.f6276a + ", sign=" + this.f6277b + ", oid=" + this.f6278c + ')';
    }
}
