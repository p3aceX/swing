package io.flutter.view;

import android.view.accessibility.AccessibilityManager;
import io.flutter.embedding.engine.FlutterJNI;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class f implements AccessibilityManager.AccessibilityStateChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ k f4704a;

    public f(k kVar) {
        this.f4704a = kVar;
    }

    @Override // android.view.accessibility.AccessibilityManager.AccessibilityStateChangeListener
    public final void onAccessibilityStateChanged(boolean z4) {
        k kVar = this.f4704a;
        if (kVar.f4807u) {
            return;
        }
        boolean z5 = false;
        C0747k c0747k = kVar.f4789b;
        if (z4) {
            ((FlutterJNI) c0747k.f6832c).setSemanticsEnabled(true);
        } else {
            kVar.j(false);
            ((FlutterJNI) c0747k.f6832c).setSemanticsEnabled(false);
        }
        B.k kVar2 = kVar.f4805s;
        if (kVar2 != null) {
            boolean zIsTouchExplorationEnabled = kVar.f4790c.isTouchExplorationEnabled();
            D2.r rVar = (D2.r) kVar2.f104b;
            if (rVar.f246p.f342b.f4535a.getIsSoftwareRenderingEnabled()) {
                rVar.setWillNotDraw(false);
                return;
            }
            if (!z4 && !zIsTouchExplorationEnabled) {
                z5 = true;
            }
            rVar.setWillNotDraw(z5);
        }
    }
}
