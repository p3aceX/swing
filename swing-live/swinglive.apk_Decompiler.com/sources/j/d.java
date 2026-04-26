package j;

import android.view.View;
import android.view.ViewTreeObserver;

/* JADX INFO: loaded from: classes.dex */
public final class d implements View.OnAttachStateChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5043a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ l f5044b;

    public /* synthetic */ d(l lVar, int i4) {
        this.f5043a = i4;
        this.f5044b = lVar;
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewAttachedToWindow(View view) {
        int i4 = this.f5043a;
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewDetachedFromWindow(View view) {
        switch (this.f5043a) {
            case 0:
                g gVar = (g) this.f5044b;
                ViewTreeObserver viewTreeObserver = gVar.f5055D;
                if (viewTreeObserver != null) {
                    if (!viewTreeObserver.isAlive()) {
                        gVar.f5055D = view.getViewTreeObserver();
                    }
                    gVar.f5055D.removeGlobalOnLayoutListener(gVar.f5064o);
                }
                view.removeOnAttachStateChangeListener(this);
                break;
            default:
                s sVar = (s) this.f5044b;
                ViewTreeObserver viewTreeObserver2 = sVar.f5150u;
                if (viewTreeObserver2 != null) {
                    if (!viewTreeObserver2.isAlive()) {
                        sVar.f5150u = view.getViewTreeObserver();
                    }
                    sVar.f5150u.removeGlobalOnLayoutListener(sVar.f5144o);
                }
                view.removeOnAttachStateChangeListener(this);
                break;
        }
    }

    private final void a(View view) {
    }

    private final void b(View view) {
    }
}
