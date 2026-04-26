package b;

import android.window.BackEvent;
import android.window.OnBackAnimationCallback;

/* JADX INFO: renamed from: b.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0239p implements OnBackAnimationCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ I3.l f3251a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ I3.l f3252b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ I3.a f3253c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ I3.a f3254d;

    public C0239p(I3.l lVar, I3.l lVar2, I3.a aVar, I3.a aVar2) {
        this.f3251a = lVar;
        this.f3252b = lVar2;
        this.f3253c = aVar;
        this.f3254d = aVar2;
    }

    public final void onBackCancelled() {
        this.f3254d.a();
    }

    public final void onBackInvoked() {
        this.f3253c.a();
    }

    public final void onBackProgressed(BackEvent backEvent) {
        J3.i.e(backEvent, "backEvent");
        this.f3252b.invoke(new C0225b(backEvent));
    }

    public final void onBackStarted(BackEvent backEvent) {
        J3.i.e(backEvent, "backEvent");
        this.f3251a.invoke(new C0225b(backEvent));
    }
}
