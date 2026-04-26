package f0;

import I.V;
import J3.i;
import P3.m;
import java.math.BigInteger;

/* JADX INFO: loaded from: classes.dex */
public final class h implements Comparable {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final h f4279f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f4280a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4281b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f4282c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f4283d;
    public final w3.f e = new w3.f(new V(this, 3));

    static {
        new h(0, 0, 0, "");
        f4279f = new h(0, 1, 0, "");
        new h(1, 0, 0, "");
    }

    public h(int i4, int i5, int i6, String str) {
        this.f4280a = i4;
        this.f4281b = i5;
        this.f4282c = i6;
        this.f4283d = str;
    }

    @Override // java.lang.Comparable
    public final int compareTo(Object obj) {
        h hVar = (h) obj;
        i.e(hVar, "other");
        Object objA = this.e.a();
        i.d(objA, "<get-bigInteger>(...)");
        Object objA2 = hVar.e.a();
        i.d(objA2, "<get-bigInteger>(...)");
        return ((BigInteger) objA).compareTo((BigInteger) objA2);
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof h)) {
            return false;
        }
        h hVar = (h) obj;
        return this.f4280a == hVar.f4280a && this.f4281b == hVar.f4281b && this.f4282c == hVar.f4282c;
    }

    public final int hashCode() {
        return ((((527 + this.f4280a) * 31) + this.f4281b) * 31) + this.f4282c;
    }

    public final String toString() {
        String str = this.f4283d;
        String strM = !m.v0(str) ? B1.a.m("-", str) : "";
        StringBuilder sb = new StringBuilder();
        sb.append(this.f4280a);
        sb.append('.');
        sb.append(this.f4281b);
        sb.append('.');
        return B1.a.n(sb, this.f4282c, strM);
    }
}
