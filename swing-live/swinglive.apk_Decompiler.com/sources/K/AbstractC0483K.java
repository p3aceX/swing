package k;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;
import f.AbstractC0398a;
import g.AbstractC0404a;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

/* JADX INFO: renamed from: k.K, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0483K implements j.r {

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public static final Method f5289C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public static final Method f5290D;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public boolean f5291A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final r f5292B;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5293a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ListAdapter f5294b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public M f5295c;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5297f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f5298m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f5299n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f5300o;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public G.a f5302q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public View f5303r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public j.l f5304s;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final Handler f5308x;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public Rect f5310z;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5296d = -2;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f5301p = 0;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final RunnableC0480H f5305t = new RunnableC0480H(this, 1);

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final ViewOnTouchListenerC0482J f5306u = new ViewOnTouchListenerC0482J(this);
    public final C0481I v = new C0481I(this);

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final RunnableC0480H f5307w = new RunnableC0480H(this, 0);

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final Rect f5309y = new Rect();

    static {
        if (Build.VERSION.SDK_INT <= 28) {
            try {
                f5289C = PopupWindow.class.getDeclaredMethod("setClipToScreenEnabled", Boolean.TYPE);
            } catch (NoSuchMethodException unused) {
                Log.i("ListPopupWindow", "Could not find method setClipToScreenEnabled() on PopupWindow. Oh well.");
            }
            try {
                f5290D = PopupWindow.class.getDeclaredMethod("setEpicenterBounds", Rect.class);
            } catch (NoSuchMethodException unused2) {
                Log.i("ListPopupWindow", "Could not find method setEpicenterBounds(Rect) on PopupWindow. Oh well.");
            }
        }
    }

    public AbstractC0483K(Context context, int i4) {
        int resourceId;
        this.f5293a = context;
        this.f5308x = new Handler(context.getMainLooper());
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(null, AbstractC0398a.f4253k, i4, 0);
        this.e = typedArrayObtainStyledAttributes.getDimensionPixelOffset(0, 0);
        int dimensionPixelOffset = typedArrayObtainStyledAttributes.getDimensionPixelOffset(1, 0);
        this.f5297f = dimensionPixelOffset;
        if (dimensionPixelOffset != 0) {
            this.f5298m = true;
        }
        typedArrayObtainStyledAttributes.recycle();
        r rVar = new r(context, null, i4, 0);
        TypedArray typedArrayObtainStyledAttributes2 = context.obtainStyledAttributes(null, AbstractC0398a.f4257o, i4, 0);
        if (typedArrayObtainStyledAttributes2.hasValue(2)) {
            F.l.c(rVar, typedArrayObtainStyledAttributes2.getBoolean(2, false));
        }
        rVar.setBackgroundDrawable((!typedArrayObtainStyledAttributes2.hasValue(0) || (resourceId = typedArrayObtainStyledAttributes2.getResourceId(0, 0)) == 0) ? typedArrayObtainStyledAttributes2.getDrawable(0) : AbstractC0404a.a(context, resourceId));
        typedArrayObtainStyledAttributes2.recycle();
        this.f5292B = rVar;
        rVar.setInputMethodMode(1);
    }

    @Override // j.r
    public final void b() {
        int i4;
        M m4;
        M m5 = this.f5295c;
        r rVar = this.f5292B;
        Context context = this.f5293a;
        if (m5 == null) {
            M m6 = new M(context, !this.f5291A);
            m6.setHoverListener((N) this);
            this.f5295c = m6;
            m6.setAdapter(this.f5294b);
            this.f5295c.setOnItemClickListener(this.f5304s);
            this.f5295c.setFocusable(true);
            this.f5295c.setFocusableInTouchMode(true);
            this.f5295c.setOnItemSelectedListener(new C0479G(this, i));
            this.f5295c.setOnScrollListener(this.v);
            rVar.setContentView(this.f5295c);
        }
        Drawable background = rVar.getBackground();
        Rect rect = this.f5309y;
        if (background != null) {
            background.getPadding(rect);
            int i5 = rect.top;
            i4 = rect.bottom + i5;
            if (!this.f5298m) {
                this.f5297f = -i5;
            }
        } else {
            rect.setEmpty();
            i4 = 0;
        }
        int maxAvailableHeight = rVar.getMaxAvailableHeight(this.f5303r, this.f5297f, rVar.getInputMethodMode() == 2);
        int i6 = this.f5296d;
        int iA = this.f5295c.a(i6 != -2 ? i6 != -1 ? View.MeasureSpec.makeMeasureSpec(i6, 1073741824) : View.MeasureSpec.makeMeasureSpec(context.getResources().getDisplayMetrics().widthPixels - (rect.left + rect.right), 1073741824) : View.MeasureSpec.makeMeasureSpec(context.getResources().getDisplayMetrics().widthPixels - (rect.left + rect.right), Integer.MIN_VALUE), maxAvailableHeight);
        int paddingBottom = iA + (iA > 0 ? this.f5295c.getPaddingBottom() + this.f5295c.getPaddingTop() + i4 : 0);
        this.f5292B.getInputMethodMode();
        F.l.d(rVar, 1002);
        if (rVar.isShowing()) {
            View view = this.f5303r;
            Field field = A.C.f4a;
            if (view.isAttachedToWindow()) {
                int width = this.f5296d;
                if (width == -1) {
                    width = -1;
                } else if (width == -2) {
                    width = this.f5303r.getWidth();
                }
                rVar.setOutsideTouchable(true);
                rVar.update(this.f5303r, this.e, this.f5297f, width < 0 ? -1 : width, paddingBottom < 0 ? -1 : paddingBottom);
                return;
            }
            return;
        }
        int width2 = this.f5296d;
        if (width2 == -1) {
            width2 = -1;
        } else if (width2 == -2) {
            width2 = this.f5303r.getWidth();
        }
        rVar.setWidth(width2);
        rVar.setHeight(paddingBottom);
        if (Build.VERSION.SDK_INT <= 28) {
            Method method = f5289C;
            if (method != null) {
                try {
                    method.invoke(rVar, Boolean.TRUE);
                } catch (Exception unused) {
                    Log.i("ListPopupWindow", "Could not call setClipToScreenEnabled() on PopupWindow. Oh well.");
                }
            }
        } else {
            rVar.setIsClippedToScreen(true);
        }
        rVar.setOutsideTouchable(true);
        rVar.setTouchInterceptor(this.f5306u);
        if (this.f5300o) {
            F.l.c(rVar, this.f5299n);
        }
        if (Build.VERSION.SDK_INT <= 28) {
            Method method2 = f5290D;
            if (method2 != null) {
                try {
                    method2.invoke(rVar, this.f5310z);
                } catch (Exception e) {
                    Log.e("ListPopupWindow", "Could not invoke setEpicenterBounds on PopupWindow", e);
                }
            }
        } else {
            rVar.setEpicenterBounds(this.f5310z);
        }
        rVar.showAsDropDown(this.f5303r, this.e, this.f5297f, this.f5301p);
        this.f5295c.setSelection(-1);
        if ((!this.f5291A || this.f5295c.isInTouchMode()) && (m4 = this.f5295c) != null) {
            m4.setListSelectionHidden(true);
            m4.requestLayout();
        }
        if (this.f5291A) {
            return;
        }
        this.f5308x.post(this.f5307w);
    }

    public final void c(ListAdapter listAdapter) {
        G.a aVar = this.f5302q;
        if (aVar == null) {
            this.f5302q = new G.a(this, 1);
        } else {
            ListAdapter listAdapter2 = this.f5294b;
            if (listAdapter2 != null) {
                listAdapter2.unregisterDataSetObserver(aVar);
            }
        }
        this.f5294b = listAdapter;
        if (listAdapter != null) {
            listAdapter.registerDataSetObserver(this.f5302q);
        }
        M m4 = this.f5295c;
        if (m4 != null) {
            m4.setAdapter(this.f5294b);
        }
    }

    @Override // j.r
    public final void dismiss() {
        r rVar = this.f5292B;
        rVar.dismiss();
        rVar.setContentView(null);
        this.f5295c = null;
        this.f5308x.removeCallbacks(this.f5305t);
    }

    @Override // j.r
    public final boolean g() {
        return this.f5292B.isShowing();
    }

    @Override // j.r
    public final ListView h() {
        return this.f5295c;
    }
}
