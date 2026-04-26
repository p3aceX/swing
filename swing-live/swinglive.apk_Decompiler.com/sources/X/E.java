package X;

import A.C0002b;
import android.os.Bundle;
import android.view.View;
import androidx.recyclerview.widget.RecyclerView;

/* JADX INFO: loaded from: classes.dex */
public final class E extends C0002b {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final F f2284d;

    public E(F f4) {
        this.f2284d = f4;
    }

    @Override // A.C0002b
    public final void b(View view, B.j jVar) {
        this.f39a.onInitializeAccessibilityNodeInfo(view, jVar.f102a);
        F f4 = this.f2284d;
        if (f4.f2285d.l()) {
            return;
        }
        RecyclerView recyclerView = f4.f2285d;
        if (recyclerView.getLayoutManager() != null) {
            recyclerView.getLayoutManager().getClass();
            RecyclerView.j(view);
        }
    }

    @Override // A.C0002b
    public final boolean c(View view, int i4, Bundle bundle) {
        if (super.c(view, i4, bundle)) {
            return true;
        }
        F f4 = this.f2284d;
        if (!f4.f2285d.l()) {
            RecyclerView recyclerView = f4.f2285d;
            if (recyclerView.getLayoutManager() != null) {
                J1.c cVar = recyclerView.getLayoutManager().f2372b.f3155a;
            }
        }
        return false;
    }
}
