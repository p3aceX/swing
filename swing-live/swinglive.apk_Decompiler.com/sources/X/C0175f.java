package X;

import android.animation.ValueAnimator;

/* JADX INFO: renamed from: X.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0175f implements ValueAnimator.AnimatorUpdateListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ C0176g f2323a;

    public C0175f(C0176g c0176g) {
        this.f2323a = c0176g;
    }

    @Override // android.animation.ValueAnimator.AnimatorUpdateListener
    public final void onAnimationUpdate(ValueAnimator valueAnimator) {
        int iFloatValue = (int) (((Float) valueAnimator.getAnimatedValue()).floatValue() * 255.0f);
        C0176g c0176g = this.f2323a;
        c0176g.f2327b.setAlpha(iFloatValue);
        c0176g.f2328c.setAlpha(iFloatValue);
        c0176g.f2338n.invalidate();
    }
}
