package O;

import android.animation.AnimatorSet;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import android.view.ViewGroup;
import b.C0225b;

/* JADX INFO: renamed from: O.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0098i extends Y {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0096g f1349b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public AnimatorSet f1350c;

    public C0098i(C0096g c0096g) {
        this.f1349b = c0096g;
    }

    @Override // O.Y
    public final void a(ViewGroup viewGroup) {
        J3.i.e(viewGroup, "container");
        AnimatorSet animatorSet = this.f1350c;
        animatorSet.getClass();
        animatorSet.start();
        if (N.J(2)) {
            Log.v("FragmentManager", "Animator from operation " + ((Object) null) + " has started.");
        }
    }

    @Override // O.Y
    public final void b(C0225b c0225b, ViewGroup viewGroup) {
        J3.i.e(c0225b, "backEvent");
        J3.i.e(viewGroup, "container");
        this.f1350c.getClass();
        if (Build.VERSION.SDK_INT >= 34) {
            throw null;
        }
    }

    @Override // O.Y
    public final void c(ViewGroup viewGroup) {
        J3.i.e(viewGroup, "container");
        C0096g c0096g = this.f1349b;
        if (c0096g.N()) {
            return;
        }
        Context context = viewGroup.getContext();
        J3.i.d(context, "context");
        D2.v vVarP0 = c0096g.p0(context);
        this.f1350c = vVarP0 != null ? (AnimatorSet) vVarP0.f261c : null;
        throw null;
    }
}
