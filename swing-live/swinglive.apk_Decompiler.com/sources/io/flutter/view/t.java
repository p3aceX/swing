package io.flutter.view;

import android.hardware.display.DisplayManager;

/* JADX INFO: loaded from: classes.dex */
public final class t implements DisplayManager.DisplayListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final DisplayManager f4821a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ v f4822b;

    public t(v vVar, DisplayManager displayManager) {
        this.f4822b = vVar;
        this.f4821a = displayManager;
    }

    @Override // android.hardware.display.DisplayManager.DisplayListener
    public final void onDisplayAdded(int i4) {
    }

    @Override // android.hardware.display.DisplayManager.DisplayListener
    public final void onDisplayChanged(int i4) {
        if (i4 == 0) {
            float refreshRate = this.f4821a.getDisplay(0).getRefreshRate();
            v vVar = this.f4822b;
            vVar.f4826a = (long) (1.0E9d / ((double) refreshRate));
            vVar.f4827b.setRefreshRateFPS(refreshRate);
        }
    }

    @Override // android.hardware.display.DisplayManager.DisplayListener
    public final void onDisplayRemoved(int i4) {
    }
}
