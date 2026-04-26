package J2;

import A.C0003c;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import e1.k;
import io.flutter.plugin.platform.i;

/* JADX INFO: loaded from: classes.dex */
public final class a implements ViewTreeObserver.OnGlobalFocusChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f804a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ View.OnFocusChangeListener f805b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ FrameLayout f806c;

    public a(View.OnFocusChangeListener onFocusChangeListener, b bVar) {
        this.f805b = onFocusChangeListener;
        this.f806c = bVar;
    }

    @Override // android.view.ViewTreeObserver.OnGlobalFocusChangeListener
    public final void onGlobalFocusChanged(View view, View view2) {
        switch (this.f804a) {
            case 0:
                b bVar = (b) this.f806c;
                this.f805b.onFocusChange(bVar, k.G(bVar, new C0003c(23)));
                break;
            default:
                i iVar = (i) this.f806c;
                this.f805b.onFocusChange(iVar, k.G(iVar, new C0003c(23)));
                break;
        }
    }

    public a(i iVar, View.OnFocusChangeListener onFocusChangeListener) {
        this.f806c = iVar;
        this.f805b = onFocusChangeListener;
    }
}
