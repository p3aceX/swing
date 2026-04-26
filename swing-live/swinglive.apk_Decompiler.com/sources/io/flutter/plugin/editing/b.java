package io.flutter.plugin.editing;

import android.view.View;
import android.view.WindowInsets;

/* JADX INFO: loaded from: classes.dex */
public final class b implements View.OnApplyWindowInsetsListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ ImeSyncDeferringInsetsCallback f4549a;

    public b(ImeSyncDeferringInsetsCallback imeSyncDeferringInsetsCallback) {
        this.f4549a = imeSyncDeferringInsetsCallback;
    }

    @Override // android.view.View.OnApplyWindowInsetsListener
    public final WindowInsets onApplyWindowInsets(View view, WindowInsets windowInsets) {
        ImeSyncDeferringInsetsCallback imeSyncDeferringInsetsCallback = this.f4549a;
        imeSyncDeferringInsetsCallback.view = view;
        if (imeSyncDeferringInsetsCallback.needsSave) {
            imeSyncDeferringInsetsCallback.lastWindowInsets = windowInsets;
            imeSyncDeferringInsetsCallback.needsSave = false;
        }
        return imeSyncDeferringInsetsCallback.animating ? WindowInsets.CONSUMED : view.onApplyWindowInsets(windowInsets);
    }
}
