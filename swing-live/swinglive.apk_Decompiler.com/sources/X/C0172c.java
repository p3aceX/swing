package X;

import java.util.ArrayList;

/* JADX INFO: renamed from: X.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0172c extends s {
    public ArrayList e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ArrayList f2311f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public ArrayList f2312g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public ArrayList f2313h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public ArrayList f2314i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public ArrayList f2315j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public ArrayList f2316k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public ArrayList f2317l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ArrayList f2318m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public ArrayList f2319n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public ArrayList f2320o;

    public static void c(ArrayList arrayList) {
        int size = arrayList.size() - 1;
        if (size < 0) {
            return;
        }
        arrayList.get(size).getClass();
        throw new ClassCastException();
    }

    @Override // X.s
    public final void a() {
        ArrayList arrayList = this.f2312g;
        int size = arrayList.size() - 1;
        if (size >= 0) {
            B1.a.p(arrayList.get(size));
            throw null;
        }
        ArrayList arrayList2 = this.e;
        for (int size2 = arrayList2.size() - 1; size2 >= 0; size2--) {
            if (arrayList2.get(size2) != null) {
                throw new ClassCastException();
            }
            if (this.f2367a != null) {
                throw null;
            }
            arrayList2.remove(size2);
        }
        ArrayList arrayList3 = this.f2311f;
        int size3 = arrayList3.size() - 1;
        if (size3 >= 0) {
            arrayList3.get(size3).getClass();
            throw new ClassCastException();
        }
        ArrayList arrayList4 = this.f2313h;
        int size4 = arrayList4.size() - 1;
        if (size4 >= 0) {
            B1.a.p(arrayList4.get(size4));
            throw null;
        }
        arrayList4.clear();
        if (b()) {
            ArrayList arrayList5 = this.f2315j;
            for (int size5 = arrayList5.size() - 1; size5 >= 0; size5--) {
                ArrayList arrayList6 = (ArrayList) arrayList5.get(size5);
                int size6 = arrayList6.size() - 1;
                if (size6 >= 0) {
                    B1.a.p(arrayList6.get(size6));
                    throw null;
                }
            }
            ArrayList arrayList7 = this.f2314i;
            for (int size7 = arrayList7.size() - 1; size7 >= 0; size7--) {
                ArrayList arrayList8 = (ArrayList) arrayList7.get(size7);
                int size8 = arrayList8.size() - 1;
                if (size8 >= 0) {
                    arrayList8.get(size8).getClass();
                    throw new ClassCastException();
                }
            }
            ArrayList arrayList9 = this.f2316k;
            for (int size9 = arrayList9.size() - 1; size9 >= 0; size9--) {
                ArrayList arrayList10 = (ArrayList) arrayList9.get(size9);
                int size10 = arrayList10.size() - 1;
                if (size10 >= 0) {
                    B1.a.p(arrayList10.get(size10));
                    throw null;
                }
            }
            c(this.f2319n);
            c(this.f2318m);
            c(this.f2317l);
            c(this.f2320o);
            ArrayList arrayList11 = this.f2368b;
            if (arrayList11.size() > 0) {
                arrayList11.get(0).getClass();
                throw new ClassCastException();
            }
            arrayList11.clear();
        }
    }

    @Override // X.s
    public final boolean b() {
        return (this.f2311f.isEmpty() && this.f2313h.isEmpty() && this.f2312g.isEmpty() && this.e.isEmpty() && this.f2318m.isEmpty() && this.f2319n.isEmpty() && this.f2317l.isEmpty() && this.f2320o.isEmpty() && this.f2315j.isEmpty() && this.f2314i.isEmpty() && this.f2316k.isEmpty()) ? false : true;
    }
}
