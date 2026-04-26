package X;

import android.view.animation.Interpolator;
import android.widget.OverScroller;
import androidx.recyclerview.widget.RecyclerView;
import java.lang.reflect.Field;

/* JADX INFO: loaded from: classes.dex */
public final class D implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2278a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2279b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public OverScroller f2280c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Interpolator f2281d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f2282f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ RecyclerView f2283m;

    public D(RecyclerView recyclerView) {
        this.f2283m = recyclerView;
        o oVar = RecyclerView.f3132q0;
        this.f2281d = oVar;
        this.e = false;
        this.f2282f = false;
        this.f2280c = new OverScroller(recyclerView.getContext(), oVar);
    }

    public final void a() {
        if (this.e) {
            this.f2282f = true;
            return;
        }
        RecyclerView recyclerView = this.f2283m;
        recyclerView.removeCallbacks(this);
        Field field = A.C.f4a;
        recyclerView.postOnAnimation(this);
    }

    @Override // java.lang.Runnable
    public final void run() {
        int i4;
        RecyclerView recyclerView = this.f2283m;
        if (recyclerView.f3174o == null) {
            recyclerView.removeCallbacks(this);
            this.f2280c.abortAnimation();
            return;
        }
        this.f2282f = false;
        this.e = true;
        recyclerView.d();
        OverScroller overScroller = this.f2280c;
        recyclerView.f3174o.getClass();
        if (overScroller.computeScrollOffset()) {
            int currX = overScroller.getCurrX();
            int currY = overScroller.getCurrY();
            int i5 = currX - this.f2278a;
            int i6 = currY - this.f2279b;
            this.f2278a = currX;
            this.f2279b = currY;
            int i7 = i5;
            int[] iArr = recyclerView.f3168j0;
            if (recyclerView.f(i7, i6, iArr, null, 1)) {
                i7 -= iArr[0];
                i4 = i6 - iArr[1];
            } else {
                i4 = i6;
            }
            int i8 = i7;
            if (!recyclerView.f3175p.isEmpty()) {
                recyclerView.invalidate();
            }
            if (recyclerView.getOverScrollMode() != 2) {
                recyclerView.c(i8, i4);
            }
            recyclerView.g(null, 1);
            if (!recyclerView.awakenScrollBars()) {
                recyclerView.invalidate();
            }
            boolean z4 = (i8 == 0 && i4 == 0) || (i8 != 0 && recyclerView.f3174o.b() && i8 == 0) || (i4 != 0 && recyclerView.f3174o.c() && i4 == 0);
            if (overScroller.isFinished() || !(z4 || recyclerView.k())) {
                recyclerView.setScrollState(0);
                C0177h c0177h = recyclerView.f3160c0;
                c0177h.getClass();
                c0177h.f2349c = 0;
                recyclerView.s(1);
            } else {
                a();
                RunnableC0179j runnableC0179j = recyclerView.f3158b0;
                if (runnableC0179j != null) {
                    runnableC0179j.a(recyclerView, i8, i4);
                }
            }
        }
        this.e = false;
        if (this.f2282f) {
            a();
        }
    }
}
