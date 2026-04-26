package O;

import android.util.Log;
import java.util.Iterator;
import java.util.concurrent.CopyOnWriteArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class E {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f1209a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final CopyOnWriteArrayList f1210b = new CopyOnWriteArrayList();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public J3.h f1211c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ N f1212d;

    public E(N n4) {
        this.f1212d = n4;
    }

    public final void a() {
        boolean zJ = N.J(3);
        N n4 = this.f1212d;
        if (zJ) {
            Log.d("FragmentManager", "handleOnBackCancelled. PREDICTIVE_BACK = true fragment manager " + n4);
        }
        C0090a c0090a = n4.f1243h;
        if (c0090a != null) {
            c0090a.f1319q = false;
            c0090a.d(false);
            n4.z(true);
            n4.D();
            Iterator it = n4.f1248m.iterator();
            if (it.hasNext()) {
                it.next().getClass();
                throw new ClassCastException();
            }
        }
        n4.f1243h = null;
    }
}
