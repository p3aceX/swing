package io.flutter.plugin.platform;

import android.app.Activity;
import android.os.IBinder;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import java.lang.ref.WeakReference;

/* JADX INFO: loaded from: classes.dex */
public final class A implements View.OnAttachStateChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4601a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f4602b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f4603c;

    public A(FrameLayout frameLayout, m mVar) {
        this.f4602b = frameLayout;
        this.f4603c = mVar;
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewAttachedToWindow(View view) {
        Window window;
        WindowManager.LayoutParams attributes;
        switch (this.f4601a) {
            case 0:
                z zVar = new z(this, 0);
                FrameLayout frameLayout = (FrameLayout) this.f4602b;
                frameLayout.getViewTreeObserver().addOnDrawListener(new B(frameLayout, zVar));
                frameLayout.removeOnAttachStateChangeListener(this);
                break;
            default:
                J3.i.e(view, "view");
                view.removeOnAttachStateChangeListener(this);
                Activity activity = (Activity) ((WeakReference) this.f4603c).get();
                IBinder iBinder = (activity == null || (window = activity.getWindow()) == null || (attributes = window.getAttributes()) == null) ? null : attributes.token;
                if (activity != null && iBinder != null) {
                    ((l0.i) this.f4602b).c(iBinder, activity);
                }
                break;
        }
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewDetachedFromWindow(View view) {
        switch (this.f4601a) {
            case 0:
                break;
            default:
                J3.i.e(view, "view");
                break;
        }
    }

    public A(l0.i iVar, Activity activity) {
        J3.i.e(iVar, "sidecarCompat");
        this.f4602b = iVar;
        this.f4603c = new WeakReference(activity);
    }

    private final void a(View view) {
    }
}
