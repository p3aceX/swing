package F;

import android.content.res.Resources;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AnimationUtils;
import android.widget.ListView;
import k.AbstractC0474B;

/* JADX INFO: loaded from: classes.dex */
public final class g implements View.OnTouchListener {

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public static final int f392x = ViewConfiguration.getTapTimeout();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final a f393a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AccelerateInterpolator f394b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ListView f395c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public b f396d;
    public final float[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final float[] f397f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final int f398m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final int f399n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final float[] f400o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final float[] f401p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final float[] f402q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public boolean f403r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f404s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f405t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f406u;
    public boolean v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final AbstractC0474B f407w;

    public g(AbstractC0474B abstractC0474B) {
        a aVar = new a();
        aVar.e = Long.MIN_VALUE;
        aVar.f386g = -1L;
        aVar.f385f = 0L;
        this.f393a = aVar;
        this.f394b = new AccelerateInterpolator();
        float[] fArr = {0.0f, 0.0f};
        this.e = fArr;
        float[] fArr2 = {Float.MAX_VALUE, Float.MAX_VALUE};
        this.f397f = fArr2;
        float[] fArr3 = {0.0f, 0.0f};
        this.f400o = fArr3;
        float[] fArr4 = {0.0f, 0.0f};
        this.f401p = fArr4;
        float[] fArr5 = {Float.MAX_VALUE, Float.MAX_VALUE};
        this.f402q = fArr5;
        this.f395c = abstractC0474B;
        float f4 = Resources.getSystem().getDisplayMetrics().density;
        float f5 = ((int) ((1575.0f * f4) + 0.5f)) / 1000.0f;
        fArr5[0] = f5;
        fArr5[1] = f5;
        float f6 = ((int) ((f4 * 315.0f) + 0.5f)) / 1000.0f;
        fArr4[0] = f6;
        fArr4[1] = f6;
        this.f398m = 1;
        fArr2[0] = Float.MAX_VALUE;
        fArr2[1] = Float.MAX_VALUE;
        fArr[0] = 0.2f;
        fArr[1] = 0.2f;
        fArr3[0] = 0.001f;
        fArr3[1] = 0.001f;
        this.f399n = f392x;
        aVar.f381a = 500;
        aVar.f382b = 500;
        this.f407w = abstractC0474B;
    }

    public static float b(float f4, float f5, float f6) {
        return f4 > f6 ? f6 : f4 < f5 ? f5 : f4;
    }

    /* JADX WARN: Removed duplicated region for block: B:12:0x003b A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:13:0x003c  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final float a(int r4, float r5, float r6, float r7) {
        /*
            r3 = this;
            float[] r0 = r3.e
            r0 = r0[r4]
            float[] r1 = r3.f397f
            r1 = r1[r4]
            float r0 = r0 * r6
            r2 = 0
            float r0 = b(r0, r2, r1)
            float r1 = r3.c(r5, r0)
            float r6 = r6 - r5
            float r5 = r3.c(r6, r0)
            float r5 = r5 - r1
            int r6 = (r5 > r2 ? 1 : (r5 == r2 ? 0 : -1))
            android.view.animation.AccelerateInterpolator r0 = r3.f394b
            if (r6 >= 0) goto L25
            float r5 = -r5
            float r5 = r0.getInterpolation(r5)
            float r5 = -r5
            goto L2d
        L25:
            int r6 = (r5 > r2 ? 1 : (r5 == r2 ? 0 : -1))
            if (r6 <= 0) goto L36
            float r5 = r0.getInterpolation(r5)
        L2d:
            r6 = -1082130432(0xffffffffbf800000, float:-1.0)
            r0 = 1065353216(0x3f800000, float:1.0)
            float r5 = b(r5, r6, r0)
            goto L37
        L36:
            r5 = r2
        L37:
            int r6 = (r5 > r2 ? 1 : (r5 == r2 ? 0 : -1))
            if (r6 != 0) goto L3c
            return r2
        L3c:
            float[] r0 = r3.f400o
            r0 = r0[r4]
            float[] r1 = r3.f401p
            r1 = r1[r4]
            float[] r2 = r3.f402q
            r4 = r2[r4]
            float r0 = r0 * r7
            if (r6 <= 0) goto L51
            float r5 = r5 * r0
            float r4 = b(r5, r1, r4)
            return r4
        L51:
            float r5 = -r5
            float r5 = r5 * r0
            float r4 = b(r5, r1, r4)
            float r4 = -r4
            return r4
        */
        throw new UnsupportedOperationException("Method not decompiled: F.g.a(int, float, float, float):float");
    }

