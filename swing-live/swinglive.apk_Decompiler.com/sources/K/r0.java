package k;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.res.Resources;
import android.graphics.Rect;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.WindowManager;
import android.view.accessibility.AccessibilityManager;
import android.widget.TextView;
import com.swing.live.R;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

/* JADX INFO: loaded from: classes.dex */
public final class r0 implements View.OnLongClickListener, View.OnHoverListener, View.OnAttachStateChangeListener {

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static r0 f5441p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static r0 f5442q;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f5443a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final CharSequence f5444b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5445c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final q0 f5446d = new q0(this, 0);
    public final q0 e = new q0(this, 1);

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5447f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f5448m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public s0 f5449n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f5450o;

    public r0(View view, CharSequence charSequence) {
        this.f5443a = view;
        this.f5444b = charSequence;
        ViewConfiguration viewConfiguration = ViewConfiguration.get(view.getContext());
        Method method = A.G.f6a;
        this.f5445c = Build.VERSION.SDK_INT >= 28 ? A.E.a(viewConfiguration) : viewConfiguration.getScaledTouchSlop() / 2;
        this.f5447f = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
        this.f5448m = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
        view.setOnLongClickListener(this);
        view.setOnHoverListener(this);
    }

    public static void b(r0 r0Var) {
        r0 r0Var2 = f5441p;
        if (r0Var2 != null) {
            r0Var2.f5443a.removeCallbacks(r0Var2.f5446d);
        }
        f5441p = r0Var;
        if (r0Var != null) {
            r0Var.f5443a.postDelayed(r0Var.f5446d, ViewConfiguration.getLongPressTimeout());
        }
    }

    public final void a() {
        r0 r0Var = f5442q;
        View view = this.f5443a;
        if (r0Var == this) {
            f5442q = null;
            s0 s0Var = this.f5449n;
            if (s0Var != null) {
                View view2 = (View) s0Var.f5452b;
                if (view2.getParent() != null) {
                    ((WindowManager) ((Context) s0Var.f5451a).getSystemService("window")).removeView(view2);
                }
                this.f5449n = null;
                this.f5447f = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                this.f5448m = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                view.removeOnAttachStateChangeListener(this);
            } else {
                Log.e("TooltipCompatHandler", "sActiveHandler.mPopup == null");
            }
        }
        if (f5441p == this) {
            b(null);
        }
        view.removeCallbacks(this.e);
    }

