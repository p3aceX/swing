package E2;

import android.util.SparseArray;
import io.flutter.plugin.platform.p;
import io.flutter.plugin.platform.q;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class a implements b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ c f338a;

    public a(c cVar) {
        this.f338a = cVar;
    }

    @Override // E2.b
    public final void a() {
        c cVar = this.f338a;
        Iterator it = cVar.v.iterator();
        while (it.hasNext()) {
            ((b) it.next()).a();
        }
        while (true) {
            q qVar = cVar.f358s;
            SparseArray sparseArray = qVar.f4676r;
            if (sparseArray.size() <= 0) {
                break;
            }
            qVar.f4665C.p(sparseArray.keyAt(0));
        }
        while (true) {
            p pVar = cVar.f359t;
            SparseArray sparseArray2 = pVar.f4655o;
            if (sparseArray2.size() <= 0) {
                cVar.f350k.f1170b = null;
                return;
            } else {
                pVar.v.p(sparseArray2.keyAt(0));
            }
        }
    }

    @Override // E2.b
    public final void b() {
    }
}
