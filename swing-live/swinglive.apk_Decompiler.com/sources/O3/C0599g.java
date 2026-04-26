package o3;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import x3.AbstractC0728h;
import x3.AbstractC0730j;

/* JADX INFO: renamed from: o3.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0599g {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0599g f6092b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0599g f6093c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0599g f6094d;
    public static final C0599g e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final C0599g f6095f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final C0599g f6096g;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6097a;

    static {
        new C0599g("2.5.4.10");
        new C0599g("2.5.4.11");
        new C0599g("2.5.4.6");
        new C0599g("2.5.4.3");
        new C0599g("2.5.29.17");
        new C0599g("2.5.29.19");
        new C0599g("2.5.29.15");
        new C0599g("2.5.29.37");
        new C0599g("1.3.6.1.5.5.7.3.1");
        new C0599g("1.3.6.1.5.5.7.3.2");
        new C0599g("1 2 840 113549 1 1 1");
        new C0599g("1.2.840.10045.2.1");
        f6092b = new C0599g("1.2.840.10045.4.3.3");
        f6093c = new C0599g("1.2.840.10045.4.3.2");
        f6094d = new C0599g("1.2.840.113549.1.1.13");
        e = new C0599g("1.2.840.113549.1.1.12");
        f6095f = new C0599g("1.2.840.113549.1.1.11");
        f6096g = new C0599g("1.2.840.113549.1.1.5");
        new C0599g("1.2.840.10045.3.1.7");
    }

    public C0599g(String str) {
        this.f6097a = str;
        List listD0 = P3.m.D0(str, new String[]{".", " "});
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(listD0));
        Iterator it = listD0.iterator();
        while (it.hasNext()) {
            arrayList.add(Integer.valueOf(Integer.parseInt(P3.m.J0((String) it.next()).toString())));
        }
        AbstractC0728h.h0(arrayList);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        return (obj instanceof C0599g) && J3.i.a(this.f6097a, ((C0599g) obj).f6097a);
    }

    public final int hashCode() {
        return this.f6097a.hashCode();
    }

    public final String toString() {
        return "OID(identifier=" + this.f6097a + ')';
    }
}
