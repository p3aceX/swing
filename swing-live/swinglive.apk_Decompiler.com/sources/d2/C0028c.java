package D2;

import android.util.Log;
import android.window.BackEvent;
import android.window.OnBackAnimationCallback;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: renamed from: D2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0028c implements OnBackAnimationCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ AbstractActivityC0029d f184a;

    public C0028c(AbstractActivityC0029d abstractActivityC0029d) {
        this.f184a = abstractActivityC0029d;
    }

    public final void onBackCancelled() {
        AbstractActivityC0029d abstractActivityC0029d = this.f184a;
        if (abstractActivityC0029d.m("cancelBackGesture")) {
            C0032g c0032g = abstractActivityC0029d.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                ((C0747k) cVar.f349j.f6969b).O("cancelBackGesture", null, null);
            } else {
                Log.w("FlutterActivityAndFragmentDelegate", "Invoked cancelBackGesture() before FlutterFragment was attached to an Activity.");
            }
        }
    }

    public final void onBackInvoked() {
        AbstractActivityC0029d abstractActivityC0029d = this.f184a;
        if (abstractActivityC0029d.m("commitBackGesture")) {
            C0032g c0032g = abstractActivityC0029d.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                ((C0747k) cVar.f349j.f6969b).O("commitBackGesture", null, null);
            } else {
                Log.w("FlutterActivityAndFragmentDelegate", "Invoked commitBackGesture() before FlutterFragment was attached to an Activity.");
            }
        }
    }

    public final void onBackProgressed(BackEvent backEvent) {
        AbstractActivityC0029d abstractActivityC0029d = this.f184a;
        if (abstractActivityC0029d.m("updateBackGestureProgress")) {
            C0032g c0032g = abstractActivityC0029d.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "Invoked updateBackGestureProgress() before FlutterFragment was attached to an Activity.");
                return;
            }
            C0779j c0779j = cVar.f349j;
            c0779j.getClass();
            ((C0747k) c0779j.f6969b).O("updateBackGestureProgress", C0779j.o(backEvent), null);
        }
    }

    public final void onBackStarted(BackEvent backEvent) {
        AbstractActivityC0029d abstractActivityC0029d = this.f184a;
        if (abstractActivityC0029d.m("startBackGesture")) {
            C0032g c0032g = abstractActivityC0029d.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "Invoked startBackGesture() before FlutterFragment was attached to an Activity.");
                return;
            }
            C0779j c0779j = cVar.f349j;
            c0779j.getClass();
            ((C0747k) c0779j.f6969b).O("startBackGesture", C0779j.o(backEvent), null);
        }
    }
}
