package O;

import A.ViewTreeObserverOnPreDrawListenerC0014n;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.Transformation;

/* JADX INFO: loaded from: classes.dex */
public final class A extends AnimationSet implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ViewGroup f1198a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f1199b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f1200c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f1201d;

    public A(Animation animation, ViewGroup viewGroup) {
        super(false);
        this.f1201d = true;
        this.f1198a = viewGroup;
        addAnimation(animation);
        viewGroup.post(this);
    }

    @Override // android.view.animation.AnimationSet, android.view.animation.Animation
    public final boolean getTransformation(long j4, Transformation transformation) {
        this.f1201d = true;
        if (this.f1199b) {
            return !this.f1200c;
        }
        if (!super.getTransformation(j4, transformation)) {
            this.f1199b = true;
            ViewTreeObserverOnPreDrawListenerC0014n.a(this.f1198a, this);
        }
        return true;
    }

    @Override // java.lang.Runnable
    public final void run() {
        boolean z4 = this.f1199b;
        ViewGroup viewGroup = this.f1198a;
        if (z4 || !this.f1201d) {
            viewGroup.endViewTransition(null);
            this.f1200c = true;
        } else {
            this.f1201d = false;
            viewGroup.post(this);
        }
    }

    @Override // android.view.animation.Animation
    public final boolean getTransformation(long j4, Transformation transformation, float f4) {
        this.f1201d = true;
        if (this.f1199b) {
            return !this.f1200c;
        }
        if (!super.getTransformation(j4, transformation, f4)) {
            this.f1199b = true;
            ViewTreeObserverOnPreDrawListenerC0014n.a(this.f1198a, this);
        }
        return true;
    }
}
