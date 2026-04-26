package com.swing.live;

import D2.AbstractActivityC0029d;
import Q3.F;
import V3.d;
import Y0.n;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class MainActivity extends AbstractActivityC0029d {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public n f3871f;

    @Override // D2.AbstractActivityC0029d, android.app.Activity
    public final void onDestroy() {
        super.onDestroy();
        n nVar = this.f3871f;
        if (nVar != null) {
            F.f((d) nVar.e);
            C0747k c0747k = (C0747k) nVar.f2489b;
            if (c0747k != null) {
                c0747k.Y(null);
            }
            C0747k c0747k2 = (C0747k) nVar.f2490c;
            if (c0747k2 != null) {
                c0747k2.Z(null);
            }
        }
        this.f3871f = null;
    }
}
