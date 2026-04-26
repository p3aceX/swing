package O;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.view.ViewGroup;

/* JADX INFO: renamed from: O.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0097h extends AnimatorListenerAdapter {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ ViewGroup f1346a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ boolean f1347b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0098i f1348c;

    public C0097h(ViewGroup viewGroup, boolean z4, Z z5, C0098i c0098i) {
        this.f1346a = viewGroup;
        this.f1347b = z4;
        this.f1348c = c0098i;
    }

    @Override // android.animation.AnimatorListenerAdapter, android.animation.Animator.AnimatorListener
    public final void onAnimationEnd(Animator animator) {
        J3.i.e(animator, "anim");
        this.f1346a.endViewTransition(null);
        if (this.f1347b) {
            throw null;
        }
        C0096g c0096g = this.f1348c.f1349b;
        throw null;
    }
}
