package X;

import android.R;
import android.animation.ValueAnimator;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.view.MotionEvent;
import androidx.recyclerview.widget.RecyclerView;
import java.lang.reflect.Field;
import java.util.ArrayList;

/* JADX INFO: renamed from: X.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0176g {

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public static final int[] f2324x = {R.attr.state_pressed};

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public static final int[] f2325y = new int[0];

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f2326a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final StateListDrawable f2327b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Drawable f2328c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f2329d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final StateListDrawable f2330f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final Drawable f2331g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final int f2332h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final int f2333i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public float f2334j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public float f2335k;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final RecyclerView f2338n;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final ValueAnimator f2345u;
    public int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final F.b f2346w;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f2336l = 0;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f2337m = 0;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final boolean f2339o = false;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final boolean f2340p = false;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f2341q = 0;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f2342r = 0;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final int[] f2343s = new int[2];

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final int[] f2344t = new int[2];

    public C0176g(RecyclerView recyclerView, StateListDrawable stateListDrawable, Drawable drawable, StateListDrawable stateListDrawable2, Drawable drawable2, int i4, int i5, int i6) {
        ValueAnimator valueAnimatorOfFloat = ValueAnimator.ofFloat(0.0f, 1.0f);
        this.f2345u = valueAnimatorOfFloat;
        this.v = 0;
        F.b bVar = new F.b(this, 4);
        this.f2346w = bVar;
        C0173d c0173d = new C0173d();
        this.f2327b = stateListDrawable;
        this.f2328c = drawable;
        this.f2330f = stateListDrawable2;
        this.f2331g = drawable2;
        this.f2329d = Math.max(i4, stateListDrawable.getIntrinsicWidth());
        this.e = Math.max(i4, drawable.getIntrinsicWidth());
        this.f2332h = Math.max(i4, stateListDrawable2.getIntrinsicWidth());
        this.f2333i = Math.max(i4, drawable2.getIntrinsicWidth());
        this.f2326a = i6;
        stateListDrawable.setAlpha(255);
        drawable.setAlpha(255);
        valueAnimatorOfFloat.addListener(new C0174e(this));
        valueAnimatorOfFloat.addUpdateListener(new C0175f(this));
        RecyclerView recyclerView2 = this.f2338n;
        if (recyclerView2 == recyclerView) {
            return;
        }
        if (recyclerView2 != null) {
            t tVar = recyclerView2.f3174o;
            if (tVar != null) {
                tVar.a("Cannot remove item decoration during a scroll  or layout");
            }
            ArrayList arrayList = recyclerView2.f3175p;
            arrayList.remove(this);
            if (arrayList.isEmpty()) {
                recyclerView2.setWillNotDraw(recyclerView2.getOverScrollMode() == 2);
            }
            recyclerView2.m();
            recyclerView2.requestLayout();
            RecyclerView recyclerView3 = this.f2338n;
            recyclerView3.f3176q.remove(this);
            if (recyclerView3.f3177r == this) {
                recyclerView3.f3177r = null;
            }
            ArrayList arrayList2 = this.f2338n.f3163e0;
            if (arrayList2 != null) {
                arrayList2.remove(c0173d);
            }
            this.f2338n.removeCallbacks(bVar);
        }
        this.f2338n = recyclerView;
        t tVar2 = recyclerView.f3174o;
        if (tVar2 != null) {
            tVar2.a("Cannot add item decoration during a scroll  or layout");
        }
        ArrayList arrayList3 = recyclerView.f3175p;
        if (arrayList3.isEmpty()) {
            recyclerView.setWillNotDraw(false);
        }
        arrayList3.add(this);
        recyclerView.m();
        recyclerView.requestLayout();
        this.f2338n.f3176q.add(this);
        RecyclerView recyclerView4 = this.f2338n;
        if (recyclerView4.f3163e0 == null) {
            recyclerView4.f3163e0 = new ArrayList();
        }
        recyclerView4.f3163e0.add(c0173d);
    }

    public static int d(float f4, float f5, int[] iArr, int i4, int i5, int i6) {
        int i7 = iArr[1] - iArr[0];
        if (i7 != 0) {
            int i8 = i4 - i6;
            int i9 = (int) (((f5 - f4) / i7) * i8);
            int i10 = i5 + i9;
            if (i10 < i8 && i10 >= 0) {
                return i9;
            }
        }
        return 0;
    }

    public final boolean a(float f4, float f5) {
        return f5 >= ((float) (this.f2337m - this.f2332h)) && f4 >= ((float) (0 - (0 / 2))) && f4 <= ((float) ((0 / 2) + 0));
    }

    public final boolean b(float f4, float f5) {
        RecyclerView recyclerView = this.f2338n;
        Field field = A.C.f4a;
        boolean z4 = recyclerView.getLayoutDirection() == 1;
        int i4 = this.f2329d;
        if (!z4 ? f4 >= this.f2336l - i4 : f4 <= i4 / 2) {
            int i5 = 0 / 2;
            if (f5 >= 0 - i5 && f5 <= i5 + 0) {
                return true;
            }
        }
        return false;
    }

    public final boolean c(MotionEvent motionEvent) {
        int i4 = this.f2341q;
        if (i4 != 1) {
            return i4 == 2;
        }
        boolean zB = b(motionEvent.getX(), motionEvent.getY());
        boolean zA = a(motionEvent.getX(), motionEvent.getY());
        if (motionEvent.getAction() != 0) {
            return false;
        }
        if (!zB && !zA) {
            return false;
        }
        if (zA) {
            this.f2342r = 1;
            this.f2335k = (int) motionEvent.getX();
        } else if (zB) {
            this.f2342r = 2;
            this.f2334j = (int) motionEvent.getY();
        }
        e(2);
        return true;
    }

    public final void e(int i4) {
        F.b bVar = this.f2346w;
        StateListDrawable stateListDrawable = this.f2327b;
        if (i4 == 2 && this.f2341q != 2) {
            stateListDrawable.setState(f2324x);
            this.f2338n.removeCallbacks(bVar);
        }
        if (i4 == 0) {
            this.f2338n.invalidate();
        } else {
            f();
        }
        if (this.f2341q == 2 && i4 != 2) {
            stateListDrawable.setState(f2325y);
            this.f2338n.removeCallbacks(bVar);
            this.f2338n.postDelayed(bVar, 1200);
        } else if (i4 == 1) {
            this.f2338n.removeCallbacks(bVar);
            this.f2338n.postDelayed(bVar, 1500);
        }
        this.f2341q = i4;
    }

    public final void f() {
        int i4 = this.v;
        ValueAnimator valueAnimator = this.f2345u;
        if (i4 != 0) {
            if (i4 != 3) {
                return;
            } else {
                valueAnimator.cancel();
            }
        }
        this.v = 1;
        valueAnimator.setFloatValues(((Float) valueAnimator.getAnimatedValue()).floatValue(), 1.0f);
        valueAnimator.setDuration(500L);
        valueAnimator.setStartDelay(0L);
        valueAnimator.start();
    }
}
