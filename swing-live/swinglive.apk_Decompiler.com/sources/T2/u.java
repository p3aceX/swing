package T2;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class u implements O2.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2000a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ String f2001b;

    public /* synthetic */ u(p1.d dVar, String str, int i4) {
        this.f2000a = i4;
        this.f2001b = str;
    }

    @Override // O2.c
    public final void f(Object obj) {
        switch (this.f2000a) {
            case 0:
                if (!(obj instanceof List)) {
                    H0.a.k(this.f2001b);
                } else {
                    List list = (List) obj;
                    if (list.size() > 1) {
                        new v(list.get(2), (String) list.get(0), (String) list.get(1));
                    }
                }
                break;
            case 1:
                if (!(obj instanceof List)) {
                    H0.a.k(this.f2001b);
                } else {
                    List list2 = (List) obj;
                    if (list2.size() > 1) {
                        new v(list2.get(2), (String) list2.get(0), (String) list2.get(1));
                    }
                }
                break;
            case 2:
                if (!(obj instanceof List)) {
                    H0.a.k(this.f2001b);
                } else {
                    List list3 = (List) obj;
                    if (list3.size() > 1) {
                        new v(list3.get(2), (String) list3.get(0), (String) list3.get(1));
                    }
                }
                break;
            default:
                if (!(obj instanceof List)) {
                    H0.a.k(this.f2001b);
                } else {
                    List list4 = (List) obj;
                    if (list4.size() > 1) {
                        new v(list4.get(2), (String) list4.get(0), (String) list4.get(1));
                    }
                }
                break;
        }
    }
}
