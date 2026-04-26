package O;

import android.view.ViewGroup;
import b.C0225b;

/* JADX INFO: loaded from: classes.dex */
public abstract class Y {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f1301a;

    public abstract void a(ViewGroup viewGroup);

    public void b(C0225b c0225b, ViewGroup viewGroup) {
        J3.i.e(c0225b, "backEvent");
        J3.i.e(viewGroup, "container");
    }

    public void c(ViewGroup viewGroup) {
        J3.i.e(viewGroup, "container");
    }
}
