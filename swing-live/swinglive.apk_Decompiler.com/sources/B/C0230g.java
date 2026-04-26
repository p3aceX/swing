package b;

import O.AbstractActivityC0114z;
import android.view.View;
import android.view.Window;
import androidx.lifecycle.EnumC0221g;
import androidx.lifecycle.H;

/* JADX INFO: renamed from: b.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0230g implements androidx.lifecycle.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3222a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ AbstractActivityC0114z f3223b;

    public /* synthetic */ C0230g(AbstractActivityC0114z abstractActivityC0114z, int i4) {
        this.f3222a = i4;
        this.f3223b = abstractActivityC0114z;
    }

    @Override // androidx.lifecycle.l
    public final void a(androidx.lifecycle.n nVar, EnumC0221g enumC0221g) {
        switch (this.f3222a) {
            case 0:
                if (enumC0221g == EnumC0221g.ON_STOP) {
                    Window window = this.f3223b.getWindow();
                    View viewPeekDecorView = window != null ? window.peekDecorView() : null;
                    if (viewPeekDecorView != null) {
                        viewPeekDecorView.cancelPendingInputEvents();
                    }
                }
                break;
            case 1:
                if (enumC0221g == EnumC0221g.ON_DESTROY) {
                    this.f3223b.f3229b.f3295b = null;
                    if (!this.f3223b.isChangingConfigurations()) {
                        this.f3223b.g().a();
                    }
                    ExecutorC0233j executorC0233j = this.f3223b.f3234n;
                    AbstractActivityC0114z abstractActivityC0114z = executorC0233j.f3228d;
                    abstractActivityC0114z.getWindow().getDecorView().removeCallbacks(executorC0233j);
                    abstractActivityC0114z.getWindow().getDecorView().getViewTreeObserver().removeOnDrawListener(executorC0233j);
                }
                break;
            default:
                AbstractActivityC0114z abstractActivityC0114z2 = this.f3223b;
                if (abstractActivityC0114z2.f3232f == null) {
                    C0232i c0232i = (C0232i) abstractActivityC0114z2.getLastNonConfigurationInstance();
                    if (c0232i != null) {
                        abstractActivityC0114z2.f3232f = c0232i.f3224a;
                    }
                    if (abstractActivityC0114z2.f3232f == null) {
                        abstractActivityC0114z2.f3232f = new H();
                    }
                }
                abstractActivityC0114z2.f3231d.b(this);
                break;
        }
    }
}
