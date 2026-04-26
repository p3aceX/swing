package A;

import android.view.View;
import android.view.ViewTreeObserver;

/* JADX INFO: renamed from: A.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ViewTreeObserverOnPreDrawListenerC0014n implements ViewTreeObserver.OnPreDrawListener, View.OnAttachStateChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f57a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ViewTreeObserver f58b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Runnable f59c;

    public ViewTreeObserverOnPreDrawListenerC0014n(View view, Runnable runnable) {
        this.f57a = view;
        this.f58b = view.getViewTreeObserver();
        this.f59c = runnable;
    }

    public static void a(View view, Runnable runnable) {
        if (view == null) {
            throw new NullPointerException("view == null");
        }
        ViewTreeObserverOnPreDrawListenerC0014n viewTreeObserverOnPreDrawListenerC0014n = new ViewTreeObserverOnPreDrawListenerC0014n(view, runnable);
        view.getViewTreeObserver().addOnPreDrawListener(viewTreeObserverOnPreDrawListenerC0014n);
        view.addOnAttachStateChangeListener(viewTreeObserverOnPreDrawListenerC0014n);
    }

    @Override // android.view.ViewTreeObserver.OnPreDrawListener
    public final boolean onPreDraw() {
        boolean zIsAlive = this.f58b.isAlive();
        View view = this.f57a;
        if (zIsAlive) {
            this.f58b.removeOnPreDrawListener(this);
        } else {
            view.getViewTreeObserver().removeOnPreDrawListener(this);
        }
        view.removeOnAttachStateChangeListener(this);
        this.f59c.run();
        return true;
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewAttachedToWindow(View view) {
        this.f58b = view.getViewTreeObserver();
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewDetachedFromWindow(View view) {
        boolean zIsAlive = this.f58b.isAlive();
        View view2 = this.f57a;
        if (zIsAlive) {
            this.f58b.removeOnPreDrawListener(this);
        } else {
            view2.getViewTreeObserver().removeOnPreDrawListener(this);
        }
        view2.removeOnAttachStateChangeListener(this);
    }
}
