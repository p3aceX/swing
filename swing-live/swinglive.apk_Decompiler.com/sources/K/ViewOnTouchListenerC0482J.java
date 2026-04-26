package k;

import android.view.MotionEvent;
import android.view.View;

/* JADX INFO: renamed from: k.J, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ViewOnTouchListenerC0482J implements View.OnTouchListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ AbstractC0483K f5288a;

    public ViewOnTouchListenerC0482J(AbstractC0483K abstractC0483K) {
        this.f5288a = abstractC0483K;
    }

    @Override // android.view.View.OnTouchListener
    public final boolean onTouch(View view, MotionEvent motionEvent) {
        r rVar;
        int action = motionEvent.getAction();
        int x4 = (int) motionEvent.getX();
        int y4 = (int) motionEvent.getY();
        AbstractC0483K abstractC0483K = this.f5288a;
        if (action == 0 && (rVar = abstractC0483K.f5292B) != null && rVar.isShowing() && x4 >= 0 && x4 < abstractC0483K.f5292B.getWidth() && y4 >= 0 && y4 < abstractC0483K.f5292B.getHeight()) {
            abstractC0483K.f5308x.postDelayed(abstractC0483K.f5305t, 250L);
            return false;
        }
        if (action != 1) {
            return false;
        }
        abstractC0483K.f5308x.removeCallbacks(abstractC0483K.f5305t);
        return false;
    }
}
