package k;

import androidx.appcompat.widget.ActionBarOverlayLayout;

/* JADX INFO: renamed from: k.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class RunnableC0486c implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5339a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ ActionBarOverlayLayout f5340b;

    public /* synthetic */ RunnableC0486c(ActionBarOverlayLayout actionBarOverlayLayout, int i4) {
        this.f5339a = i4;
        this.f5340b = actionBarOverlayLayout;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f5339a) {
            case 0:
                ActionBarOverlayLayout actionBarOverlayLayout = this.f5340b;
                actionBarOverlayLayout.h();
                actionBarOverlayLayout.f2713z = actionBarOverlayLayout.f2698c.animate().translationY(0.0f).setListener(actionBarOverlayLayout.f2692A);
                break;
            default:
                ActionBarOverlayLayout actionBarOverlayLayout2 = this.f5340b;
                actionBarOverlayLayout2.h();
                actionBarOverlayLayout2.f2713z = actionBarOverlayLayout2.f2698c.animate().translationY(-actionBarOverlayLayout2.f2698c.getHeight()).setListener(actionBarOverlayLayout2.f2692A);
                break;
        }
    }
}
