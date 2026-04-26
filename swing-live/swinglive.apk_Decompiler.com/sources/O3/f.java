package O3;

import Q3.p0;
import e1.k;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class f implements c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1466a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1467b;

    public /* synthetic */ f(Object obj, int i4) {
        this.f1466a = i4;
        this.f1467b = obj;
    }

    @Override // O3.c
    public final Iterator iterator() {
        switch (this.f1466a) {
            case 0:
                p0 p0Var = (p0) this.f1467b;
                d dVar = new d();
                dVar.f1465c = k.l(p0Var, dVar, dVar);
                return dVar;
            case 1:
                return (Iterator) this.f1467b;
            default:
                return new P3.d((String) this.f1467b);
        }
    }
}
