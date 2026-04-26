package io.flutter.plugin.platform;

import android.os.Build;

/* JADX INFO: loaded from: classes.dex */
public final class w implements io.flutter.view.r {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ x f4695a;

    public w(x xVar) {
        this.f4695a = xVar;
    }

    @Override // io.flutter.view.r
    public final void onTrimMemory(int i4) {
        if (i4 != 80 || Build.VERSION.SDK_INT < 29) {
            return;
        }
        this.f4695a.f4700f = true;
    }
}
