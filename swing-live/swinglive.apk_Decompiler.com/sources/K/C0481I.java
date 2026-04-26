package k;

import android.os.Handler;
import android.widget.AbsListView;

/* JADX INFO: renamed from: k.I, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0481I implements AbsListView.OnScrollListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ AbstractC0483K f5287a;

    public C0481I(AbstractC0483K abstractC0483K) {
        this.f5287a = abstractC0483K;
    }

    @Override // android.widget.AbsListView.OnScrollListener
    public final void onScrollStateChanged(AbsListView absListView, int i4) {
        if (i4 == 1) {
            AbstractC0483K abstractC0483K = this.f5287a;
            if (abstractC0483K.f5292B.getInputMethodMode() == 2 || abstractC0483K.f5292B.getContentView() == null) {
                return;
            }
            Handler handler = abstractC0483K.f5308x;
            RunnableC0480H runnableC0480H = abstractC0483K.f5305t;
            handler.removeCallbacks(runnableC0480H);
            runnableC0480H.run();
        }
    }

    @Override // android.widget.AbsListView.OnScrollListener
    public final void onScroll(AbsListView absListView, int i4, int i5, int i6) {
    }
}
