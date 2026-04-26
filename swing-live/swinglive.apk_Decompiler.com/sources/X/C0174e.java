package X;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;

/* JADX INFO: renamed from: X.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0174e extends AnimatorListenerAdapter {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f2321a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0176g f2322b;

    public C0174e(C0176g c0176g) {
        this.f2322b = c0176g;
    }

    @Override // android.animation.AnimatorListenerAdapter, android.animation.Animator.AnimatorListener
    public final void onAnimationCancel(Animator animator) {
        this.f2321a = true;
    }

    @Override // android.animation.AnimatorListenerAdapter, android.animation.Animator.AnimatorListener
    public final void onAnimationEnd(Animator animator) {
        if (this.f2321a) {
            this.f2321a = false;
            return;
        }
        C0176g c0176g = this.f2322b;
        if (((Float) c0176g.f2345u.getAnimatedValue()).floatValue() == 0.0f) {
            c0176g.v = 0;
            c0176g.e(0);
        } else {
            c0176g.v = 2;
            c0176g.f2338n.invalidate();
        }
    }
}
