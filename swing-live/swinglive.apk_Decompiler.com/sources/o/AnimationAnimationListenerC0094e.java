package O;

import android.util.Log;
import android.view.ViewGroup;
import android.view.animation.Animation;

/* JADX INFO: renamed from: O.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class AnimationAnimationListenerC0094e implements Animation.AnimationListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ ViewGroup f1340a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0095f f1341b;

    public AnimationAnimationListenerC0094e(Z z4, ViewGroup viewGroup, C0095f c0095f) {
        this.f1340a = viewGroup;
        this.f1341b = c0095f;
    }

    @Override // android.view.animation.Animation.AnimationListener
    public final void onAnimationEnd(Animation animation) {
        J3.i.e(animation, "animation");
        C0095f c0095f = this.f1341b;
        ViewGroup viewGroup = this.f1340a;
        viewGroup.post(new RunnableC0093d(0, viewGroup, c0095f));
        if (N.J(2)) {
            Log.v("FragmentManager", "Animation from operation " + ((Object) null) + " has ended.");
        }
    }

    @Override // android.view.animation.Animation.AnimationListener
    public final void onAnimationRepeat(Animation animation) {
        J3.i.e(animation, "animation");
    }

    @Override // android.view.animation.Animation.AnimationListener
    public final void onAnimationStart(Animation animation) {
        J3.i.e(animation, "animation");
        if (N.J(2)) {
            Log.v("FragmentManager", "Animation from operation " + ((Object) null) + " has reached onAnimationStart.");
        }
    }
}
