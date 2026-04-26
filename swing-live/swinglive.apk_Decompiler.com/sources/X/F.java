package X;

import A.C0002b;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import androidx.recyclerview.widget.RecyclerView;

/* JADX INFO: loaded from: classes.dex */
public final class F extends C0002b {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final RecyclerView f2285d;

    public F(RecyclerView recyclerView) {
        this.f2285d = recyclerView;
        new E(this);
    }

    @Override // A.C0002b
    public final void a(View view, AccessibilityEvent accessibilityEvent) {
        super.a(view, accessibilityEvent);
        accessibilityEvent.setClassName(RecyclerView.class.getName());
        if (!(view instanceof RecyclerView) || this.f2285d.l()) {
            return;
        }
        RecyclerView recyclerView = (RecyclerView) view;
        if (recyclerView.getLayoutManager() != null) {
            recyclerView.getLayoutManager().A(accessibilityEvent);
        }
    }

    @Override // A.C0002b
    public final void b(View view, B.j jVar) {
        View.AccessibilityDelegate accessibilityDelegate = this.f39a;
        AccessibilityNodeInfo accessibilityNodeInfo = jVar.f102a;
        accessibilityDelegate.onInitializeAccessibilityNodeInfo(view, accessibilityNodeInfo);
        accessibilityNodeInfo.setClassName("androidx.recyclerview.widget.RecyclerView");
        RecyclerView recyclerView = this.f2285d;
        if (recyclerView.l() || recyclerView.getLayoutManager() == null) {
            return;
        }
        t layoutManager = recyclerView.getLayoutManager();
        RecyclerView recyclerView2 = layoutManager.f2372b;
        J1.c cVar = recyclerView2.f3155a;
        if (recyclerView2.canScrollVertically(-1) || layoutManager.f2372b.canScrollHorizontally(-1)) {
            accessibilityNodeInfo.addAction(8192);
            accessibilityNodeInfo.setScrollable(true);
        }
        if (layoutManager.f2372b.canScrollVertically(1) || layoutManager.f2372b.canScrollHorizontally(1)) {
            accessibilityNodeInfo.addAction(4096);
            accessibilityNodeInfo.setScrollable(true);
        }
        B b5 = recyclerView2.f3162d0;
        accessibilityNodeInfo.setCollectionInfo(AccessibilityNodeInfo.CollectionInfo.obtain(layoutManager.x(cVar, b5), layoutManager.q(cVar, b5), false, 0));
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x0056 A[PHI: r0
      0x0056: PHI (r0v8 int) = (r0v4 int), (r0v12 int) binds: [B:27:0x0073, B:19:0x0046] A[DONT_GENERATE, DONT_INLINE]] */
    @Override // A.C0002b
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean c(android.view.View r4, int r5, android.os.Bundle r6) {
        /*
            r3 = this;
            boolean r4 = super.c(r4, r5, r6)
            r6 = 1
            if (r4 == 0) goto L8
            return r6
        L8:
            androidx.recyclerview.widget.RecyclerView r4 = r3.f2285d
            boolean r0 = r4.l()
            r1 = 0
            if (r0 != 0) goto L8c
            X.t r0 = r4.getLayoutManager()
            if (r0 == 0) goto L8c
            X.t r4 = r4.getLayoutManager()
            androidx.recyclerview.widget.RecyclerView r0 = r4.f2372b
            J1.c r2 = r0.f3155a
            r2 = 4096(0x1000, float:5.74E-42)
            if (r5 == r2) goto L58
            r2 = 8192(0x2000, float:1.148E-41)
            if (r5 == r2) goto L2a
            r5 = r1
            r0 = r5
            goto L81
        L2a:
            r5 = -1
            boolean r0 = r0.canScrollVertically(r5)
            if (r0 == 0) goto L3f
            int r0 = r4.f2376g
            int r2 = r4.u()
            int r0 = r0 - r2
            int r2 = r4.r()
            int r0 = r0 - r2
            int r0 = -r0
            goto L40
        L3f:
            r0 = r1
        L40:
            androidx.recyclerview.widget.RecyclerView r2 = r4.f2372b
            boolean r5 = r2.canScrollHorizontally(r5)
            if (r5 == 0) goto L56
            int r5 = r4.f2375f
            int r2 = r4.s()
            int r5 = r5 - r2
            int r2 = r4.t()
            int r5 = r5 - r2
            int r5 = -r5
            goto L81
        L56:
            r5 = r1
            goto L81
        L58:
            boolean r5 = r0.canScrollVertically(r6)
            if (r5 == 0) goto L6c
            int r5 = r4.f2376g
            int r0 = r4.u()
            int r5 = r5 - r0
            int r0 = r4.r()
            int r5 = r5 - r0
            r0 = r5
            goto L6d
        L6c:
            r0 = r1
        L6d:
            androidx.recyclerview.widget.RecyclerView r5 = r4.f2372b
            boolean r5 = r5.canScrollHorizontally(r6)
            if (r5 == 0) goto L56
            int r5 = r4.f2375f
            int r2 = r4.s()
            int r5 = r5 - r2
            int r2 = r4.t()
            int r5 = r5 - r2
        L81:
            if (r0 != 0) goto L86
            if (r5 != 0) goto L86
            goto L8c
        L86:
            androidx.recyclerview.widget.RecyclerView r4 = r4.f2372b
            r4.r(r5, r0)
            return r6
        L8c:
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: X.F.c(android.view.View, int, android.os.Bundle):boolean");
    }
}
