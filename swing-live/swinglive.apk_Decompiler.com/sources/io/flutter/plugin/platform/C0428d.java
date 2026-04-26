package io.flutter.plugin.platform;

import D2.C0033h;
import android.view.MotionEvent;

/* JADX INFO: renamed from: io.flutter.plugin.platform.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0428d extends C0033h {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public C0425a f4623n;

    @Override // android.view.View
    public final boolean onHoverEvent(MotionEvent motionEvent) {
        C0425a c0425a = this.f4623n;
        if (c0425a != null) {
            io.flutter.view.k kVar = c0425a.f4616a;
            if (kVar == null ? false : kVar.f(motionEvent, true)) {
                return true;
            }
        }
        return super.onHoverEvent(motionEvent);
    }
}
