package androidx.appcompat.widget;

import A.C;
import B.k;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.ContextThemeWrapper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import com.swing.live.R;
import f.AbstractC0398a;
import g.AbstractC0404a;
import i.C0419d;
import j.j;
import java.lang.reflect.Field;
import java.util.ArrayList;
import k.C0489f;
import k.C0492i;
import k.C0499p;
import k.C0500q;
import k.C0504v;
import k.InterfaceC0507y;
import k.Q;
import k.k0;
import k.l0;
import k.m0;
import k.n0;
import k.o0;
import k.p0;
import k.v0;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class Toolbar extends ViewGroup {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public int f2809A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public int f2810B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final int f2811C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public CharSequence f2812D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public CharSequence f2813E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public ColorStateList f2814F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public ColorStateList f2815G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public boolean f2816H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public boolean f2817I;
    public final ArrayList J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public final ArrayList f2818K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public final int[] f2819L;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public final k f2820M;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public p0 f2821N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public l0 f2822O;

    /* JADX INFO: renamed from: P, reason: collision with root package name */
    public boolean f2823P;

    /* JADX INFO: renamed from: Q, reason: collision with root package name */
    public final F.b f2824Q;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ActionMenuView f2825a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0504v f2826b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0504v f2827c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0499p f2828d;
    public C0500q e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Drawable f2829f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final CharSequence f2830m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public C0499p f2831n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public View f2832o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public Context f2833p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f2834q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f2835r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f2836s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final int f2837t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final int f2838u;
    public int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public int f2839w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f2840x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f2841y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public Q f2842z;

    public Toolbar(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, R.attr.toolbarStyle);
        this.f2811C = 8388627;
        this.J = new ArrayList();
        this.f2818K = new ArrayList();
        this.f2819L = new int[2];
        this.f2820M = new k(this, 24);
        this.f2824Q = new F.b(this, 13);
        C0747k c0747kP = C0747k.P(getContext(), attributeSet, AbstractC0398a.f4262t, R.attr.toolbarStyle);
        TypedArray typedArray = (TypedArray) c0747kP.f6832c;
        this.f2835r = typedArray.getResourceId(28, 0);
        this.f2836s = typedArray.getResourceId(19, 0);
        this.f2811C = typedArray.getInteger(0, 8388627);
        this.f2837t = typedArray.getInteger(2, 48);
        int dimensionPixelOffset = typedArray.getDimensionPixelOffset(22, 0);
        dimensionPixelOffset = typedArray.hasValue(27) ? typedArray.getDimensionPixelOffset(27, dimensionPixelOffset) : dimensionPixelOffset;
        this.f2841y = dimensionPixelOffset;
        this.f2840x = dimensionPixelOffset;
        this.f2839w = dimensionPixelOffset;
        this.v = dimensionPixelOffset;
        int dimensionPixelOffset2 = typedArray.getDimensionPixelOffset(25, -1);
        if (dimensionPixelOffset2 >= 0) {
            this.v = dimensionPixelOffset2;
        }
        int dimensionPixelOffset3 = typedArray.getDimensionPixelOffset(24, -1);
        if (dimensionPixelOffset3 >= 0) {
            this.f2839w = dimensionPixelOffset3;
        }
        int dimensionPixelOffset4 = typedArray.getDimensionPixelOffset(26, -1);
        if (dimensionPixelOffset4 >= 0) {
            this.f2840x = dimensionPixelOffset4;
        }
        int dimensionPixelOffset5 = typedArray.getDimensionPixelOffset(23, -1);
        if (dimensionPixelOffset5 >= 0) {
            this.f2841y = dimensionPixelOffset5;
        }
        this.f2838u = typedArray.getDimensionPixelSize(13, -1);
        int dimensionPixelOffset6 = typedArray.getDimensionPixelOffset(9, Integer.MIN_VALUE);
        int dimensionPixelOffset7 = typedArray.getDimensionPixelOffset(5, Integer.MIN_VALUE);
        int dimensionPixelSize = typedArray.getDimensionPixelSize(7, 0);
        int dimensionPixelSize2 = typedArray.getDimensionPixelSize(8, 0);
        d();
        Q q4 = this.f2842z;
        q4.f5329h = false;
        if (dimensionPixelSize != Integer.MIN_VALUE) {
            q4.e = dimensionPixelSize;
            q4.f5323a = dimensionPixelSize;
        }
        if (dimensionPixelSize2 != Integer.MIN_VALUE) {
            q4.f5327f = dimensionPixelSize2;
            q4.f5324b = dimensionPixelSize2;
        }
        if (dimensionPixelOffset6 != Integer.MIN_VALUE || dimensionPixelOffset7 != Integer.MIN_VALUE) {
            q4.a(dimensionPixelOffset6, dimensionPixelOffset7);
        }
        this.f2809A = typedArray.getDimensionPixelOffset(10, Integer.MIN_VALUE);
        this.f2810B = typedArray.getDimensionPixelOffset(6, Integer.MIN_VALUE);
        this.f2829f = c0747kP.F(4);
        this.f2830m = typedArray.getText(3);
        CharSequence text = typedArray.getText(21);
        if (!TextUtils.isEmpty(text)) {
            setTitle(text);
        }
        CharSequence text2 = typedArray.getText(18);
        if (!TextUtils.isEmpty(text2)) {
            setSubtitle(text2);
        }
        this.f2833p = getContext();
        setPopupTheme(typedArray.getResourceId(17, 0));
        Drawable drawableF = c0747kP.F(16);
        if (drawableF != null) {
            setNavigationIcon(drawableF);
        }
        CharSequence text3 = typedArray.getText(15);
        if (!TextUtils.isEmpty(text3)) {
            setNavigationContentDescription(text3);
        }
        Drawable drawableF2 = c0747kP.F(11);
        if (drawableF2 != null) {
            setLogo(drawableF2);
        }
        CharSequence text4 = typedArray.getText(12);
        if (!TextUtils.isEmpty(text4)) {
            setLogoDescription(text4);
        }
        if (typedArray.hasValue(29)) {
            setTitleTextColor(c0747kP.E(29));
        }
        if (typedArray.hasValue(20)) {
            setSubtitleTextColor(c0747kP.E(20));
        }
        if (typedArray.hasValue(14)) {
            getMenuInflater().inflate(typedArray.getResourceId(14, 0), getMenu());
        }
        c0747kP.T();
    }

    public static m0 g() {
        m0 m0Var = new m0(-2, -2);
        m0Var.f5412b = 0;
        m0Var.f5411a = 8388627;
        return m0Var;
    }

    private MenuInflater getMenuInflater() {
        return new C0419d(getContext());
    }

    public static m0 h(ViewGroup.LayoutParams layoutParams) {
        boolean z4 = layoutParams instanceof m0;
        if (z4) {
            m0 m0Var = (m0) layoutParams;
            m0 m0Var2 = new m0(m0Var);
            m0Var2.f5412b = 0;
            m0Var2.f5412b = m0Var.f5412b;
            return m0Var2;
        }
        if (z4) {
            m0 m0Var3 = new m0((m0) layoutParams);
            m0Var3.f5412b = 0;
            return m0Var3;
        }
        if (!(layoutParams instanceof ViewGroup.MarginLayoutParams)) {
            m0 m0Var4 = new m0(layoutParams);
            m0Var4.f5412b = 0;
            return m0Var4;
        }
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) layoutParams;
        m0 m0Var5 = new m0(marginLayoutParams);
        m0Var5.f5412b = 0;
        ((ViewGroup.MarginLayoutParams) m0Var5).leftMargin = marginLayoutParams.leftMargin;
        ((ViewGroup.MarginLayoutParams) m0Var5).topMargin = marginLayoutParams.topMargin;
        ((ViewGroup.MarginLayoutParams) m0Var5).rightMargin = marginLayoutParams.rightMargin;
        ((ViewGroup.MarginLayoutParams) m0Var5).bottomMargin = marginLayoutParams.bottomMargin;
        return m0Var5;
    }

    public static int j(View view) {
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        return marginLayoutParams.getMarginEnd() + marginLayoutParams.getMarginStart();
    }

    public static int k(View view) {
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        return marginLayoutParams.topMargin + marginLayoutParams.bottomMargin;
    }

    public final void a(int i4, ArrayList arrayList) {
        Field field = C.f4a;
        boolean z4 = getLayoutDirection() == 1;
        int childCount = getChildCount();
        int absoluteGravity = Gravity.getAbsoluteGravity(i4, getLayoutDirection());
        arrayList.clear();
        if (!z4) {
            for (int i5 = 0; i5 < childCount; i5++) {
                View childAt = getChildAt(i5);
                m0 m0Var = (m0) childAt.getLayoutParams();
                if (m0Var.f5412b == 0 && q(childAt)) {
                    int i6 = m0Var.f5411a;
                    Field field2 = C.f4a;
                    int layoutDirection = getLayoutDirection();
                    int absoluteGravity2 = Gravity.getAbsoluteGravity(i6, layoutDirection) & 7;
                    if (absoluteGravity2 != 1 && absoluteGravity2 != 3 && absoluteGravity2 != 5) {
                        absoluteGravity2 = layoutDirection == 1 ? 5 : 3;
                    }
                    if (absoluteGravity2 == absoluteGravity) {
                        arrayList.add(childAt);
                    }
                }
            }
            return;
        }
        for (int i7 = childCount - 1; i7 >= 0; i7--) {
            View childAt2 = getChildAt(i7);
            m0 m0Var2 = (m0) childAt2.getLayoutParams();
            if (m0Var2.f5412b == 0 && q(childAt2)) {
                int i8 = m0Var2.f5411a;
                Field field3 = C.f4a;
                int layoutDirection2 = getLayoutDirection();
                int absoluteGravity3 = Gravity.getAbsoluteGravity(i8, layoutDirection2) & 7;
                if (absoluteGravity3 != 1 && absoluteGravity3 != 3 && absoluteGravity3 != 5) {
                    absoluteGravity3 = layoutDirection2 == 1 ? 5 : 3;
                }
                if (absoluteGravity3 == absoluteGravity) {
                    arrayList.add(childAt2);
                }
            }
        }
    }

    public final void b(View view, boolean z4) {
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
        m0 m0VarG = layoutParams == null ? g() : !checkLayoutParams(layoutParams) ? h(layoutParams) : (m0) layoutParams;
        m0VarG.f5412b = 1;
        if (!z4 || this.f2832o == null) {
            addView(view, m0VarG);
        } else {
            view.setLayoutParams(m0VarG);
            this.f2818K.add(view);
        }
    }

    public final void c() {
        if (this.f2831n == null) {
            C0499p c0499p = new C0499p(getContext());
            this.f2831n = c0499p;
            c0499p.setImageDrawable(this.f2829f);
            this.f2831n.setContentDescription(this.f2830m);
            m0 m0VarG = g();
            m0VarG.f5411a = (this.f2837t & 112) | 8388611;
            m0VarG.f5412b = 2;
            this.f2831n.setLayoutParams(m0VarG);
            this.f2831n.setOnClickListener(new k0(this));
        }
    }

    @Override // android.view.ViewGroup
    public final boolean checkLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return super.checkLayoutParams(layoutParams) && (layoutParams instanceof m0);
    }

    public final void d() {
        if (this.f2842z == null) {
            Q q4 = new Q();
            q4.f5323a = 0;
            q4.f5324b = 0;
            q4.f5325c = Integer.MIN_VALUE;
            q4.f5326d = Integer.MIN_VALUE;
            q4.e = 0;
            q4.f5327f = 0;
            q4.f5328g = false;
            q4.f5329h = false;
            this.f2842z = q4;
        }
    }

    public final void e() {
        if (this.f2825a == null) {
            ActionMenuView actionMenuView = new ActionMenuView(getContext(), null);
            this.f2825a = actionMenuView;
            actionMenuView.setPopupTheme(this.f2834q);
            this.f2825a.setOnMenuItemClickListener(this.f2820M);
            this.f2825a.getClass();
            m0 m0VarG = g();
            m0VarG.f5411a = (this.f2837t & 112) | 8388613;
            this.f2825a.setLayoutParams(m0VarG);
            b(this.f2825a, false);
        }
        ActionMenuView actionMenuView2 = this.f2825a;
        if (actionMenuView2.v == null) {
            j jVar = (j) actionMenuView2.getMenu();
            if (this.f2822O == null) {
                this.f2822O = new l0(this);
            }
            this.f2825a.setExpandedActionViewsExclusive(true);
            jVar.b(this.f2822O, this.f2833p);
        }
    }

    public final void f() {
        if (this.f2828d == null) {
            this.f2828d = new C0499p(getContext());
            m0 m0VarG = g();
            m0VarG.f5411a = (this.f2837t & 112) | 8388611;
            this.f2828d.setLayoutParams(m0VarG);
        }
    }

    @Override // android.view.ViewGroup
    public final /* bridge */ /* synthetic */ ViewGroup.LayoutParams generateDefaultLayoutParams() {
        return g();
    }

    @Override // android.view.ViewGroup
    public final /* bridge */ /* synthetic */ ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return h(layoutParams);
    }

    public CharSequence getCollapseContentDescription() {
        C0499p c0499p = this.f2831n;
        if (c0499p != null) {
            return c0499p.getContentDescription();
        }
        return null;
    }

    public Drawable getCollapseIcon() {
        C0499p c0499p = this.f2831n;
        if (c0499p != null) {
            return c0499p.getDrawable();
        }
        return null;
    }

    public int getContentInsetEnd() {
        Q q4 = this.f2842z;
        if (q4 != null) {
            return q4.f5328g ? q4.f5323a : q4.f5324b;
        }
        return 0;
    }

    public int getContentInsetEndWithActions() {
        int i4 = this.f2810B;
        return i4 != Integer.MIN_VALUE ? i4 : getContentInsetEnd();
    }

    public int getContentInsetLeft() {
        Q q4 = this.f2842z;
        if (q4 != null) {
            return q4.f5323a;
        }
        return 0;
    }

    public int getContentInsetRight() {
        Q q4 = this.f2842z;
        if (q4 != null) {
            return q4.f5324b;
        }
        return 0;
    }

    public int getContentInsetStart() {
        Q q4 = this.f2842z;
        if (q4 != null) {
            return q4.f5328g ? q4.f5324b : q4.f5323a;
        }
        return 0;
    }

    public int getContentInsetStartWithNavigation() {
        int i4 = this.f2809A;
        return i4 != Integer.MIN_VALUE ? i4 : getContentInsetStart();
    }

    public int getCurrentContentInsetEnd() {
        j jVar;
        ActionMenuView actionMenuView = this.f2825a;
        return (actionMenuView == null || (jVar = actionMenuView.v) == null || !jVar.hasVisibleItems()) ? getContentInsetEnd() : Math.max(getContentInsetEnd(), Math.max(this.f2810B, 0));
    }

    public int getCurrentContentInsetLeft() {
        Field field = C.f4a;
        return getLayoutDirection() == 1 ? getCurrentContentInsetEnd() : getCurrentContentInsetStart();
    }

    public int getCurrentContentInsetRight() {
        Field field = C.f4a;
        return getLayoutDirection() == 1 ? getCurrentContentInsetStart() : getCurrentContentInsetEnd();
    }

    public int getCurrentContentInsetStart() {
        return getNavigationIcon() != null ? Math.max(getContentInsetStart(), Math.max(this.f2809A, 0)) : getContentInsetStart();
    }

    public Drawable getLogo() {
        C0500q c0500q = this.e;
        if (c0500q != null) {
            return c0500q.getDrawable();
        }
        return null;
    }

    public CharSequence getLogoDescription() {
        C0500q c0500q = this.e;
        if (c0500q != null) {
            return c0500q.getContentDescription();
        }
        return null;
    }

    public Menu getMenu() {
        e();
        return this.f2825a.getMenu();
    }

    public CharSequence getNavigationContentDescription() {
        C0499p c0499p = this.f2828d;
        if (c0499p != null) {
            return c0499p.getContentDescription();
        }
        return null;
    }

    public Drawable getNavigationIcon() {
        C0499p c0499p = this.f2828d;
        if (c0499p != null) {
            return c0499p.getDrawable();
        }
        return null;
    }

    public C0492i getOuterActionMenuPresenter() {
        return null;
    }

    public Drawable getOverflowIcon() {
        e();
        return this.f2825a.getOverflowIcon();
    }

    public Context getPopupContext() {
        return this.f2833p;
    }

    public int getPopupTheme() {
        return this.f2834q;
    }

    public CharSequence getSubtitle() {
        return this.f2813E;
    }

    public final TextView getSubtitleTextView() {
        return this.f2827c;
    }

    public CharSequence getTitle() {
        return this.f2812D;
    }

    public int getTitleMarginBottom() {
        return this.f2841y;
    }

    public int getTitleMarginEnd() {
        return this.f2839w;
    }

    public int getTitleMarginStart() {
        return this.v;
    }

    public int getTitleMarginTop() {
        return this.f2840x;
    }

    public final TextView getTitleTextView() {
        return this.f2826b;
    }

    public InterfaceC0507y getWrapper() {
        Drawable drawable;
        if (this.f2821N == null) {
            p0 p0Var = new p0();
            p0Var.f5435l = 0;
            p0Var.f5425a = this;
            p0Var.f5431h = getTitle();
            p0Var.f5432i = getSubtitle();
            p0Var.f5430g = p0Var.f5431h != null;
            p0Var.f5429f = getNavigationIcon();
            C0747k c0747kP = C0747k.P(getContext(), null, AbstractC0398a.f4244a, R.attr.actionBarStyle);
            p0Var.f5436m = c0747kP.F(15);
            TypedArray typedArray = (TypedArray) c0747kP.f6832c;
            CharSequence text = typedArray.getText(27);
            if (!TextUtils.isEmpty(text)) {
                p0Var.f5430g = true;
                p0Var.f5431h = text;
                if ((p0Var.f5426b & 8) != 0) {
                    p0Var.f5425a.setTitle(text);
                }
            }
            CharSequence text2 = typedArray.getText(25);
            if (!TextUtils.isEmpty(text2)) {
                p0Var.f5432i = text2;
                if ((p0Var.f5426b & 8) != 0) {
                    setSubtitle(text2);
                }
            }
            Drawable drawableF = c0747kP.F(20);
            if (drawableF != null) {
                p0Var.e = drawableF;
                p0Var.c();
            }
            Drawable drawableF2 = c0747kP.F(17);
            if (drawableF2 != null) {
                p0Var.f5428d = drawableF2;
                p0Var.c();
            }
            if (p0Var.f5429f == null && (drawable = p0Var.f5436m) != null) {
                p0Var.f5429f = drawable;
                int i4 = p0Var.f5426b & 4;
                Toolbar toolbar = p0Var.f5425a;
                if (i4 != 0) {
                    toolbar.setNavigationIcon(drawable);
                } else {
                    toolbar.setNavigationIcon((Drawable) null);
                }
            }
            p0Var.a(typedArray.getInt(10, 0));
            int resourceId = typedArray.getResourceId(9, 0);
            if (resourceId != 0) {
                View viewInflate = LayoutInflater.from(getContext()).inflate(resourceId, (ViewGroup) this, false);
                View view = p0Var.f5427c;
                if (view != null && (p0Var.f5426b & 16) != 0) {
                    removeView(view);
                }
                p0Var.f5427c = viewInflate;
                if (viewInflate != null && (p0Var.f5426b & 16) != 0) {
                    addView(viewInflate);
                }
                p0Var.a(p0Var.f5426b | 16);
            }
            int layoutDimension = typedArray.getLayoutDimension(13, 0);
            if (layoutDimension > 0) {
                ViewGroup.LayoutParams layoutParams = getLayoutParams();
                layoutParams.height = layoutDimension;
                setLayoutParams(layoutParams);
            }
            int dimensionPixelOffset = typedArray.getDimensionPixelOffset(7, -1);
            int dimensionPixelOffset2 = typedArray.getDimensionPixelOffset(3, -1);
            if (dimensionPixelOffset >= 0 || dimensionPixelOffset2 >= 0) {
                int iMax = Math.max(dimensionPixelOffset, 0);
                int iMax2 = Math.max(dimensionPixelOffset2, 0);
                d();
                this.f2842z.a(iMax, iMax2);
            }
            int resourceId2 = typedArray.getResourceId(28, 0);
            if (resourceId2 != 0) {
                Context context = getContext();
                this.f2835r = resourceId2;
                C0504v c0504v = this.f2826b;
                if (c0504v != null) {
                    c0504v.setTextAppearance(context, resourceId2);
                }
            }
            int resourceId3 = typedArray.getResourceId(26, 0);
            if (resourceId3 != 0) {
                Context context2 = getContext();
                this.f2836s = resourceId3;
                C0504v c0504v2 = this.f2827c;
                if (c0504v2 != null) {
                    c0504v2.setTextAppearance(context2, resourceId3);
                }
            }
            int resourceId4 = typedArray.getResourceId(22, 0);
            if (resourceId4 != 0) {
                setPopupTheme(resourceId4);
            }
            c0747kP.T();
            if (R.string.abc_action_bar_up_description != p0Var.f5435l) {
                p0Var.f5435l = R.string.abc_action_bar_up_description;
                if (TextUtils.isEmpty(getNavigationContentDescription())) {
                    int i5 = p0Var.f5435l;
                    p0Var.f5433j = i5 != 0 ? getContext().getString(i5) : null;
                    p0Var.b();
                }
            }
            p0Var.f5433j = getNavigationContentDescription();
            setNavigationOnClickListener(new k0(p0Var));
            this.f2821N = p0Var;
        }
        return this.f2821N;
    }

    public final int i(View view, int i4) {
        m0 m0Var = (m0) view.getLayoutParams();
        int measuredHeight = view.getMeasuredHeight();
        int i5 = i4 > 0 ? (measuredHeight - i4) / 2 : 0;
        int i6 = m0Var.f5411a & 112;
        if (i6 != 16 && i6 != 48 && i6 != 80) {
            i6 = this.f2811C & 112;
        }
        if (i6 == 48) {
            return getPaddingTop() - i5;
        }
        if (i6 == 80) {
            return (((getHeight() - getPaddingBottom()) - measuredHeight) - ((ViewGroup.MarginLayoutParams) m0Var).bottomMargin) - i5;
        }
        int paddingTop = getPaddingTop();
        int paddingBottom = getPaddingBottom();
        int height = getHeight();
        int iMax = (((height - paddingTop) - paddingBottom) - measuredHeight) / 2;
        int i7 = ((ViewGroup.MarginLayoutParams) m0Var).topMargin;
        if (iMax < i7) {
            iMax = i7;
        } else {
            int i8 = (((height - paddingBottom) - measuredHeight) - iMax) - paddingTop;
            int i9 = ((ViewGroup.MarginLayoutParams) m0Var).bottomMargin;
            if (i8 < i9) {
                iMax = Math.max(0, iMax - (i9 - i8));
            }
        }
        return paddingTop + iMax;
    }

    public final boolean l(View view) {
        return view.getParent() == this || this.f2818K.contains(view);
    }

    public final int m(View view, int i4, int i5, int[] iArr) {
        m0 m0Var = (m0) view.getLayoutParams();
        int i6 = ((ViewGroup.MarginLayoutParams) m0Var).leftMargin - iArr[0];
        int iMax = Math.max(0, i6) + i4;
        iArr[0] = Math.max(0, -i6);
        int i7 = i(view, i5);
        int measuredWidth = view.getMeasuredWidth();
        view.layout(iMax, i7, iMax + measuredWidth, view.getMeasuredHeight() + i7);
        return measuredWidth + ((ViewGroup.MarginLayoutParams) m0Var).rightMargin + iMax;
    }

    public final int n(View view, int i4, int i5, int[] iArr) {
        m0 m0Var = (m0) view.getLayoutParams();
        int i6 = ((ViewGroup.MarginLayoutParams) m0Var).rightMargin - iArr[1];
        int iMax = i4 - Math.max(0, i6);
        iArr[1] = Math.max(0, -i6);
        int i7 = i(view, i5);
        int measuredWidth = view.getMeasuredWidth();
        view.layout(iMax - measuredWidth, i7, iMax, view.getMeasuredHeight() + i7);
        return iMax - (measuredWidth + ((ViewGroup.MarginLayoutParams) m0Var).leftMargin);
    }

    public final int o(View view, int i4, int i5, int i6, int i7, int[] iArr) {
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        int i8 = marginLayoutParams.leftMargin - iArr[0];
        int i9 = marginLayoutParams.rightMargin - iArr[1];
        int iMax = Math.max(0, i9) + Math.max(0, i8);
        iArr[0] = Math.max(0, -i8);
        iArr[1] = Math.max(0, -i9);
        view.measure(ViewGroup.getChildMeasureSpec(i4, getPaddingRight() + getPaddingLeft() + iMax + i5, marginLayoutParams.width), ViewGroup.getChildMeasureSpec(i6, getPaddingBottom() + getPaddingTop() + marginLayoutParams.topMargin + marginLayoutParams.bottomMargin + i7, marginLayoutParams.height));
        return view.getMeasuredWidth() + iMax;
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeCallbacks(this.f2824Q);
    }

    @Override // android.view.View
    public final boolean onHoverEvent(MotionEvent motionEvent) {
        int actionMasked = motionEvent.getActionMasked();
        if (actionMasked == 9) {
            this.f2817I = false;
        }
        if (!this.f2817I) {
            boolean zOnHoverEvent = super.onHoverEvent(motionEvent);
            if (actionMasked == 9 && !zOnHoverEvent) {
                this.f2817I = true;
            }
        }
        if (actionMasked != 10 && actionMasked != 3) {
            return true;
        }
        this.f2817I = false;
        return true;
    }

    /* JADX WARN: Removed duplicated region for block: B:105:0x0295 A[LOOP:0: B:104:0x0293->B:105:0x0295, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:108:0x02ad A[LOOP:1: B:107:0x02ab->B:108:0x02ad, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:111:0x02cd A[LOOP:2: B:110:0x02cb->B:111:0x02cd, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:115:0x0313  */
    /* JADX WARN: Removed duplicated region for block: B:120:0x0321 A[LOOP:3: B:119:0x031f->B:120:0x0321, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:19:0x0062  */
    /* JADX WARN: Removed duplicated region for block: B:24:0x0079  */
    /* JADX WARN: Removed duplicated region for block: B:29:0x00b6  */
    /* JADX WARN: Removed duplicated region for block: B:34:0x00cd  */
    /* JADX WARN: Removed duplicated region for block: B:39:0x00ea  */
    /* JADX WARN: Removed duplicated region for block: B:40:0x0101  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x0106  */
    /* JADX WARN: Removed duplicated region for block: B:43:0x011f  */
    /* JADX WARN: Removed duplicated region for block: B:48:0x012a  */
    /* JADX WARN: Removed duplicated region for block: B:49:0x012c  */
    /* JADX WARN: Removed duplicated region for block: B:50:0x012f  */
    /* JADX WARN: Removed duplicated region for block: B:52:0x0133  */
    /* JADX WARN: Removed duplicated region for block: B:53:0x0136  */
    /* JADX WARN: Removed duplicated region for block: B:65:0x0169  */
    /* JADX WARN: Removed duplicated region for block: B:75:0x01a2  */
    /* JADX WARN: Removed duplicated region for block: B:77:0x01af  */
    /* JADX WARN: Removed duplicated region for block: B:89:0x021c  */
    @Override // android.view.ViewGroup, android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void onLayout(boolean r20, int r21, int r22, int r23, int r24) {
        /*
            Method dump skipped, instruction units count: 818
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.appcompat.widget.Toolbar.onLayout(boolean, int, int, int, int):void");
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        int iJ;
        int iMax;
        int iCombineMeasuredStates;
        int iJ2;
        int iK;
        int iCombineMeasuredStates2;
        int iMax2;
        boolean zA = v0.a(this);
        int i6 = !zA ? 1 : 0;
        int i7 = 0;
        if (q(this.f2828d)) {
            p(this.f2828d, i4, 0, i5, this.f2838u);
            iJ = j(this.f2828d) + this.f2828d.getMeasuredWidth();
            iMax = Math.max(0, k(this.f2828d) + this.f2828d.getMeasuredHeight());
            iCombineMeasuredStates = View.combineMeasuredStates(0, this.f2828d.getMeasuredState());
        } else {
            iJ = 0;
            iMax = 0;
            iCombineMeasuredStates = 0;
        }
        if (q(this.f2831n)) {
            p(this.f2831n, i4, 0, i5, this.f2838u);
            iJ = j(this.f2831n) + this.f2831n.getMeasuredWidth();
            iMax = Math.max(iMax, k(this.f2831n) + this.f2831n.getMeasuredHeight());
            iCombineMeasuredStates = View.combineMeasuredStates(iCombineMeasuredStates, this.f2831n.getMeasuredState());
        }
        int currentContentInsetStart = getCurrentContentInsetStart();
        int iMax3 = Math.max(currentContentInsetStart, iJ);
        int iMax4 = Math.max(0, currentContentInsetStart - iJ);
        int[] iArr = this.f2819L;
        iArr[zA ? 1 : 0] = iMax4;
        if (q(this.f2825a)) {
            p(this.f2825a, i4, iMax3, i5, this.f2838u);
            iJ2 = j(this.f2825a) + this.f2825a.getMeasuredWidth();
            iMax = Math.max(iMax, k(this.f2825a) + this.f2825a.getMeasuredHeight());
            iCombineMeasuredStates = View.combineMeasuredStates(iCombineMeasuredStates, this.f2825a.getMeasuredState());
        } else {
            iJ2 = 0;
        }
        int currentContentInsetEnd = getCurrentContentInsetEnd();
        int iMax5 = iMax3 + Math.max(currentContentInsetEnd, iJ2);
        iArr[i6] = Math.max(0, currentContentInsetEnd - iJ2);
        if (q(this.f2832o)) {
            iMax5 += o(this.f2832o, i4, iMax5, i5, 0, iArr);
            iMax = Math.max(iMax, k(this.f2832o) + this.f2832o.getMeasuredHeight());
            iCombineMeasuredStates = View.combineMeasuredStates(iCombineMeasuredStates, this.f2832o.getMeasuredState());
        }
        if (q(this.e)) {
            iMax5 += o(this.e, i4, iMax5, i5, 0, iArr);
            iMax = Math.max(iMax, k(this.e) + this.e.getMeasuredHeight());
            iCombineMeasuredStates = View.combineMeasuredStates(iCombineMeasuredStates, this.e.getMeasuredState());
        }
        int childCount = getChildCount();
        for (int i8 = 0; i8 < childCount; i8++) {
            View childAt = getChildAt(i8);
            if (((m0) childAt.getLayoutParams()).f5412b == 0 && q(childAt)) {
                iMax5 += o(childAt, i4, iMax5, i5, 0, iArr);
                int iMax6 = Math.max(iMax, k(childAt) + childAt.getMeasuredHeight());
                iCombineMeasuredStates = View.combineMeasuredStates(iCombineMeasuredStates, childAt.getMeasuredState());
                iMax = iMax6;
            } else {
                iMax5 = iMax5;
            }
        }
        int i9 = iMax5;
        int i10 = this.f2840x + this.f2841y;
        int i11 = this.v + this.f2839w;
        if (q(this.f2826b)) {
            o(this.f2826b, i4, i9 + i11, i5, i10, iArr);
            int iJ3 = j(this.f2826b) + this.f2826b.getMeasuredWidth();
            iK = k(this.f2826b) + this.f2826b.getMeasuredHeight();
            iCombineMeasuredStates2 = View.combineMeasuredStates(iCombineMeasuredStates, this.f2826b.getMeasuredState());
            iMax2 = iJ3;
        } else {
            iK = 0;
            iCombineMeasuredStates2 = iCombineMeasuredStates;
            iMax2 = 0;
        }
        if (q(this.f2827c)) {
            iMax2 = Math.max(iMax2, o(this.f2827c, i4, i9 + i11, i5, i10 + iK, iArr));
            iK += k(this.f2827c) + this.f2827c.getMeasuredHeight();
            iCombineMeasuredStates2 = View.combineMeasuredStates(iCombineMeasuredStates2, this.f2827c.getMeasuredState());
        }
        int iMax7 = Math.max(iMax, iK);
        int paddingRight = getPaddingRight() + getPaddingLeft() + i9 + iMax2;
        int paddingBottom = getPaddingBottom() + getPaddingTop() + iMax7;
        int iResolveSizeAndState = View.resolveSizeAndState(Math.max(paddingRight, getSuggestedMinimumWidth()), i4, (-16777216) & iCombineMeasuredStates2);
        int iResolveSizeAndState2 = View.resolveSizeAndState(Math.max(paddingBottom, getSuggestedMinimumHeight()), i5, iCombineMeasuredStates2 << 16);
        if (!this.f2823P) {
            i7 = iResolveSizeAndState2;
            break;
        }
        int childCount2 = getChildCount();
        for (int i12 = 0; i12 < childCount2; i12++) {
            View childAt2 = getChildAt(i12);
            if (q(childAt2) && childAt2.getMeasuredWidth() > 0 && childAt2.getMeasuredHeight() > 0) {
                i7 = iResolveSizeAndState2;
                break;
            }
        }
        setMeasuredDimension(iResolveSizeAndState, i7);
    }

    @Override // android.view.View
    public final void onRestoreInstanceState(Parcelable parcelable) {
        MenuItem menuItemFindItem;
        if (!(parcelable instanceof o0)) {
            super.onRestoreInstanceState(parcelable);
            return;
        }
        o0 o0Var = (o0) parcelable;
        super.onRestoreInstanceState(o0Var.f507a);
        ActionMenuView actionMenuView = this.f2825a;
        j jVar = actionMenuView != null ? actionMenuView.v : null;
        int i4 = o0Var.f5421c;
        if (i4 != 0 && this.f2822O != null && jVar != null && (menuItemFindItem = jVar.findItem(i4)) != null) {
            menuItemFindItem.expandActionView();
        }
        if (o0Var.f5422d) {
            F.b bVar = this.f2824Q;
            removeCallbacks(bVar);
            post(bVar);
        }
    }

    @Override // android.view.View
    public final void onRtlPropertiesChanged(int i4) {
        super.onRtlPropertiesChanged(i4);
        d();
        Q q4 = this.f2842z;
        boolean z4 = i4 == 1;
        if (z4 == q4.f5328g) {
            return;
        }
        q4.f5328g = z4;
        if (!q4.f5329h) {
            q4.f5323a = q4.e;
            q4.f5324b = q4.f5327f;
            return;
        }
        if (z4) {
            int i5 = q4.f5326d;
            if (i5 == Integer.MIN_VALUE) {
                i5 = q4.e;
            }
            q4.f5323a = i5;
            int i6 = q4.f5325c;
            if (i6 == Integer.MIN_VALUE) {
                i6 = q4.f5327f;
            }
            q4.f5324b = i6;
            return;
        }
        int i7 = q4.f5325c;
        if (i7 == Integer.MIN_VALUE) {
            i7 = q4.e;
        }
        q4.f5323a = i7;
        int i8 = q4.f5326d;
        if (i8 == Integer.MIN_VALUE) {
            i8 = q4.f5327f;
        }
        q4.f5324b = i8;
    }

    @Override // android.view.View
    public final Parcelable onSaveInstanceState() {
        C0492i c0492i;
        C0489f c0489f;
        j.k kVar;
        o0 o0Var = new o0(super.onSaveInstanceState());
        l0 l0Var = this.f2822O;
        if (l0Var != null && (kVar = l0Var.f5406b) != null) {
            o0Var.f5421c = kVar.f5102a;
        }
        ActionMenuView actionMenuView = this.f2825a;
        o0Var.f5422d = (actionMenuView == null || (c0492i = actionMenuView.f2720y) == null || (c0489f = c0492i.f5394x) == null || !c0489f.b()) ? false : true;
        return o0Var;
    }

    @Override // android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        int actionMasked = motionEvent.getActionMasked();
        if (actionMasked == 0) {
            this.f2816H = false;
        }
        if (!this.f2816H) {
            boolean zOnTouchEvent = super.onTouchEvent(motionEvent);
            if (actionMasked == 0 && !zOnTouchEvent) {
                this.f2816H = true;
            }
        }
        if (actionMasked != 1 && actionMasked != 3) {
            return true;
        }
        this.f2816H = false;
        return true;
    }

    public final void p(View view, int i4, int i5, int i6, int i7) {
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        int childMeasureSpec = ViewGroup.getChildMeasureSpec(i4, getPaddingRight() + getPaddingLeft() + marginLayoutParams.leftMargin + marginLayoutParams.rightMargin + i5, marginLayoutParams.width);
        int childMeasureSpec2 = ViewGroup.getChildMeasureSpec(i6, getPaddingBottom() + getPaddingTop() + marginLayoutParams.topMargin + marginLayoutParams.bottomMargin, marginLayoutParams.height);
        int mode = View.MeasureSpec.getMode(childMeasureSpec2);
        if (mode != 1073741824 && i7 >= 0) {
            if (mode != 0) {
                i7 = Math.min(View.MeasureSpec.getSize(childMeasureSpec2), i7);
            }
            childMeasureSpec2 = View.MeasureSpec.makeMeasureSpec(i7, 1073741824);
        }
        view.measure(childMeasureSpec, childMeasureSpec2);
    }

    public final boolean q(View view) {
        return (view == null || view.getParent() != this || view.getVisibility() == 8) ? false : true;
    }

    public void setCollapseContentDescription(int i4) {
        setCollapseContentDescription(i4 != 0 ? getContext().getText(i4) : null);
    }

    public void setCollapseIcon(int i4) {
        setCollapseIcon(AbstractC0404a.a(getContext(), i4));
    }

    public void setCollapsible(boolean z4) {
        this.f2823P = z4;
        requestLayout();
    }

    public void setContentInsetEndWithActions(int i4) {
        if (i4 < 0) {
            i4 = Integer.MIN_VALUE;
        }
        if (i4 != this.f2810B) {
            this.f2810B = i4;
            if (getNavigationIcon() != null) {
                requestLayout();
            }
        }
    }

    public void setContentInsetStartWithNavigation(int i4) {
        if (i4 < 0) {
            i4 = Integer.MIN_VALUE;
        }
        if (i4 != this.f2809A) {
            this.f2809A = i4;
            if (getNavigationIcon() != null) {
                requestLayout();
            }
        }
    }

    public void setLogo(int i4) {
        setLogo(AbstractC0404a.a(getContext(), i4));
    }

    public void setLogoDescription(int i4) {
        setLogoDescription(getContext().getText(i4));
    }

    public void setNavigationContentDescription(int i4) {
        setNavigationContentDescription(i4 != 0 ? getContext().getText(i4) : null);
    }

    public void setNavigationIcon(int i4) {
        setNavigationIcon(AbstractC0404a.a(getContext(), i4));
    }

    public void setNavigationOnClickListener(View.OnClickListener onClickListener) {
        f();
        this.f2828d.setOnClickListener(onClickListener);
    }

    public void setOverflowIcon(Drawable drawable) {
        e();
        this.f2825a.setOverflowIcon(drawable);
    }

    public void setPopupTheme(int i4) {
        if (this.f2834q != i4) {
            this.f2834q = i4;
            if (i4 == 0) {
                this.f2833p = getContext();
            } else {
                this.f2833p = new ContextThemeWrapper(getContext(), i4);
            }
        }
    }

    public void setSubtitle(int i4) {
        setSubtitle(getContext().getText(i4));
    }

    public void setSubtitleTextColor(int i4) {
        setSubtitleTextColor(ColorStateList.valueOf(i4));
    }

    public void setTitle(int i4) {
        setTitle(getContext().getText(i4));
    }

    public void setTitleMarginBottom(int i4) {
        this.f2841y = i4;
        requestLayout();
    }

    public void setTitleMarginEnd(int i4) {
        this.f2839w = i4;
        requestLayout();
    }

    public void setTitleMarginStart(int i4) {
        this.v = i4;
        requestLayout();
    }

    public void setTitleMarginTop(int i4) {
        this.f2840x = i4;
        requestLayout();
    }

    public void setTitleTextColor(int i4) {
        setTitleTextColor(ColorStateList.valueOf(i4));
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(AttributeSet attributeSet) {
        Context context = getContext();
        m0 m0Var = new m0(context, attributeSet);
        m0Var.f5411a = 0;
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.f4245b);
        m0Var.f5411a = typedArrayObtainStyledAttributes.getInt(0, 0);
        typedArrayObtainStyledAttributes.recycle();
        m0Var.f5412b = 0;
        return m0Var;
    }

    public void setCollapseContentDescription(CharSequence charSequence) {
        if (!TextUtils.isEmpty(charSequence)) {
            c();
        }
        C0499p c0499p = this.f2831n;
        if (c0499p != null) {
            c0499p.setContentDescription(charSequence);
        }
    }

    public void setCollapseIcon(Drawable drawable) {
        if (drawable != null) {
            c();
            this.f2831n.setImageDrawable(drawable);
        } else {
            C0499p c0499p = this.f2831n;
            if (c0499p != null) {
                c0499p.setImageDrawable(this.f2829f);
            }
        }
    }

    public void setLogo(Drawable drawable) {
        if (drawable != null) {
            if (this.e == null) {
                this.e = new C0500q(getContext(), 0);
            }
            if (!l(this.e)) {
                b(this.e, true);
            }
        } else {
            C0500q c0500q = this.e;
            if (c0500q != null && l(c0500q)) {
                removeView(this.e);
                this.f2818K.remove(this.e);
            }
        }
        C0500q c0500q2 = this.e;
        if (c0500q2 != null) {
            c0500q2.setImageDrawable(drawable);
        }
    }

    public void setLogoDescription(CharSequence charSequence) {
        if (!TextUtils.isEmpty(charSequence) && this.e == null) {
            this.e = new C0500q(getContext(), 0);
        }
        C0500q c0500q = this.e;
        if (c0500q != null) {
            c0500q.setContentDescription(charSequence);
        }
    }

    public void setNavigationContentDescription(CharSequence charSequence) {
        if (!TextUtils.isEmpty(charSequence)) {
            f();
        }
        C0499p c0499p = this.f2828d;
        if (c0499p != null) {
            c0499p.setContentDescription(charSequence);
        }
    }

    public void setNavigationIcon(Drawable drawable) {
        if (drawable != null) {
            f();
            if (!l(this.f2828d)) {
                b(this.f2828d, true);
            }
        } else {
            C0499p c0499p = this.f2828d;
            if (c0499p != null && l(c0499p)) {
                removeView(this.f2828d);
                this.f2818K.remove(this.f2828d);
            }
        }
        C0499p c0499p2 = this.f2828d;
        if (c0499p2 != null) {
            c0499p2.setImageDrawable(drawable);
        }
    }

    public void setSubtitle(CharSequence charSequence) {
        if (TextUtils.isEmpty(charSequence)) {
            C0504v c0504v = this.f2827c;
            if (c0504v != null && l(c0504v)) {
                removeView(this.f2827c);
                this.f2818K.remove(this.f2827c);
            }
        } else {
            if (this.f2827c == null) {
                Context context = getContext();
                C0504v c0504v2 = new C0504v(context, null);
                this.f2827c = c0504v2;
                c0504v2.setSingleLine();
                this.f2827c.setEllipsize(TextUtils.TruncateAt.END);
                int i4 = this.f2836s;
                if (i4 != 0) {
                    this.f2827c.setTextAppearance(context, i4);
                }
                ColorStateList colorStateList = this.f2815G;
                if (colorStateList != null) {
                    this.f2827c.setTextColor(colorStateList);
                }
            }
            if (!l(this.f2827c)) {
                b(this.f2827c, true);
            }
        }
        C0504v c0504v3 = this.f2827c;
        if (c0504v3 != null) {
            c0504v3.setText(charSequence);
        }
        this.f2813E = charSequence;
    }

    public void setSubtitleTextColor(ColorStateList colorStateList) {
        this.f2815G = colorStateList;
        C0504v c0504v = this.f2827c;
        if (c0504v != null) {
            c0504v.setTextColor(colorStateList);
        }
    }

    public void setTitle(CharSequence charSequence) {
        if (TextUtils.isEmpty(charSequence)) {
            C0504v c0504v = this.f2826b;
            if (c0504v != null && l(c0504v)) {
                removeView(this.f2826b);
                this.f2818K.remove(this.f2826b);
            }
        } else {
            if (this.f2826b == null) {
                Context context = getContext();
                C0504v c0504v2 = new C0504v(context, null);
                this.f2826b = c0504v2;
                c0504v2.setSingleLine();
                this.f2826b.setEllipsize(TextUtils.TruncateAt.END);
                int i4 = this.f2835r;
                if (i4 != 0) {
                    this.f2826b.setTextAppearance(context, i4);
                }
                ColorStateList colorStateList = this.f2814F;
                if (colorStateList != null) {
                    this.f2826b.setTextColor(colorStateList);
                }
            }
            if (!l(this.f2826b)) {
                b(this.f2826b, true);
            }
        }
        C0504v c0504v3 = this.f2826b;
        if (c0504v3 != null) {
            c0504v3.setText(charSequence);
        }
        this.f2812D = charSequence;
    }

    public void setTitleTextColor(ColorStateList colorStateList) {
        this.f2814F = colorStateList;
        C0504v c0504v = this.f2826b;
        if (c0504v != null) {
            c0504v.setTextColor(colorStateList);
        }
    }

    public void setOnMenuItemClickListener(n0 n0Var) {
    }
}
