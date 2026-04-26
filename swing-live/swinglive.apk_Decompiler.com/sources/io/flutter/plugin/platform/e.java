package io.flutter.plugin.platform;

import T2.RunnableC0169n;
import android.view.View;

/* JADX INFO: loaded from: classes.dex */
public final class e implements View.OnSystemUiVisibilityChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ View f4624a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ f f4625b;

    public e(f fVar, View view) {
        this.f4625b = fVar;
        this.f4624a = view;
    }

    @Override // android.view.View.OnSystemUiVisibilityChangeListener
    public final void onSystemUiVisibilityChange(int i4) {
        this.f4624a.post(new RunnableC0169n(this, i4, 1));
    }
}
