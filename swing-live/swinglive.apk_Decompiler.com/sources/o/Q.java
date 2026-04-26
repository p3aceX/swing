package O;

import android.util.Log;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class Q extends androidx.lifecycle.F {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final boolean f1271f;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final HashMap f1269c = new HashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final HashMap f1270d = new HashMap();
    public final HashMap e = new HashMap();

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f1272g = false;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f1273h = false;

    public Q(boolean z4) {
        this.f1271f = z4;
    }

    @Override // androidx.lifecycle.F
    public final void a() {
        if (N.J(3)) {
            Log.d("FragmentManager", "onCleared called for " + this);
        }
        this.f1272g = true;
    }

    public final void b(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        if (N.J(3)) {
            Log.d("FragmentManager", "Clearing non-config state for " + abstractComponentCallbacksC0109u);
        }
        d(abstractComponentCallbacksC0109u.e, z4);
    }

    public final void c(String str, boolean z4) {
        if (N.J(3)) {
            Log.d("FragmentManager", "Clearing non-config state for saved state of Fragment " + str);
        }
        d(str, z4);
    }

    public final void d(String str, boolean z4) {
        HashMap map = this.f1270d;
        Q q4 = (Q) map.get(str);
        if (q4 != null) {
            if (z4) {
                ArrayList arrayList = new ArrayList();
                arrayList.addAll(q4.f1270d.keySet());
                Iterator it = arrayList.iterator();
                while (it.hasNext()) {
                    q4.c((String) it.next(), true);
                }
            }
            q4.a();
            map.remove(str);
        }
        HashMap map2 = this.e;
        androidx.lifecycle.H h4 = (androidx.lifecycle.H) map2.get(str);
        if (h4 != null) {
            h4.a();
            map2.remove(str);
        }
    }

    public final void e(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (this.f1273h) {
            if (N.J(2)) {
                Log.v("FragmentManager", "Ignoring removeRetainedFragment as the state is already saved");
            }
        } else {
            if (this.f1269c.remove(abstractComponentCallbacksC0109u.e) == null || !N.J(2)) {
                return;
            }
            Log.v("FragmentManager", "Updating retained Fragments: Removed " + abstractComponentCallbacksC0109u);
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && Q.class == obj.getClass()) {
            Q q4 = (Q) obj;
            if (this.f1269c.equals(q4.f1269c) && this.f1270d.equals(q4.f1270d) && this.e.equals(q4.e)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return this.e.hashCode() + ((this.f1270d.hashCode() + (this.f1269c.hashCode() * 31)) * 31);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("FragmentManagerViewModel{");
        sb.append(Integer.toHexString(System.identityHashCode(this)));
        sb.append("} Fragments (");
        Iterator it = this.f1269c.values().iterator();
        while (it.hasNext()) {
            sb.append(it.next());
            if (it.hasNext()) {
                sb.append(", ");
            }
        }
        sb.append(") Child Non Config (");
        Iterator it2 = this.f1270d.keySet().iterator();
        while (it2.hasNext()) {
            sb.append((String) it2.next());
            if (it2.hasNext()) {
                sb.append(", ");
            }
        }
        sb.append(") ViewModelStores (");
        Iterator it3 = this.e.keySet().iterator();
        while (it3.hasNext()) {
            sb.append((String) it3.next());
            if (it3.hasNext()) {
                sb.append(", ");
            }
        }
        sb.append(')');
        return sb.toString();
    }
}
