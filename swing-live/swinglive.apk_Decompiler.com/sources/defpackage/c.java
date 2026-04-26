package defpackage;

import I3.a;
import J3.i;
import P3.m;
import java.util.List;
import l3.C0525b;
import r3.C0655a;
import t3.AbstractC0685a;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class c implements a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3293a;

    public /* synthetic */ c(int i4) {
        this.f3293a = i4;
    }

    @Override // I3.a
    public final Object a() {
        int i4 = 1;
        switch (this.f3293a) {
            case 0:
                return new g();
            case 1:
                int i5 = AbstractC0685a.f6588a;
                return Long.valueOf(System.currentTimeMillis());
            case 2:
                return new C0525b(i4);
            default:
                C0655a c0655a = C0655a.f6429c;
                String property = System.getProperty("java.version");
                i.d(property, "getProperty(...)");
                try {
                    List listE0 = m.E0(property, new char[]{'-', '_'});
                    return listE0.size() == 2 ? new C0655a((String) listE0.get(0), Integer.parseInt((String) listE0.get(1))) : new C0655a(property, -1);
                } catch (Throwable unused) {
                    return C0655a.f6429c;
                }
        }
    }
}
