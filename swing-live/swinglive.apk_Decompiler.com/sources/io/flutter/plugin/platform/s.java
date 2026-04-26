package io.flutter.plugin.platform;

import android.content.Context;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.widget.FrameLayout;

/* JADX INFO: loaded from: classes.dex */
public final class s extends FrameLayout {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0425a f4686a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final FrameLayout f4687b;

    public s(Context context, C0425a c0425a, FrameLayout frameLayout) {
        super(context);
        this.f4686a = c0425a;
        this.f4687b = frameLayout;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean requestSendAccessibilityEvent(View view, AccessibilityEvent accessibilityEvent) {
        io.flutter.view.k kVar = this.f4686a.f4616a;
        if (kVar == null) {
            return false;
        }
        return kVar.a(this.f4687b, view, accessibilityEvent);
    }
}
