package k;

import java.lang.reflect.Field;

/* JADX INFO: renamed from: k.H, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class RunnableC0480H implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5285a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ AbstractC0483K f5286b;

    public /* synthetic */ RunnableC0480H(AbstractC0483K abstractC0483K, int i4) {
        this.f5285a = i4;
        this.f5286b = abstractC0483K;
    }

    @Override // java.lang.Runnable
    public final void run() {
        AbstractC0483K abstractC0483K = this.f5286b;
        switch (this.f5285a) {
            case 0:
                M m4 = abstractC0483K.f5295c;
                if (m4 != null) {
                    m4.setListSelectionHidden(true);
                    m4.requestLayout();
                }
                break;
            default:
                M m5 = abstractC0483K.f5295c;
                if (m5 != null) {
                    Field field = A.C.f4a;
                    if (m5.isAttachedToWindow() && abstractC0483K.f5295c.getCount() > abstractC0483K.f5295c.getChildCount() && abstractC0483K.f5295c.getChildCount() <= Integer.MAX_VALUE) {
                        abstractC0483K.f5292B.setInputMethodMode(2);
                        abstractC0483K.b();
                        break;
                    }
                }
                break;
        }
    }
}
