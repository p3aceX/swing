package io.flutter.view;

import android.view.accessibility.AccessibilityManager;

/* JADX INFO: loaded from: classes.dex */
public final class g implements AccessibilityManager.TouchExplorationStateChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ AccessibilityManager f4705a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ k f4706b;

    public g(k kVar, AccessibilityManager accessibilityManager) {
        this.f4706b = kVar;
        this.f4705a = accessibilityManager;
    }

    @Override // android.view.accessibility.AccessibilityManager.TouchExplorationStateChangeListener
    public final void onTouchExplorationStateChanged(boolean z4) {
        k kVar = this.f4706b;
        if (kVar.f4807u) {
            return;
        }
        boolean z5 = false;
        if (!z4) {
            kVar.j(false);
            j jVar = kVar.f4802p;
            if (jVar != null) {
                kVar.h(jVar.f4762b, 256);
                kVar.f4802p = null;
            }
        }
        B.k kVar2 = kVar.f4805s;
        if (kVar2 != null) {
            boolean zIsEnabled = this.f4705a.isEnabled();
            D2.r rVar = (D2.r) kVar2.f104b;
            if (rVar.f246p.f342b.f4535a.getIsSoftwareRenderingEnabled()) {
                rVar.setWillNotDraw(false);
                return;
            }
            if (!zIsEnabled && !z4) {
                z5 = true;
            }
            rVar.setWillNotDraw(z5);
        }
    }
}