    public final float c(float f4, float f5) {
        if (f5 != 0.0f) {
            int i4 = this.f398m;
            if (i4 == 0 || i4 == 1) {
                if (f4 < f5) {
                    if (f4 >= 0.0f) {
                        return 1.0f - (f4 / f5);
                    }
                    if (this.f406u && i4 == 1) {
                        return 1.0f;
                    }
                }
            } else if (i4 == 2 && f4 < 0.0f) {
                return f4 / (-f5);
            }
        }
        return 0.0f;
    }

    public final void d() {
        int i4 = 0;
        if (this.f404s) {
            this.f406u = false;
            return;
        }
        a aVar = this.f393a;
        long jCurrentAnimationTimeMillis = AnimationUtils.currentAnimationTimeMillis();
        int i5 = (int) (jCurrentAnimationTimeMillis - aVar.e);
        int i6 = aVar.f382b;
        if (i5 > i6) {
            i4 = i6;
        } else if (i5 >= 0) {
            i4 = i5;
        }
        aVar.f388i = i4;
        aVar.f387h = aVar.a(jCurrentAnimationTimeMillis);
        aVar.f386g = jCurrentAnimationTimeMillis;
    }

    public final boolean e() {
        AbstractC0474B abstractC0474B;
        int count;
        a aVar = this.f393a;
        float f4 = aVar.f384d;
        int iAbs = (int) (f4 / Math.abs(f4));
        Math.abs(aVar.f383c);
        if (iAbs != 0 && (count = (abstractC0474B = this.f407w).getCount()) != 0) {
            int childCount = abstractC0474B.getChildCount();
            int firstVisiblePosition = abstractC0474B.getFirstVisiblePosition();
            int i4 = firstVisiblePosition + childCount;
            if (iAbs <= 0 ? !(iAbs >= 0 || (firstVisiblePosition <= 0 && abstractC0474B.getChildAt(0).getTop() >= 0)) : !(i4 >= count && abstractC0474B.getChildAt(childCount - 1).getBottom() <= abstractC0474B.getHeight())) {
                return true;
            }
        }
        return false;
    }

    /* JADX WARN: Code restructure failed: missing block: B:11:0x0014, code lost:
    
        if (r0 != 3) goto L30;
     */
    @Override // android.view.View.OnTouchListener
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onTouch(android.view.View r8, android.view.MotionEvent r9) {
        /*
            r7 = this;
            boolean r0 = r7.v
            r1 = 0
            if (r0 != 0) goto L7
            goto L7c
        L7:
            int r0 = r9.getActionMasked()
            r2 = 1
            if (r0 == 0) goto L1b
            if (r0 == r2) goto L17
            r3 = 2
            if (r0 == r3) goto L1f
            r8 = 3
            if (r0 == r8) goto L17
            goto L7c
        L17:
            r7.d()
            return r1
        L1b:
            r7.f405t = r2
            r7.f403r = r1
        L1f:
            float r0 = r9.getX()
            int r3 = r8.getWidth()
            float r3 = (float) r3
            android.widget.ListView r4 = r7.f395c
            int r5 = r4.getWidth()
            float r5 = (float) r5
            float r0 = r7.a(r1, r0, r3, r5)
            float r9 = r9.getY()
            int r8 = r8.getHeight()
            float r8 = (float) r8
            int r3 = r4.getHeight()
            float r3 = (float) r3
            float r8 = r7.a(r2, r9, r8, r3)
            F.a r9 = r7.f393a
            r9.f383c = r0
            r9.f384d = r8
            boolean r8 = r7.f406u
            if (r8 != 0) goto L7c
            boolean r8 = r7.e()
            if (r8 == 0) goto L7c
            F.b r8 = r7.f396d
            if (r8 != 0) goto L60
            F.b r8 = new F.b
            r8.<init>(r7, r1)
            r7.f396d = r8
        L60:
            r7.f406u = r2
            r7.f404s = r2
            boolean r8 = r7.f403r
            if (r8 != 0) goto L75
            int r8 = r7.f399n
            if (r8 <= 0) goto L75
            F.b r9 = r7.f396d
            long r5 = (long) r8
            java.lang.reflect.Field r8 = A.C.f4a
            r4.postOnAnimationDelayed(r9, r5)
            goto L7a
        L75:
            F.b r8 = r7.f396d
            r8.run()
        L7a:
            r7.f403r = r2
        L7c:
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: F.g.onTouch(android.view.View, android.view.MotionEvent):boolean");
    }
}