    public final void c(boolean z4) {
        int height;
        int i4;
        int i5;
        int i6;
        int i7;
        int i8;
        long longPressTimeout;
        long j4;
        long j5;
        Field field = A.C.f4a;
        View view = this.f5443a;
        if (view.isAttachedToWindow()) {
            b(null);
            r0 r0Var = f5442q;
            if (r0Var != null) {
                r0Var.a();
            }
            f5442q = this;
            this.f5450o = z4;
            Context context = view.getContext();
            s0 s0Var = new s0();
            WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
            s0Var.f5454d = layoutParams;
            s0Var.e = new Rect();
            s0Var.f5455f = new int[2];
            s0Var.f5456g = new int[2];
            s0Var.f5451a = context;
            View viewInflate = LayoutInflater.from(context).inflate(R.layout.abc_tooltip, (ViewGroup) null);
            s0Var.f5452b = viewInflate;
            s0Var.f5453c = (TextView) viewInflate.findViewById(R.id.message);
            layoutParams.setTitle(s0.class.getSimpleName());
            layoutParams.packageName = context.getPackageName();
            layoutParams.type = 1002;
            layoutParams.width = -2;
            layoutParams.height = -2;
            layoutParams.format = -3;
            layoutParams.windowAnimations = R.style.Animation_AppCompat_Tooltip;
            layoutParams.flags = 24;
            this.f5449n = s0Var;
            int width = this.f5447f;
            int i9 = this.f5448m;
            boolean z5 = this.f5450o;
            View view2 = (View) s0Var.f5452b;
            ViewParent parent = view2.getParent();
            Context context2 = (Context) s0Var.f5451a;
            if (parent != null && view2.getParent() != null) {
                ((WindowManager) context2.getSystemService("window")).removeView(view2);
            }
            ((TextView) s0Var.f5453c).setText(this.f5444b);
            WindowManager.LayoutParams layoutParams2 = (WindowManager.LayoutParams) s0Var.f5454d;
            layoutParams2.token = view.getApplicationWindowToken();
            int dimensionPixelOffset = context2.getResources().getDimensionPixelOffset(R.dimen.tooltip_precise_anchor_threshold);
            if (view.getWidth() < dimensionPixelOffset) {
                width = view.getWidth() / 2;
            }
            if (view.getHeight() >= dimensionPixelOffset) {
                int dimensionPixelOffset2 = context2.getResources().getDimensionPixelOffset(R.dimen.tooltip_precise_anchor_extra_offset);
                height = i9 + dimensionPixelOffset2;
                i4 = i9 - dimensionPixelOffset2;
            } else {
                height = view.getHeight();
                i4 = 0;
            }
            layoutParams2.gravity = 49;
            int dimensionPixelOffset3 = context2.getResources().getDimensionPixelOffset(z5 ? R.dimen.tooltip_y_offset_touch : R.dimen.tooltip_y_offset_non_touch);
            View rootView = view.getRootView();
            ViewGroup.LayoutParams layoutParams3 = rootView.getLayoutParams();
            if (!(layoutParams3 instanceof WindowManager.LayoutParams) || ((WindowManager.LayoutParams) layoutParams3).type != 2) {
                Context context3 = view.getContext();
                while (true) {
                    if (!(context3 instanceof ContextWrapper)) {
                        break;
                    }
                    if (context3 instanceof Activity) {
                        rootView = ((Activity) context3).getWindow().getDecorView();
                        break;
                    }
                    context3 = ((ContextWrapper) context3).getBaseContext();
                }
            }
            if (rootView == null) {
                Log.e("TooltipPopup", "Cannot find app view");
                i8 = 1;
            } else {
                Rect rect = (Rect) s0Var.e;
                rootView.getWindowVisibleDisplayFrame(rect);
                if (rect.left >= 0 || rect.top >= 0) {
                    i5 = width;
                    i6 = i4;
                    i7 = 0;
                    i8 = 1;
                } else {
                    Resources resources = context2.getResources();
                    i8 = 1;
                    i5 = width;
                    i6 = i4;
                    int identifier = resources.getIdentifier("status_bar_height", "dimen", "android");
                    int dimensionPixelSize = identifier != 0 ? resources.getDimensionPixelSize(identifier) : 0;
                    DisplayMetrics displayMetrics = resources.getDisplayMetrics();
                    i7 = 0;
                    rect.set(0, dimensionPixelSize, displayMetrics.widthPixels, displayMetrics.heightPixels);
                }
                int[] iArr = (int[]) s0Var.f5456g;
                rootView.getLocationOnScreen(iArr);
                int[] iArr2 = (int[]) s0Var.f5455f;
                view.getLocationOnScreen(iArr2);
                int i10 = iArr2[i7] - iArr[i7];
                iArr2[i7] = i10;
                iArr2[i8] = iArr2[i8] - iArr[i8];
                layoutParams2.x = (i10 + i5) - (rootView.getWidth() / 2);
                int iMakeMeasureSpec = View.MeasureSpec.makeMeasureSpec(i7, i7);
                view2.measure(iMakeMeasureSpec, iMakeMeasureSpec);
                int measuredHeight = view2.getMeasuredHeight();
                int i11 = iArr2[i8];
                int i12 = ((i11 + i6) - dimensionPixelOffset3) - measuredHeight;
                int i13 = i11 + height + dimensionPixelOffset3;
                if (z5) {
                    if (i12 >= 0) {
                        layoutParams2.y = i12;
                    } else {
                        layoutParams2.y = i13;
                    }
                } else if (measuredHeight + i13 <= rect.height()) {
                    layoutParams2.y = i13;
                } else {
                    layoutParams2.y = i12;
                }
            }
            ((WindowManager) context2.getSystemService("window")).addView(view2, layoutParams2);
            view.addOnAttachStateChangeListener(this);
            if (this.f5450o) {
                j5 = 2500;
            } else {
                if ((view.getWindowSystemUiVisibility() & 1) == i8) {
                    longPressTimeout = ViewConfiguration.getLongPressTimeout();
                    j4 = 3000;
                } else {
                    longPressTimeout = ViewConfiguration.getLongPressTimeout();
                    j4 = 15000;
                }
                j5 = j4 - longPressTimeout;
            }
            q0 q0Var = this.e;
            view.removeCallbacks(q0Var);
            view.postDelayed(q0Var, j5);
        }
    }

    @Override // android.view.View.OnHoverListener
    public final boolean onHover(View view, MotionEvent motionEvent) {
        if (this.f5449n == null || !this.f5450o) {
            View view2 = this.f5443a;
            AccessibilityManager accessibilityManager = (AccessibilityManager) view2.getContext().getSystemService("accessibility");
            if (!accessibilityManager.isEnabled() || !accessibilityManager.isTouchExplorationEnabled()) {
                int action = motionEvent.getAction();
                if (action != 7) {
                    if (action == 10) {
                        this.f5447f = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                        this.f5448m = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                        a();
                        return false;
                    }
                } else if (view2.isEnabled() && this.f5449n == null) {
                    int x4 = (int) motionEvent.getX();
                    int y4 = (int) motionEvent.getY();
                    int iAbs = Math.abs(x4 - this.f5447f);
                    int i4 = this.f5445c;
                    if (iAbs > i4 || Math.abs(y4 - this.f5448m) > i4) {
                        this.f5447f = x4;
                        this.f5448m = y4;
                        b(this);
                    }
                }
            }
        }
        return false;
    }

    @Override // android.view.View.OnLongClickListener
    public final boolean onLongClick(View view) {
        this.f5447f = view.getWidth() / 2;
        this.f5448m = view.getHeight() / 2;
        c(true);
        return true;
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewDetachedFromWindow(View view) {
        a();
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewAttachedToWindow(View view) {
    }
}
