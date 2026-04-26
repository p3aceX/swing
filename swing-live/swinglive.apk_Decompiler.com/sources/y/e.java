package Y;

import android.os.Bundle;
import m.C0541c;
import m.C0544f;

/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f2458a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f2459b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f2460c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f2461d;

    public Bundle a(String str) {
        if (!this.f2459b) {
            throw new IllegalStateException("You can consumeRestoredStateForKey only after super.onCreate of corresponding component");
        }
        Bundle bundle = (Bundle) this.f2461d;
        if (bundle == null) {
            return null;
        }
        Bundle bundle2 = bundle.getBundle(str);
        Bundle bundle3 = (Bundle) this.f2461d;
        if (bundle3 != null) {
            bundle3.remove(str);
        }
        Bundle bundle4 = (Bundle) this.f2461d;
        if (bundle4 != null && !bundle4.isEmpty()) {
            return bundle2;
        }
        this.f2461d = null;
        return bundle2;
    }

    public void b(String str, d dVar) {
        Object obj;
        C0544f c0544f = (C0544f) this.f2460c;
        C0541c c0541cF = c0544f.f(str);
        if (c0541cF != null) {
            obj = c0541cF.f5752b;
        } else {
            C0541c c0541c = new C0541c(str, dVar);
            c0544f.f5761d++;
            C0541c c0541c2 = c0544f.f5759b;
            if (c0541c2 == null) {
                c0544f.f5758a = c0541c;
                c0544f.f5759b = c0541c;
            } else {
                c0541c2.f5753c = c0541c;
                c0541c.f5754d = c0541c2;
                c0544f.f5759b = c0541c;
            }
            obj = null;
        }
        if (((d) obj) != null) {
            throw new IllegalArgumentException("SavedStateProvider with the given key is already registered");
        }
    }
}
