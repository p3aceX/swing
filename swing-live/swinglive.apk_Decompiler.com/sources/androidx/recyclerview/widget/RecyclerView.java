package androidx.recyclerview.widget;

import A.AbstractC0019t;
import A.AbstractC0021v;
import A.C;
import A.C0009i;
import A.G;
import D2.H;
import F.b;
import J1.c;
import J3.i;
import W.a;
import X.A;
import X.B;
import X.C0171b;
import X.C0172c;
import X.C0176g;
import X.C0177h;
import X.D;
import X.F;
import X.M;
import X.N;
import X.RunnableC0179j;
import X.o;
import X.p;
import X.q;
import X.r;
import X.s;
import X.t;
import X.u;
import X.v;
import X.w;
import X.x;
import X.y;
import X.z;
import android.R;
import android.content.Context;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Build;
import android.os.Parcelable;
import android.os.SystemClock;
import android.os.Trace;
import android.util.AttributeSet;
import android.util.Log;
import android.util.SparseArray;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.widget.EdgeEffect;
import android.widget.OverScroller;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import p1.d;
import u1.C0690c;
import w.f;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class RecyclerView extends ViewGroup {
    public static final int[] n0 = {R.attr.nestedScrollingEnabled};

    /* JADX INFO: renamed from: o0, reason: collision with root package name */
    public static final int[] f3130o0 = {R.attr.clipToPadding};

    /* JADX INFO: renamed from: p0, reason: collision with root package name */
    public static final Class[] f3131p0;

    /* JADX INFO: renamed from: q0, reason: collision with root package name */
    public static final o f3132q0;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public boolean f3133A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public boolean f3134B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public int f3135C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public final int f3136D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public r f3137E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public EdgeEffect f3138F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public EdgeEffect f3139G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public EdgeEffect f3140H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public EdgeEffect f3141I;
    public s J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public int f3142K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public int f3143L;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public VelocityTracker f3144M;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public int f3145N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public int f3146O;

    /* JADX INFO: renamed from: P, reason: collision with root package name */
    public int f3147P;

    /* JADX INFO: renamed from: Q, reason: collision with root package name */
    public int f3148Q;

    /* JADX INFO: renamed from: R, reason: collision with root package name */
    public int f3149R;

    /* JADX INFO: renamed from: S, reason: collision with root package name */
    public final int f3150S;

    /* JADX INFO: renamed from: T, reason: collision with root package name */
    public final int f3151T;

    /* JADX INFO: renamed from: U, reason: collision with root package name */
    public final float f3152U;

    /* JADX INFO: renamed from: V, reason: collision with root package name */
    public final float f3153V;

    /* JADX INFO: renamed from: W, reason: collision with root package name */
    public boolean f3154W;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final c f3155a;

    /* JADX INFO: renamed from: a0, reason: collision with root package name */
    public final D f3156a0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public A f3157b;

    /* JADX INFO: renamed from: b0, reason: collision with root package name */
    public RunnableC0179j f3158b0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0747k f3159c;

    /* JADX INFO: renamed from: c0, reason: collision with root package name */
    public final C0177h f3160c0;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0747k f3161d;

    /* JADX INFO: renamed from: d0, reason: collision with root package name */
    public final B f3162d0;
    public final N e;

    /* JADX INFO: renamed from: e0, reason: collision with root package name */
    public ArrayList f3163e0;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f3164f;

    /* JADX INFO: renamed from: f0, reason: collision with root package name */
    public final d f3165f0;

    /* JADX INFO: renamed from: g0, reason: collision with root package name */
    public F f3166g0;
    public C0009i h0;

    /* JADX INFO: renamed from: i0, reason: collision with root package name */
    public final int[] f3167i0;

    /* JADX INFO: renamed from: j0, reason: collision with root package name */
    public final int[] f3168j0;

    /* JADX INFO: renamed from: k0, reason: collision with root package name */
    public final int[] f3169k0;

    /* JADX INFO: renamed from: l0, reason: collision with root package name */
    public final ArrayList f3170l0;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Rect f3171m;

    /* JADX INFO: renamed from: m0, reason: collision with root package name */
    public final b f3172m0;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final Rect f3173n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public t f3174o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final ArrayList f3175p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final ArrayList f3176q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public C0176g f3177r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f3178s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f3179t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f3180u;
    public int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f3181w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public boolean f3182x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f3183y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public final AccessibilityManager f3184z;

    static {
        Class cls = Integer.TYPE;
        f3131p0 = new Class[]{Context.class, AttributeSet.class, cls, cls};
        f3132q0 = new o();
    }

    public RecyclerView(Context context, AttributeSet attributeSet) {
        float fA;
        int i4;
        char c5;
        Constructor constructor;
        Object[] objArr;
        super(context, attributeSet, 0);
        this.f3155a = new c(this);
        this.e = new N();
        this.f3171m = new Rect();
        this.f3173n = new Rect();
        new RectF();
        this.f3175p = new ArrayList();
        this.f3176q = new ArrayList();
        this.v = 0;
        this.f3133A = false;
        this.f3134B = false;
        this.f3135C = 0;
        this.f3136D = 0;
        this.f3137E = new r();
        C0172c c0172c = new C0172c();
        c0172c.f2367a = null;
        c0172c.f2368b = new ArrayList();
        c0172c.f2369c = 250L;
        c0172c.f2370d = 250L;
        c0172c.e = new ArrayList();
        c0172c.f2311f = new ArrayList();
        c0172c.f2312g = new ArrayList();
        c0172c.f2313h = new ArrayList();
        c0172c.f2314i = new ArrayList();
        c0172c.f2315j = new ArrayList();
        c0172c.f2316k = new ArrayList();
        c0172c.f2317l = new ArrayList();
        c0172c.f2318m = new ArrayList();
        c0172c.f2319n = new ArrayList();
        c0172c.f2320o = new ArrayList();
        this.J = c0172c;
        this.f3142K = 0;
        this.f3143L = -1;
        this.f3152U = Float.MIN_VALUE;
        this.f3153V = Float.MIN_VALUE;
        boolean z4 = true;
        this.f3154W = true;
        this.f3156a0 = new D(this);
        this.f3160c0 = new C0177h();
        B b5 = new B();
        b5.f2274a = 0;
        b5.f2275b = false;
        b5.f2276c = false;
        b5.f2277d = false;
        b5.e = false;
        this.f3162d0 = b5;
        d dVar = new d(28);
        this.f3165f0 = dVar;
        this.f3167i0 = new int[2];
        this.f3168j0 = new int[2];
        this.f3169k0 = new int[2];
        this.f3170l0 = new ArrayList();
        this.f3172m0 = new b(this, 5);
        if (attributeSet != null) {
            TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, f3130o0, 0, 0);
            this.f3164f = typedArrayObtainStyledAttributes.getBoolean(0, true);
            typedArrayObtainStyledAttributes.recycle();
        } else {
            this.f3164f = true;
        }
        setScrollContainer(true);
        setFocusableInTouchMode(true);
        ViewConfiguration viewConfiguration = ViewConfiguration.get(context);
        this.f3149R = viewConfiguration.getScaledTouchSlop();
        int i5 = Build.VERSION.SDK_INT;
        if (i5 >= 26) {
            Method method = G.f6a;
            fA = A.D.a(viewConfiguration);
        } else {
            fA = G.a(viewConfiguration, context);
        }
        this.f3152U = fA;
        this.f3153V = i5 >= 26 ? A.D.b(viewConfiguration) : G.a(viewConfiguration, context);
        this.f3150S = viewConfiguration.getScaledMinimumFlingVelocity();
        this.f3151T = viewConfiguration.getScaledMaximumFlingVelocity();
        setWillNotDraw(getOverScrollMode() == 2);
        this.J.f2367a = dVar;
        this.f3159c = new C0747k(new d(this, 27));
        this.f3161d = new C0747k(new C0690c(this, 21));
        Field field = C.f4a;
        if ((i5 >= 26 ? AbstractC0021v.c(this) : 0) == 0 && i5 >= 26) {
            AbstractC0021v.m(this, 8);
        }
        if (getImportantForAccessibility() == 0) {
            setImportantForAccessibility(1);
        }
        this.f3184z = (AccessibilityManager) getContext().getSystemService("accessibility");
        setAccessibilityDelegateCompat(new F(this));
        if (attributeSet != null) {
            TypedArray typedArrayObtainStyledAttributes2 = context.obtainStyledAttributes(attributeSet, a.f2255a, 0, 0);
            String string = typedArrayObtainStyledAttributes2.getString(7);
            if (typedArrayObtainStyledAttributes2.getInt(1, -1) == -1) {
                setDescendantFocusability(262144);
            }
            if (typedArrayObtainStyledAttributes2.getBoolean(2, false)) {
                StateListDrawable stateListDrawable = (StateListDrawable) typedArrayObtainStyledAttributes2.getDrawable(5);
                Drawable drawable = typedArrayObtainStyledAttributes2.getDrawable(6);
                StateListDrawable stateListDrawable2 = (StateListDrawable) typedArrayObtainStyledAttributes2.getDrawable(3);
                Drawable drawable2 = typedArrayObtainStyledAttributes2.getDrawable(4);
                if (stateListDrawable == null || drawable == null || stateListDrawable2 == null || drawable2 == null) {
                    throw new IllegalArgumentException("Trying to set fast scroller without both required drawables." + h());
                }
                Resources resources = getContext().getResources();
                i4 = 4;
                c5 = 3;
                new C0176g(this, stateListDrawable, drawable, stateListDrawable2, drawable2, resources.getDimensionPixelSize(com.swing.live.R.dimen.fastscroll_default_thickness), resources.getDimensionPixelSize(com.swing.live.R.dimen.fastscroll_minimum_range), resources.getDimensionPixelOffset(com.swing.live.R.dimen.fastscroll_margin));
            } else {
                i4 = 4;
                c5 = 3;
            }
            typedArrayObtainStyledAttributes2.recycle();
            if (string != null) {
                String strTrim = string.trim();
                if (!strTrim.isEmpty()) {
                    if (strTrim.charAt(0) == '.') {
                        strTrim = context.getPackageName() + strTrim;
                    } else if (!strTrim.contains(".")) {
                        strTrim = RecyclerView.class.getPackage().getName() + '.' + strTrim;
                    }
                    String str = strTrim;
                    try {
                        Class<? extends U> clsAsSubclass = (isInEditMode() ? getClass().getClassLoader() : context.getClassLoader()).loadClass(str).asSubclass(t.class);
                        try {
                            constructor = clsAsSubclass.getConstructor(f3131p0);
                            Object[] objArr2 = new Object[i4];
                            objArr2[0] = context;
                            objArr2[1] = attributeSet;
                            objArr2[2] = 0;
                            objArr2[c5] = 0;
                            objArr = objArr2;
                        } catch (NoSuchMethodException e) {
                            try {
                                constructor = clsAsSubclass.getConstructor(new Class[0]);
                                objArr = null;
                            } catch (NoSuchMethodException e4) {
                                e4.initCause(e);
                                throw new IllegalStateException(attributeSet.getPositionDescription() + ": Error creating LayoutManager " + str, e4);
                            }
                        }
                        constructor.setAccessible(true);
                        setLayoutManager((t) constructor.newInstance(objArr));
                    } catch (ClassCastException e5) {
                        throw new IllegalStateException(attributeSet.getPositionDescription() + ": Class is not a LayoutManager " + str, e5);
                    } catch (ClassNotFoundException e6) {
                        throw new IllegalStateException(attributeSet.getPositionDescription() + ": Unable to find LayoutManager " + str, e6);
                    } catch (IllegalAccessException e7) {
                        throw new IllegalStateException(attributeSet.getPositionDescription() + ": Cannot access non-public constructor " + str, e7);
                    } catch (InstantiationException e8) {
                        throw new IllegalStateException(attributeSet.getPositionDescription() + ": Could not instantiate the LayoutManager: " + str, e8);
                    } catch (InvocationTargetException e9) {
                        throw new IllegalStateException(attributeSet.getPositionDescription() + ": Could not instantiate the LayoutManager: " + str, e9);
                    }
                }
            }
            TypedArray typedArrayObtainStyledAttributes3 = context.obtainStyledAttributes(attributeSet, n0, 0, 0);
            z4 = typedArrayObtainStyledAttributes3.getBoolean(0, true);
            typedArrayObtainStyledAttributes3.recycle();
        } else {
            setDescendantFocusability(262144);
        }
        setNestedScrollingEnabled(z4);
    }

    private C0009i getScrollingChildHelper() {
        if (this.h0 == null) {
            this.h0 = new C0009i(this);
        }
        return this.h0;
    }

    public static void j(View view) {
        if (view == null) {
            return;
        }
        ((u) view.getLayoutParams()).getClass();
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void addFocusables(ArrayList arrayList, int i4, int i5) {
        t tVar = this.f3174o;
        if (tVar != null) {
            tVar.getClass();
        }
        super.addFocusables(arrayList, i4, i5);
    }

    public final void b(String str) {
        if (this.f3135C > 0) {
            if (str != null) {
                throw new IllegalStateException(str);
            }
            throw new IllegalStateException("Cannot call this method while RecyclerView is computing a layout or scrolling" + h());
        }
        if (this.f3136D > 0) {
            Log.w("RecyclerView", "Cannot call this method in a scroll callback. Scroll callbacks mightbe run during a measure & layout pass where you cannot change theRecyclerView data. Any method call that might change the structureof the RecyclerView or the adapter contents should be postponed tothe next frame.", new IllegalStateException("" + h()));
        }
    }

    public final void c(int i4, int i5) {
        boolean zIsFinished;
        EdgeEffect edgeEffect = this.f3138F;
        if (edgeEffect == null || edgeEffect.isFinished() || i4 <= 0) {
            zIsFinished = false;
        } else {
            this.f3138F.onRelease();
            zIsFinished = this.f3138F.isFinished();
        }
        EdgeEffect edgeEffect2 = this.f3140H;
        if (edgeEffect2 != null && !edgeEffect2.isFinished() && i4 < 0) {
            this.f3140H.onRelease();
            zIsFinished |= this.f3140H.isFinished();
        }
        EdgeEffect edgeEffect3 = this.f3139G;
        if (edgeEffect3 != null && !edgeEffect3.isFinished() && i5 > 0) {
            this.f3139G.onRelease();
            zIsFinished |= this.f3139G.isFinished();
        }
        EdgeEffect edgeEffect4 = this.f3141I;
        if (edgeEffect4 != null && !edgeEffect4.isFinished() && i5 < 0) {
            this.f3141I.onRelease();
            zIsFinished |= this.f3141I.isFinished();
        }
        if (zIsFinished) {
            Field field = C.f4a;
            postInvalidateOnAnimation();
        }
    }

    @Override // android.view.ViewGroup
    public final boolean checkLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return (layoutParams instanceof u) && this.f3174o.d((u) layoutParams);
    }

    @Override // android.view.View
    public final int computeHorizontalScrollExtent() {
        t tVar = this.f3174o;
        if (tVar != null && tVar.b()) {
            return this.f3174o.f(this.f3162d0);
        }
        return 0;
    }

    @Override // android.view.View
    public final int computeHorizontalScrollOffset() {
        t tVar = this.f3174o;
        if (tVar != null && tVar.b()) {
            this.f3174o.g(this.f3162d0);
        }
        return 0;
    }

    @Override // android.view.View
    public final int computeHorizontalScrollRange() {
        t tVar = this.f3174o;
        if (tVar != null && tVar.b()) {
            return this.f3174o.h(this.f3162d0);
        }
        return 0;
    }

    @Override // android.view.View
    public final int computeVerticalScrollExtent() {
        t tVar = this.f3174o;
        if (tVar != null && tVar.c()) {
            return this.f3174o.i(this.f3162d0);
        }
        return 0;
    }

    @Override // android.view.View
    public final int computeVerticalScrollOffset() {
        t tVar = this.f3174o;
        if (tVar != null && tVar.c()) {
            this.f3174o.j(this.f3162d0);
        }
        return 0;
    }

    @Override // android.view.View
    public final int computeVerticalScrollRange() {
        t tVar = this.f3174o;
        if (tVar != null && tVar.c()) {
            return this.f3174o.k(this.f3162d0);
        }
        return 0;
    }

    public final void d() {
        C0747k c0747k = this.f3159c;
        if (!this.f3180u || this.f3133A) {
            int i4 = f.f6682a;
            Trace.beginSection("RV FullInvalidate");
            Log.e("RecyclerView", "No adapter attached; skipping layout");
            Trace.endSection();
            return;
        }
        if (((ArrayList) c0747k.f6832c).size() > 0) {
            c0747k.getClass();
            if (((ArrayList) c0747k.f6832c).size() > 0) {
                int i5 = f.f6682a;
                Trace.beginSection("RV FullInvalidate");
                Log.e("RecyclerView", "No adapter attached; skipping layout");
                Trace.endSection();
            }
        }
    }

    @Override // android.view.View
    public final boolean dispatchNestedFling(float f4, float f5, boolean z4) {
        return getScrollingChildHelper().a(f4, f5, z4);
    }

    @Override // android.view.View
    public final boolean dispatchNestedPreFling(float f4, float f5) {
        return getScrollingChildHelper().b(f4, f5);
    }

    @Override // android.view.View
    public final boolean dispatchNestedPreScroll(int i4, int i5, int[] iArr, int[] iArr2) {
        return getScrollingChildHelper().c(i4, i5, iArr, iArr2, 0);
    }

    @Override // android.view.View
    public final boolean dispatchNestedScroll(int i4, int i5, int i6, int i7, int[] iArr) {
        return getScrollingChildHelper().d(i4, i5, i6, i7, iArr, 0, null);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void dispatchRestoreInstanceState(SparseArray sparseArray) {
        dispatchThawSelfOnly(sparseArray);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void dispatchSaveInstanceState(SparseArray sparseArray) {
        dispatchFreezeSelfOnly(sparseArray);
    }

    @Override // android.view.View
    public final void draw(Canvas canvas) {
        boolean z4;
        super.draw(canvas);
        ArrayList arrayList = this.f3175p;
        int size = arrayList.size();
        boolean z5 = false;
        for (int i4 = 0; i4 < size; i4++) {
            C0176g c0176g = (C0176g) arrayList.get(i4);
            if (c0176g.f2336l != c0176g.f2338n.getWidth() || c0176g.f2337m != c0176g.f2338n.getHeight()) {
                c0176g.f2336l = c0176g.f2338n.getWidth();
                c0176g.f2337m = c0176g.f2338n.getHeight();
                c0176g.e(0);
            } else if (c0176g.v != 0) {
                if (c0176g.f2339o) {
                    int i5 = c0176g.f2336l;
                    int i6 = c0176g.f2329d;
                    int i7 = i5 - i6;
                    int i8 = 0 - (0 / 2);
                    StateListDrawable stateListDrawable = c0176g.f2327b;
                    stateListDrawable.setBounds(0, 0, i6, 0);
                    int i9 = c0176g.f2337m;
                    Drawable drawable = c0176g.f2328c;
                    drawable.setBounds(0, 0, c0176g.e, i9);
                    RecyclerView recyclerView = c0176g.f2338n;
                    Field field = C.f4a;
                    if (recyclerView.getLayoutDirection() == 1) {
                        drawable.draw(canvas);
                        canvas.translate(i6, i8);
                        canvas.scale(-1.0f, 1.0f);
                        stateListDrawable.draw(canvas);
                        canvas.scale(1.0f, 1.0f);
                        canvas.translate(-i6, -i8);
                    } else {
                        canvas.translate(i7, 0.0f);
                        drawable.draw(canvas);
                        canvas.translate(0.0f, i8);
                        stateListDrawable.draw(canvas);
                        canvas.translate(-i7, -i8);
                    }
                }
                if (c0176g.f2340p) {
                    int i10 = c0176g.f2337m;
                    int i11 = c0176g.f2332h;
                    int i12 = i10 - i11;
                    StateListDrawable stateListDrawable2 = c0176g.f2330f;
                    stateListDrawable2.setBounds(0, 0, 0, i11);
                    int i13 = c0176g.f2336l;
                    Drawable drawable2 = c0176g.f2331g;
                    drawable2.setBounds(0, 0, i13, c0176g.f2333i);
                    canvas.translate(0.0f, i12);
                    drawable2.draw(canvas);
                    canvas.translate(0 - (0 / 2), 0.0f);
                    stateListDrawable2.draw(canvas);
                    canvas.translate(-r9, -i12);
                }
            }
        }
        EdgeEffect edgeEffect = this.f3138F;
        if (edgeEffect == null || edgeEffect.isFinished()) {
            z4 = false;
        } else {
            int iSave = canvas.save();
            int paddingBottom = this.f3164f ? getPaddingBottom() : 0;
            canvas.rotate(270.0f);
            canvas.translate((-getHeight()) + paddingBottom, 0.0f);
            EdgeEffect edgeEffect2 = this.f3138F;
            z4 = edgeEffect2 != null && edgeEffect2.draw(canvas);
            canvas.restoreToCount(iSave);
        }
        EdgeEffect edgeEffect3 = this.f3139G;
        if (edgeEffect3 != null && !edgeEffect3.isFinished()) {
            int iSave2 = canvas.save();
            if (this.f3164f) {
                canvas.translate(getPaddingLeft(), getPaddingTop());
            }
            EdgeEffect edgeEffect4 = this.f3139G;
            z4 |= edgeEffect4 != null && edgeEffect4.draw(canvas);
            canvas.restoreToCount(iSave2);
        }
        EdgeEffect edgeEffect5 = this.f3140H;
        if (edgeEffect5 != null && !edgeEffect5.isFinished()) {
            int iSave3 = canvas.save();
            int width = getWidth();
            int paddingTop = this.f3164f ? getPaddingTop() : 0;
            canvas.rotate(90.0f);
            canvas.translate(-paddingTop, -width);
            EdgeEffect edgeEffect6 = this.f3140H;
            z4 |= edgeEffect6 != null && edgeEffect6.draw(canvas);
            canvas.restoreToCount(iSave3);
        }
        EdgeEffect edgeEffect7 = this.f3141I;
        if (edgeEffect7 != null && !edgeEffect7.isFinished()) {
            int iSave4 = canvas.save();
            canvas.rotate(180.0f);
            if (this.f3164f) {
                canvas.translate(getPaddingRight() + (-getWidth()), getPaddingBottom() + (-getHeight()));
            } else {
                canvas.translate(-getWidth(), -getHeight());
            }
            EdgeEffect edgeEffect8 = this.f3141I;
            if (edgeEffect8 != null && edgeEffect8.draw(canvas)) {
                z5 = true;
            }
            z4 |= z5;
            canvas.restoreToCount(iSave4);
        }
        if ((z4 || this.J == null || arrayList.size() <= 0 || !this.J.b()) ? z4 : true) {
            Field field2 = C.f4a;
            postInvalidateOnAnimation();
        }
    }

    @Override // android.view.ViewGroup
    public final boolean drawChild(Canvas canvas, View view, long j4) {
        return super.drawChild(canvas, view, j4);
    }

    public final void e(int i4, int i5) {
        int paddingRight = getPaddingRight() + getPaddingLeft();
        Field field = C.f4a;
        setMeasuredDimension(t.e(i4, paddingRight, getMinimumWidth()), t.e(i5, getPaddingBottom() + getPaddingTop(), getMinimumHeight()));
    }

    public final boolean f(int i4, int i5, int[] iArr, int[] iArr2, int i6) {
        return getScrollingChildHelper().c(i4, i5, iArr, iArr2, i6);
    }

    /* JADX WARN: Code restructure failed: missing block: B:63:0x00c2, code lost:
    
        if (r4 > 0) goto L82;
     */
    /* JADX WARN: Code restructure failed: missing block: B:67:0x00e0, code lost:
    
        if (r7 > 0) goto L82;
     */
    /* JADX WARN: Code restructure failed: missing block: B:69:0x00e3, code lost:
    
        if (r4 < 0) goto L82;
     */
    /* JADX WARN: Code restructure failed: missing block: B:71:0x00e6, code lost:
    
        if (r7 < 0) goto L82;
     */
    /* JADX WARN: Code restructure failed: missing block: B:76:0x00ee, code lost:
    
        if ((r7 * r1) < 0) goto L83;
     */
    /* JADX WARN: Code restructure failed: missing block: B:81:0x00f6, code lost:
    
        if ((r7 * r1) > 0) goto L83;
     */
    @Override // android.view.ViewGroup, android.view.ViewParent
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.view.View focusSearch(android.view.View r13, int r14) {
        /*
            Method dump skipped, instruction units count: 254
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.recyclerview.widget.RecyclerView.focusSearch(android.view.View, int):android.view.View");
    }

    public final boolean g(int[] iArr, int i4) {
        return getScrollingChildHelper().d(0, 0, 0, 0, iArr, i4, null);
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateDefaultLayoutParams() {
        t tVar = this.f3174o;
        if (tVar != null) {
            return tVar.l();
        }
        throw new IllegalStateException("RecyclerView has no LayoutManager" + h());
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(AttributeSet attributeSet) {
        t tVar = this.f3174o;
        if (tVar != null) {
            return tVar.m(getContext(), attributeSet);
        }
        throw new IllegalStateException("RecyclerView has no LayoutManager" + h());
    }

    public p getAdapter() {
        return null;
    }

    @Override // android.view.View
    public int getBaseline() {
        t tVar = this.f3174o;
        if (tVar == null) {
            return super.getBaseline();
        }
        tVar.getClass();
        return -1;
    }

    @Override // android.view.ViewGroup
    public final int getChildDrawingOrder(int i4, int i5) {
        return super.getChildDrawingOrder(i4, i5);
    }

    @Override // android.view.ViewGroup
    public boolean getClipToPadding() {
        return this.f3164f;
    }

    public F getCompatAccessibilityDelegate() {
        return this.f3166g0;
    }

    public r getEdgeEffectFactory() {
        return this.f3137E;
    }

    public s getItemAnimator() {
        return this.J;
    }

    public int getItemDecorationCount() {
        return this.f3175p.size();
    }

    public t getLayoutManager() {
        return this.f3174o;
    }

    public int getMaxFlingVelocity() {
        return this.f3151T;
    }

    public int getMinFlingVelocity() {
        return this.f3150S;
    }

    public long getNanoTime() {
        return System.nanoTime();
    }

    public v getOnFlingListener() {
        return null;
    }

    public boolean getPreserveFocusAfterLayout() {
        return this.f3154W;
    }

    public y getRecycledViewPool() {
        c cVar = this.f3155a;
        if (((y) cVar.e) == null) {
            y yVar = new y();
            yVar.f2379a = new SparseArray();
            yVar.f2380b = 0;
            cVar.e = yVar;
        }
        return (y) cVar.e;
    }

    public int getScrollState() {
        return this.f3142K;
    }

    public final String h() {
        return " " + super.toString() + ", adapter:null, layout:" + this.f3174o + ", context:" + getContext();
    }

    @Override // android.view.View
    public final boolean hasNestedScrollingParent() {
        return getScrollingChildHelper().f(0);
    }

    public final View i(View view) {
        ViewParent parent = view.getParent();
        while (parent != null && parent != this && (parent instanceof View)) {
            view = parent;
            parent = view.getParent();
        }
        if (parent == this) {
            return view;
        }
        return null;
    }

    @Override // android.view.View
    public final boolean isAttachedToWindow() {
        return this.f3178s;
    }

    @Override // android.view.View
    public final boolean isNestedScrollingEnabled() {
        return getScrollingChildHelper().f53d;
    }

    public final boolean k() {
        return getScrollingChildHelper().f(1);
    }

    public final boolean l() {
        return !this.f3180u || this.f3133A || ((ArrayList) this.f3159c.f6832c).size() > 0;
    }

    public final void m() {
        int iL = this.f3161d.L();
        for (int i4 = 0; i4 < iL; i4++) {
            ((u) this.f3161d.K(i4).getLayoutParams()).f2378b = true;
        }
        ArrayList arrayList = (ArrayList) this.f3155a.f785c;
        if (arrayList.size() <= 0) {
            return;
        }
        arrayList.get(0).getClass();
        throw new ClassCastException();
    }

    public final void n(MotionEvent motionEvent) {
        int actionIndex = motionEvent.getActionIndex();
        if (motionEvent.getPointerId(actionIndex) == this.f3143L) {
            int i4 = actionIndex == 0 ? 1 : 0;
            this.f3143L = motionEvent.getPointerId(i4);
            int x4 = (int) (motionEvent.getX(i4) + 0.5f);
            this.f3147P = x4;
            this.f3145N = x4;
            int y4 = (int) (motionEvent.getY(i4) + 0.5f);
            this.f3148Q = y4;
            this.f3146O = y4;
        }
    }

    public final void o(View view, View view2) {
        View view3 = view2 != null ? view2 : view;
        int width = view3.getWidth();
        int height = view3.getHeight();
        Rect rect = this.f3171m;
        rect.set(0, 0, width, height);
        ViewGroup.LayoutParams layoutParams = view3.getLayoutParams();
        if (layoutParams instanceof u) {
            u uVar = (u) layoutParams;
            if (!uVar.f2378b) {
                int i4 = rect.left;
                Rect rect2 = uVar.f2377a;
                rect.left = i4 - rect2.left;
                rect.right += rect2.right;
                rect.top -= rect2.top;
                rect.bottom += rect2.bottom;
            }
        }
        if (view2 != null) {
            offsetDescendantRectToMyCoords(view2, rect);
            offsetRectIntoDescendantCoords(view, rect);
        }
        this.f3174o.G(this, view, this.f3171m, !this.f3180u, view2 == null);
    }

    /* JADX WARN: Removed duplicated region for block: B:18:0x0056  */
    @Override // android.view.ViewGroup, android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void onAttachedToWindow() {
        /*
            r5 = this;
            super.onAttachedToWindow()
            r0 = 0
            r5.f3135C = r0
            r1 = 1
            r5.f3178s = r1
            boolean r2 = r5.f3180u
            if (r2 == 0) goto L14
            boolean r2 = r5.isLayoutRequested()
            if (r2 != 0) goto L14
            r0 = r1
        L14:
            r5.f3180u = r0
            X.t r0 = r5.f3174o
            if (r0 == 0) goto L1c
            r0.e = r1
        L1c:
            java.lang.ThreadLocal r0 = X.RunnableC0179j.e
            java.lang.Object r1 = r0.get()
            X.j r1 = (X.RunnableC0179j) r1
            r5.f3158b0 = r1
            if (r1 != 0) goto L64
            X.j r1 = new X.j
            r1.<init>()
            java.util.ArrayList r2 = new java.util.ArrayList
            r2.<init>()
            r1.f2355a = r2
            java.util.ArrayList r2 = new java.util.ArrayList
            r2.<init>()
            r1.f2358d = r2
            r5.f3158b0 = r1
            java.lang.reflect.Field r1 = A.C.f4a
            android.view.Display r1 = r5.getDisplay()
            boolean r2 = r5.isInEditMode()
            if (r2 != 0) goto L56
            if (r1 == 0) goto L56
            float r1 = r1.getRefreshRate()
            r2 = 1106247680(0x41f00000, float:30.0)
            int r2 = (r1 > r2 ? 1 : (r1 == r2 ? 0 : -1))
            if (r2 < 0) goto L56
            goto L58
        L56:
            r1 = 1114636288(0x42700000, float:60.0)
        L58:
            X.j r2 = r5.f3158b0
            r3 = 1315859240(0x4e6e6b28, float:1.0E9)
            float r3 = r3 / r1
            long r3 = (long) r3
            r2.f2357c = r3
            r0.set(r2)
        L64:
            X.j r0 = r5.f3158b0
            java.util.ArrayList r0 = r0.f2355a
            r0.add(r5)
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.recyclerview.widget.RecyclerView.onAttachedToWindow():void");
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        Object obj;
        super.onDetachedFromWindow();
        s sVar = this.J;
        if (sVar != null) {
            sVar.a();
        }
        setScrollState(0);
        D d5 = this.f3156a0;
        d5.f2283m.removeCallbacks(d5);
        d5.f2280c.abortAnimation();
        this.f3178s = false;
        t tVar = this.f3174o;
        if (tVar != null) {
            tVar.e = false;
            tVar.z(this);
        }
        this.f3170l0.clear();
        removeCallbacks(this.f3172m0);
        this.e.getClass();
        do {
            H h4 = M.f2307a;
            int i4 = h4.f163a;
            obj = null;
            if (i4 > 0) {
                int i5 = i4 - 1;
                Object[] objArr = h4.f164b;
                Object obj2 = objArr[i5];
                i.c(obj2, "null cannot be cast to non-null type T of androidx.core.util.Pools.SimplePool");
                objArr[i5] = null;
                h4.f163a--;
                obj = obj2;
            }
        } while (obj != null);
        RunnableC0179j runnableC0179j = this.f3158b0;
        if (runnableC0179j != null) {
            runnableC0179j.f2355a.remove(this);
            this.f3158b0 = null;
        }
    }

    @Override // android.view.View
    public final void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        ArrayList arrayList = this.f3175p;
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            ((C0176g) arrayList.get(i4)).getClass();
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:28:0x0064  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x006a  */
    /* JADX WARN: Removed duplicated region for block: B:33:0x006e  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onGenericMotionEvent(android.view.MotionEvent r6) {
        /*
            r5 = this;
            X.t r0 = r5.f3174o
            r1 = 0
            if (r0 != 0) goto L7
            goto L79
        L7:
            boolean r0 = r5.f3181w
            if (r0 == 0) goto Ld
            goto L79
        Ld:
            int r0 = r6.getAction()
            r2 = 8
            if (r0 != r2) goto L79
            int r0 = r6.getSource()
            r0 = r0 & 2
            r2 = 0
            if (r0 == 0) goto L40
            X.t r0 = r5.f3174o
            boolean r0 = r0.c()
            if (r0 == 0) goto L2e
            r0 = 9
            float r0 = r6.getAxisValue(r0)
            float r0 = -r0
            goto L2f
        L2e:
            r0 = r2
        L2f:
            X.t r3 = r5.f3174o
            boolean r3 = r3.b()
            if (r3 == 0) goto L3e
            r3 = 10
            float r3 = r6.getAxisValue(r3)
            goto L66
        L3e:
            r3 = r2
            goto L66
        L40:
            int r0 = r6.getSource()
            r3 = 4194304(0x400000, float:5.877472E-39)
            r0 = r0 & r3
            if (r0 == 0) goto L64
            r0 = 26
            float r0 = r6.getAxisValue(r0)
            X.t r3 = r5.f3174o
            boolean r3 = r3.c()
            if (r3 == 0) goto L59
            float r0 = -r0
            goto L3e
        L59:
            X.t r3 = r5.f3174o
            boolean r3 = r3.b()
            if (r3 == 0) goto L64
            r3 = r0
            r0 = r2
            goto L66
        L64:
            r0 = r2
            r3 = r0
        L66:
            int r4 = (r0 > r2 ? 1 : (r0 == r2 ? 0 : -1))
            if (r4 != 0) goto L6e
            int r2 = (r3 > r2 ? 1 : (r3 == r2 ? 0 : -1))
            if (r2 == 0) goto L79
        L6e:
            float r2 = r5.f3152U
            float r3 = r3 * r2
            int r2 = (int) r3
            float r3 = r5.f3153V
            float r0 = r0 * r3
            int r0 = (int) r0
            r5.q(r2, r0, r6)
        L79:
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.recyclerview.widget.RecyclerView.onGenericMotionEvent(android.view.MotionEvent):boolean");
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // android.view.ViewGroup
    public final boolean onInterceptTouchEvent(MotionEvent motionEvent) {
        boolean z4;
        if (!this.f3181w) {
            int action = motionEvent.getAction();
            if (action == 3 || action == 0) {
                this.f3177r = null;
            }
            ArrayList arrayList = this.f3176q;
            int size = arrayList.size();
            for (int i4 = 0; i4 < size; i4++) {
                C0176g c0176g = (C0176g) arrayList.get(i4);
                if (c0176g.c(motionEvent) && action != 3) {
                    this.f3177r = c0176g;
                    p();
                    setScrollState(0);
                    return true;
                }
            }
            t tVar = this.f3174o;
            if (tVar != null) {
                boolean zB = tVar.b();
                boolean zC = this.f3174o.c();
                if (this.f3144M == null) {
                    this.f3144M = VelocityTracker.obtain();
                }
                this.f3144M.addMovement(motionEvent);
                int actionMasked = motionEvent.getActionMasked();
                int actionIndex = motionEvent.getActionIndex();
                if (actionMasked == 0) {
                    if (this.f3182x) {
                        this.f3182x = false;
                    }
                    this.f3143L = motionEvent.getPointerId(0);
                    int x4 = (int) (motionEvent.getX() + 0.5f);
                    this.f3147P = x4;
                    this.f3145N = x4;
                    int y4 = (int) (motionEvent.getY() + 0.5f);
                    this.f3148Q = y4;
                    this.f3146O = y4;
                    if (this.f3142K == 2) {
                        getParent().requestDisallowInterceptTouchEvent(true);
                        setScrollState(1);
                    }
                    int[] iArr = this.f3169k0;
                    iArr[1] = 0;
                    iArr[0] = 0;
                    int i5 = zB;
                    if (zC) {
                        i5 = (zB ? 1 : 0) | 2;
                    }
                    getScrollingChildHelper().g(i5, 0);
                } else if (actionMasked == 1) {
                    this.f3144M.clear();
                    s(0);
                } else if (actionMasked == 2) {
                    int iFindPointerIndex = motionEvent.findPointerIndex(this.f3143L);
                    if (iFindPointerIndex < 0) {
                        Log.e("RecyclerView", "Error processing scroll; pointer index for id " + this.f3143L + " not found. Did any MotionEvents get skipped?");
                        return false;
                    }
                    int x5 = (int) (motionEvent.getX(iFindPointerIndex) + 0.5f);
                    int y5 = (int) (motionEvent.getY(iFindPointerIndex) + 0.5f);
                    if (this.f3142K != 1) {
                        int i6 = x5 - this.f3145N;
                        int i7 = y5 - this.f3146O;
                        if (!zB || Math.abs(i6) <= this.f3149R) {
                            z4 = false;
                        } else {
                            this.f3147P = x5;
                            z4 = true;
                        }
                        if (zC && Math.abs(i7) > this.f3149R) {
                            this.f3148Q = y5;
                            z4 = true;
                        }
                        if (z4) {
                            setScrollState(1);
                        }
                    }
                } else if (actionMasked == 3) {
                    p();
                    setScrollState(0);
                } else if (actionMasked == 5) {
                    this.f3143L = motionEvent.getPointerId(actionIndex);
                    int x6 = (int) (motionEvent.getX(actionIndex) + 0.5f);
                    this.f3147P = x6;
                    this.f3145N = x6;
                    int y6 = (int) (motionEvent.getY(actionIndex) + 0.5f);
                    this.f3148Q = y6;
                    this.f3146O = y6;
                } else if (actionMasked == 6) {
                    n(motionEvent);
                }
                if (this.f3142K == 1) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        int i8 = f.f6682a;
        Trace.beginSection("RV OnLayout");
        Log.e("RecyclerView", "No adapter attached; skipping layout");
        Trace.endSection();
        this.f3180u = true;
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        t tVar = this.f3174o;
        if (tVar == null) {
            e(i4, i5);
            return;
        }
        if (tVar.y()) {
            View.MeasureSpec.getMode(i4);
            View.MeasureSpec.getMode(i5);
            this.f3174o.f2372b.e(i4, i5);
        } else {
            if (this.f3179t) {
                this.f3174o.f2372b.e(i4, i5);
                return;
            }
            B b5 = this.f3162d0;
            if (b5.e) {
                setMeasuredDimension(getMeasuredWidth(), getMeasuredHeight());
                return;
            }
            b5.getClass();
            this.v++;
            this.f3174o.f2372b.e(i4, i5);
            if (this.v < 1) {
                this.v = 1;
            }
            this.v--;
            b5.f2276c = false;
        }
    }

    @Override // android.view.ViewGroup
    public final boolean onRequestFocusInDescendants(int i4, Rect rect) {
        if (this.f3135C > 0) {
            return false;
        }
        return super.onRequestFocusInDescendants(i4, rect);
    }

    @Override // android.view.View
    public final void onRestoreInstanceState(Parcelable parcelable) {
        Parcelable parcelable2;
        if (!(parcelable instanceof A)) {
            super.onRestoreInstanceState(parcelable);
            return;
        }
        A a5 = (A) parcelable;
        this.f3157b = a5;
        super.onRestoreInstanceState(a5.f507a);
        t tVar = this.f3174o;
        if (tVar == null || (parcelable2 = this.f3157b.f2273c) == null) {
            return;
        }
        tVar.B(parcelable2);
    }

    @Override // android.view.View
    public final Parcelable onSaveInstanceState() {
        A a5 = new A(super.onSaveInstanceState());
        A a6 = this.f3157b;
        if (a6 != null) {
            a5.f2273c = a6.f2273c;
            return a5;
        }
        t tVar = this.f3174o;
        if (tVar != null) {
            a5.f2273c = tVar.C();
            return a5;
        }
        a5.f2273c = null;
        return a5;
    }

    @Override // android.view.View
    public final void onSizeChanged(int i4, int i5, int i6, int i7) {
        super.onSizeChanged(i4, i5, i6, i7);
        if (i4 == i6 && i5 == i7) {
            return;
        }
        this.f3141I = null;
        this.f3139G = null;
        this.f3140H = null;
        this.f3138F = null;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:103:0x022e  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onTouchEvent(android.view.MotionEvent r22) {
        /*
            Method dump skipped, instruction units count: 856
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.recyclerview.widget.RecyclerView.onTouchEvent(android.view.MotionEvent):boolean");
    }

    public final void p() {
        VelocityTracker velocityTracker = this.f3144M;
        if (velocityTracker != null) {
            velocityTracker.clear();
        }
        boolean zIsFinished = false;
        s(0);
        EdgeEffect edgeEffect = this.f3138F;
        if (edgeEffect != null) {
            edgeEffect.onRelease();
            zIsFinished = this.f3138F.isFinished();
        }
        EdgeEffect edgeEffect2 = this.f3139G;
        if (edgeEffect2 != null) {
            edgeEffect2.onRelease();
            zIsFinished |= this.f3139G.isFinished();
        }
        EdgeEffect edgeEffect3 = this.f3140H;
        if (edgeEffect3 != null) {
            edgeEffect3.onRelease();
            zIsFinished |= this.f3140H.isFinished();
        }
        EdgeEffect edgeEffect4 = this.f3141I;
        if (edgeEffect4 != null) {
            edgeEffect4.onRelease();
            zIsFinished |= this.f3141I.isFinished();
        }
        if (zIsFinished) {
            Field field = C.f4a;
            postInvalidateOnAnimation();
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:39:0x011a  */
    /* JADX WARN: Removed duplicated region for block: B:47:0x0171  */
    /* JADX WARN: Removed duplicated region for block: B:62:0x01d6  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void q(int r11, int r12, android.view.MotionEvent r13) {
        /*
            Method dump skipped, instruction units count: 488
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.recyclerview.widget.RecyclerView.q(int, int, android.view.MotionEvent):void");
    }

    public final void r(int i4, int i5) {
        int iRound;
        t tVar = this.f3174o;
        if (tVar == null) {
            Log.e("RecyclerView", "Cannot smooth scroll without a LayoutManager set. Call setLayoutManager with a non-null argument.");
            return;
        }
        if (this.f3181w) {
            return;
        }
        int i6 = !tVar.b() ? 0 : i4;
        int i7 = !this.f3174o.c() ? 0 : i5;
        if (i6 == 0 && i7 == 0) {
            return;
        }
        D d5 = this.f3156a0;
        d5.getClass();
        int iAbs = Math.abs(i6);
        int iAbs2 = Math.abs(i7);
        boolean z4 = iAbs > iAbs2;
        int iSqrt = (int) Math.sqrt(0);
        int iSqrt2 = (int) Math.sqrt((i7 * i7) + (i6 * i6));
        RecyclerView recyclerView = d5.f2283m;
        int width = z4 ? recyclerView.getWidth() : recyclerView.getHeight();
        int i8 = width / 2;
        float f4 = width;
        float f5 = i8;
        float fSin = (((float) Math.sin((Math.min(1.0f, (iSqrt2 * 1.0f) / f4) - 0.5f) * 0.47123894f)) * f5) + f5;
        if (iSqrt > 0) {
            iRound = Math.round(Math.abs(fSin / iSqrt) * 1000.0f) * 4;
        } else {
            if (!z4) {
                iAbs = iAbs2;
            }
            iRound = (int) (((iAbs / f4) + 1.0f) * 300.0f);
        }
        int iMin = Math.min(iRound, 2000);
        o oVar = f3132q0;
        if (d5.f2281d != oVar) {
            d5.f2281d = oVar;
            d5.f2280c = new OverScroller(recyclerView.getContext(), oVar);
        }
        recyclerView.setScrollState(2);
        d5.f2279b = 0;
        d5.f2278a = 0;
        d5.f2280c.startScroll(0, 0, i6, i7, iMin);
        d5.a();
    }

    @Override // android.view.ViewGroup
    public final void removeDetachedView(View view, boolean z4) {
        j(view);
        view.clearAnimation();
        j(view);
        super.removeDetachedView(view, z4);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void requestChildFocus(View view, View view2) {
        this.f3174o.getClass();
        if (this.f3135C <= 0 && view2 != null) {
            o(view, view2);
        }
        super.requestChildFocus(view, view2);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean requestChildRectangleOnScreen(View view, Rect rect, boolean z4) {
        return this.f3174o.G(this, view, rect, z4, false);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void requestDisallowInterceptTouchEvent(boolean z4) {
        ArrayList arrayList = this.f3176q;
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            ((C0176g) arrayList.get(i4)).getClass();
        }
        super.requestDisallowInterceptTouchEvent(z4);
    }

    @Override // android.view.View, android.view.ViewParent
    public final void requestLayout() {
        if (this.v != 0 || this.f3181w) {
            return;
        }
        super.requestLayout();
    }

    public final void s(int i4) {
        getScrollingChildHelper().h(i4);
    }

    @Override // android.view.View
    public final void scrollBy(int i4, int i5) {
        t tVar = this.f3174o;
        if (tVar == null) {
            Log.e("RecyclerView", "Cannot scroll without a LayoutManager set. Call setLayoutManager with a non-null argument.");
            return;
        }
        if (this.f3181w) {
            return;
        }
        boolean zB = tVar.b();
        boolean zC = this.f3174o.c();
        if (zB || zC) {
            if (!zB) {
                i4 = 0;
            }
            if (!zC) {
                i5 = 0;
            }
            q(i4, i5, null);
        }
    }

    @Override // android.view.View
    public final void scrollTo(int i4, int i5) {
        Log.w("RecyclerView", "RecyclerView does not support scrolling to an absolute position. Use scrollToPosition instead");
    }

    @Override // android.view.View, android.view.accessibility.AccessibilityEventSource
    public final void sendAccessibilityEventUnchecked(AccessibilityEvent accessibilityEvent) {
        if (this.f3135C <= 0) {
            super.sendAccessibilityEventUnchecked(accessibilityEvent);
        } else {
            int contentChangeTypes = accessibilityEvent != null ? accessibilityEvent.getContentChangeTypes() : 0;
            this.f3183y |= contentChangeTypes != 0 ? contentChangeTypes : 0;
        }
    }

    public void setAccessibilityDelegateCompat(F f4) {
        this.f3166g0 = f4;
        C.a(this, f4);
    }

    public void setAdapter(p pVar) {
        setLayoutFrozen(false);
        s sVar = this.J;
        if (sVar != null) {
            sVar.a();
        }
        t tVar = this.f3174o;
        c cVar = this.f3155a;
        if (tVar != null) {
            tVar.E();
            this.f3174o.F(cVar);
        }
        ((ArrayList) cVar.f787f).clear();
        ArrayList arrayList = (ArrayList) cVar.f785c;
        int size = arrayList.size() - 1;
        if (size >= 0) {
            arrayList.get(size).getClass();
            throw new ClassCastException();
        }
        arrayList.clear();
        C0177h c0177h = ((RecyclerView) cVar.f788g).f3160c0;
        c0177h.getClass();
        c0177h.f2349c = 0;
        C0747k c0747k = this.f3159c;
        c0747k.U((ArrayList) c0747k.f6832c);
        c0747k.U((ArrayList) c0747k.f6833d);
        ((ArrayList) cVar.f787f).clear();
        ArrayList arrayList2 = (ArrayList) cVar.f785c;
        int size2 = arrayList2.size() - 1;
        if (size2 >= 0) {
            arrayList2.get(size2).getClass();
            throw new ClassCastException();
        }
        arrayList2.clear();
        RecyclerView recyclerView = (RecyclerView) cVar.f788g;
        C0177h c0177h2 = recyclerView.f3160c0;
        c0177h2.getClass();
        c0177h2.f2349c = 0;
        if (((y) cVar.e) == null) {
            y yVar = new y();
            yVar.f2379a = new SparseArray();
            yVar.f2380b = 0;
            cVar.e = yVar;
        }
        y yVar2 = (y) cVar.e;
        if (yVar2.f2380b == 0) {
            SparseArray sparseArray = yVar2.f2379a;
            if (sparseArray.size() > 0) {
                ((x) sparseArray.valueAt(0)).getClass();
                throw null;
            }
        }
        this.f3162d0.f2275b = true;
        this.f3134B = this.f3134B;
        this.f3133A = true;
        int iL = this.f3161d.L();
        for (int i4 = 0; i4 < iL; i4++) {
            j(this.f3161d.K(i4));
        }
        m();
        int size3 = arrayList2.size();
        for (int i5 = 0; i5 < size3; i5++) {
            if (arrayList2.get(i5) != null) {
                throw new ClassCastException();
            }
        }
        int size4 = arrayList2.size() - 1;
        if (size4 >= 0) {
            arrayList2.get(size4).getClass();
            throw new ClassCastException();
        }
        arrayList2.clear();
        C0177h c0177h3 = recyclerView.f3160c0;
        c0177h3.getClass();
        c0177h3.f2349c = 0;
        requestLayout();
    }

    public void setChildDrawingOrderCallback(q qVar) {
        if (qVar == null) {
            return;
        }
        setChildrenDrawingOrderEnabled(false);
    }

    @Override // android.view.ViewGroup
    public void setClipToPadding(boolean z4) {
        if (z4 != this.f3164f) {
            this.f3141I = null;
            this.f3139G = null;
            this.f3140H = null;
            this.f3138F = null;
        }
        this.f3164f = z4;
        super.setClipToPadding(z4);
        if (this.f3180u) {
            requestLayout();
        }
    }

    public void setEdgeEffectFactory(r rVar) {
        rVar.getClass();
        this.f3137E = rVar;
        this.f3141I = null;
        this.f3139G = null;
        this.f3140H = null;
        this.f3138F = null;
    }

    public void setHasFixedSize(boolean z4) {
        this.f3179t = z4;
    }

    public void setItemAnimator(s sVar) {
        s sVar2 = this.J;
        if (sVar2 != null) {
            sVar2.a();
            this.J.f2367a = null;
        }
        this.J = sVar;
        if (sVar != null) {
            sVar.f2367a = this.f3165f0;
        }
    }

    public void setItemViewCacheSize(int i4) {
        c cVar = this.f3155a;
        cVar.f783a = i4;
        cVar.f();
    }

    public void setLayoutFrozen(boolean z4) {
        if (z4 != this.f3181w) {
            b("Do not setLayoutFrozen in layout or scroll");
            if (!z4) {
                this.f3181w = false;
                return;
            }
            long jUptimeMillis = SystemClock.uptimeMillis();
            onTouchEvent(MotionEvent.obtain(jUptimeMillis, jUptimeMillis, 3, 0.0f, 0.0f, 0));
            this.f3181w = true;
            this.f3182x = true;
            setScrollState(0);
            D d5 = this.f3156a0;
            d5.f2283m.removeCallbacks(d5);
            d5.f2280c.abortAnimation();
        }
    }

    public void setLayoutManager(t tVar) {
        C0690c c0690c;
        if (tVar == this.f3174o) {
            return;
        }
        setScrollState(0);
        D d5 = this.f3156a0;
        d5.f2283m.removeCallbacks(d5);
        d5.f2280c.abortAnimation();
        t tVar2 = this.f3174o;
        c cVar = this.f3155a;
        if (tVar2 != null) {
            s sVar = this.J;
            if (sVar != null) {
                sVar.a();
            }
            this.f3174o.E();
            this.f3174o.F(cVar);
            ((ArrayList) cVar.f787f).clear();
            ArrayList arrayList = (ArrayList) cVar.f785c;
            int size = arrayList.size() - 1;
            if (size >= 0) {
                arrayList.get(size).getClass();
                throw new ClassCastException();
            }
            arrayList.clear();
            C0177h c0177h = ((RecyclerView) cVar.f788g).f3160c0;
            c0177h.getClass();
            c0177h.f2349c = 0;
            if (this.f3178s) {
                t tVar3 = this.f3174o;
                tVar3.e = false;
                tVar3.z(this);
            }
            this.f3174o.I(null);
            this.f3174o = null;
        } else {
            ((ArrayList) cVar.f787f).clear();
            ArrayList arrayList2 = (ArrayList) cVar.f785c;
            int size2 = arrayList2.size() - 1;
            if (size2 >= 0) {
                arrayList2.get(size2).getClass();
                throw new ClassCastException();
            }
            arrayList2.clear();
            C0177h c0177h2 = ((RecyclerView) cVar.f788g).f3160c0;
            c0177h2.getClass();
            c0177h2.f2349c = 0;
        }
        C0747k c0747k = this.f3161d;
        ((C0171b) c0747k.f6832c).c();
        ArrayList arrayList3 = (ArrayList) c0747k.f6833d;
        int size3 = arrayList3.size() - 1;
        while (true) {
            c0690c = (C0690c) c0747k.f6831b;
            if (size3 < 0) {
                break;
            }
            j((View) arrayList3.get(size3));
            arrayList3.remove(size3);
            size3--;
        }
        RecyclerView recyclerView = (RecyclerView) c0690c.f6642b;
        int childCount = recyclerView.getChildCount();
        for (int i4 = 0; i4 < childCount; i4++) {
            View childAt = recyclerView.getChildAt(i4);
            j(childAt);
            childAt.clearAnimation();
        }
        recyclerView.removeAllViews();
        this.f3174o = tVar;
        if (tVar != null) {
            if (tVar.f2372b != null) {
                throw new IllegalArgumentException("LayoutManager " + tVar + " is already attached to a RecyclerView:" + tVar.f2372b.h());
            }
            tVar.I(this);
            if (this.f3178s) {
                this.f3174o.e = true;
            }
        }
        cVar.f();
        requestLayout();
    }

    @Override // android.view.View
    public void setNestedScrollingEnabled(boolean z4) {
        C0009i scrollingChildHelper = getScrollingChildHelper();
        if (scrollingChildHelper.f53d) {
            Field field = C.f4a;
            AbstractC0019t.z(scrollingChildHelper.f52c);
        }
        scrollingChildHelper.f53d = z4;
    }

    public void setPreserveFocusAfterLayout(boolean z4) {
        this.f3154W = z4;
    }

    public void setRecycledViewPool(y yVar) {
        c cVar = this.f3155a;
        if (((y) cVar.e) != null) {
            r1.f2380b--;
        }
        cVar.e = yVar;
        if (yVar != null) {
            ((RecyclerView) cVar.f788g).getAdapter();
        }
    }

    public void setScrollState(int i4) {
        if (i4 == this.f3142K) {
            return;
        }
        this.f3142K = i4;
        if (i4 != 2) {
            D d5 = this.f3156a0;
            d5.f2283m.removeCallbacks(d5);
            d5.f2280c.abortAnimation();
        }
        t tVar = this.f3174o;
        if (tVar != null) {
            tVar.D(i4);
        }
        ArrayList arrayList = this.f3163e0;
        if (arrayList != null) {
            for (int size = arrayList.size() - 1; size >= 0; size--) {
                ((w) this.f3163e0.get(size)).getClass();
            }
        }
    }

    public void setScrollingTouchSlop(int i4) {
        ViewConfiguration viewConfiguration = ViewConfiguration.get(getContext());
        if (i4 != 0) {
            if (i4 == 1) {
                this.f3149R = viewConfiguration.getScaledPagingTouchSlop();
                return;
            }
            Log.w("RecyclerView", "setScrollingTouchSlop(): bad argument constant " + i4 + "; using default value");
        }
        this.f3149R = viewConfiguration.getScaledTouchSlop();
    }

    public void setViewCacheExtension(X.C c5) {
        this.f3155a.getClass();
    }

    @Override // android.view.View
    public final boolean startNestedScroll(int i4) {
        return getScrollingChildHelper().g(i4, 0);
    }

    @Override // android.view.View
    public final void stopNestedScroll() {
        getScrollingChildHelper().h(0);
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams layoutParams) {
        t tVar = this.f3174o;
        if (tVar != null) {
            return tVar.n(layoutParams);
        }
        throw new IllegalStateException("RecyclerView has no LayoutManager" + h());
    }

    public void setOnFlingListener(v vVar) {
    }

    @Deprecated
    public void setOnScrollListener(w wVar) {
    }

    public void setRecyclerListener(z zVar) {
    }
}
