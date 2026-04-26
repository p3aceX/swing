package O;

import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class L implements K {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1220a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ N f1221b;

    public L(N n4, int i4) {
        this.f1221b = n4;
        this.f1220a = i4;
    }

    @Override // O.K
    public final boolean a(ArrayList arrayList, ArrayList arrayList2) {
        N n4 = this.f1221b;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = n4.f1259y;
        int i4 = this.f1220a;
        if (abstractComponentCallbacksC0109u == null || i4 >= 0 || !abstractComponentCallbacksC0109u.m().Q()) {
            return n4.R(arrayList, arrayList2, i4, 1);
        }
        return false;
    }
}
