package k;

import android.os.SystemClock;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;

/* JADX INFO: renamed from: k.D, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class RunnableC0476D implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5265a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ j.a f5266b;

    public /* synthetic */ RunnableC0476D(j.a aVar, int i4) {
        this.f5265a = i4;
        this.f5266b = aVar;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f5265a) {
            case 0:
                ViewParent parent = this.f5266b.f5034d.getParent();
                if (parent != null) {
                    parent.requestDisallowInterceptTouchEvent(true);
                }
                break;
            default:
                j.a aVar = this.f5266b;
                aVar.a();
                View view = aVar.f5034d;
                if (view.isEnabled() && !view.isLongClickable() && aVar.c()) {
                    view.getParent().requestDisallowInterceptTouchEvent(true);
                    long jUptimeMillis = SystemClock.uptimeMillis();
                    MotionEvent motionEventObtain = MotionEvent.obtain(jUptimeMillis, jUptimeMillis, 3, 0.0f, 0.0f, 0);
                    view.onTouchEvent(motionEventObtain);
                    motionEventObtain.recycle();
                    aVar.f5036m = true;
                    break;
                }
                break;
        }
    }
}
