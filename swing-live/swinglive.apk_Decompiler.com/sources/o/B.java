package O;

import android.animation.LayoutTransition;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowInsets;
import android.widget.FrameLayout;
import com.swing.live.R;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class B extends FrameLayout {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f1202a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f1203b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public View.OnApplyWindowInsetsListener f1204c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f1205d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public B(Context context, AttributeSet attributeSet, N n4) {
        super(context, attributeSet);
        J3.i.e(context, "context");
        J3.i.e(attributeSet, "attrs");
        J3.i.e(n4, "fm");
        this.f1202a = new ArrayList();
        this.f1203b = new ArrayList();
        this.f1205d = true;
        String classAttribute = attributeSet.getClassAttribute();
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, N.a.f1104b, 0, 0);
        classAttribute = classAttribute == null ? typedArrayObtainStyledAttributes.getString(0) : classAttribute;
        String string = typedArrayObtainStyledAttributes.getString(1);
        typedArrayObtainStyledAttributes.recycle();
        int id = getId();
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uB = n4.B(id);
        if (classAttribute != null && abstractComponentCallbacksC0109uB == null) {
            if (id == -1) {
                throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.g("FragmentContainerView must have an android:id to add Fragment ", classAttribute, string != null ? " with tag ".concat(string) : ""));
            }
            G G4 = n4.G();
            context.getClassLoader();
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uA = G4.a(classAttribute);
            J3.i.d(abstractComponentCallbacksC0109uA, "fm.fragmentFactory.insta…ontext.classLoader, name)");
            abstractComponentCallbacksC0109uA.f1388C = id;
            abstractComponentCallbacksC0109uA.f1389D = id;
            abstractComponentCallbacksC0109uA.f1390E = string;
            abstractComponentCallbacksC0109uA.f1424y = n4;
            C0113y c0113y = n4.v;
            abstractComponentCallbacksC0109uA.f1425z = c0113y;
            abstractComponentCallbacksC0109uA.J = true;
            if ((c0113y == null ? null : c0113y.f1432b) != null) {
                abstractComponentCallbacksC0109uA.J = true;
            }
            C0090a c0090a = new C0090a(n4);
            c0090a.f1317o = true;
            abstractComponentCallbacksC0109uA.f1395K = this;
            c0090a.e(getId(), abstractComponentCallbacksC0109uA, string);
            if (c0090a.f1309g) {
                throw new IllegalStateException("This transaction is already being added to the back stack");
            }
            N n5 = c0090a.f1318p;
            if (n5.v != null && !n5.f1231I) {
                n5.y(true);
                c0090a.a(n5.f1232K, n5.f1233L);
                n5.f1238b = true;
                try {
                    n5.T(n5.f1232K, n5.f1233L);
                    n5.d();
                    n5.e0();
                    if (n5.J) {
                        n5.J = false;
                        n5.c0();
                    }
                    ((HashMap) n5.f1239c.f707c).values().removeAll(Collections.singleton(null));
                } catch (Throwable th) {
                    n5.d();
                    throw th;
                }
            }
        }
        Iterator it = n4.f1239c.j().iterator();
        while (it.hasNext()) {
            int i4 = ((U) it.next()).f1289c.f1389D;
            getId();
        }
    }

    public final void a(View view) {
        if (this.f1203b.contains(view)) {
            this.f1202a.add(view);
        }
    }

    @Override // android.view.ViewGroup
    public final void addView(View view, int i4, ViewGroup.LayoutParams layoutParams) {
        J3.i.e(view, "child");
        Object tag = view.getTag(R.id.fragment_container_view_tag);
        if ((tag instanceof AbstractComponentCallbacksC0109u ? (AbstractComponentCallbacksC0109u) tag : null) != null) {
            super.addView(view, i4, layoutParams);
            return;
        }
        throw new IllegalStateException(("Views added to a FragmentContainerView must be associated with a Fragment. View " + view + " is not associated with a Fragment.").toString());
    }

    @Override // android.view.ViewGroup, android.view.View
    public final WindowInsets dispatchApplyWindowInsets(WindowInsets windowInsets) {
        J3.i.e(windowInsets, "insets");
        A.X xA = A.X.a(windowInsets, null);
        View.OnApplyWindowInsetsListener onApplyWindowInsetsListener = this.f1204c;
        if (onApplyWindowInsetsListener != null) {
            WindowInsets windowInsetsOnApplyWindowInsets = onApplyWindowInsetsListener.onApplyWindowInsets(this, windowInsets);
            J3.i.d(windowInsetsOnApplyWindowInsets, "onApplyWindowInsetsListe…lyWindowInsets(v, insets)");
            xA = A.X.a(windowInsetsOnApplyWindowInsets, null);
        } else {
            Field field = A.C.f4a;
            A.V v = xA.f33a;
            WindowInsets windowInsets2 = v instanceof A.O ? ((A.O) v).f22c : null;
            if (windowInsets2 != null) {
                WindowInsets windowInsetsB = A.r.b(this, windowInsets2);
                if (!windowInsetsB.equals(windowInsets2)) {
                    xA = A.X.a(windowInsetsB, this);
                }
            }
        }
        A.V v4 = xA.f33a;
        if (!v4.k()) {
            int childCount = getChildCount();
            for (int i4 = 0; i4 < childCount; i4++) {
                View childAt = getChildAt(i4);
                Field field2 = A.C.f4a;
                WindowInsets windowInsets3 = v4 instanceof A.O ? ((A.O) v4).f22c : null;
                if (windowInsets3 != null) {
                    WindowInsets windowInsetsA = A.r.a(childAt, windowInsets3);
                    if (!windowInsetsA.equals(windowInsets3)) {
                        A.X.a(windowInsetsA, childAt);
                    }
                }
            }
        }
        return windowInsets;
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void dispatchDraw(Canvas canvas) {
        J3.i.e(canvas, "canvas");
        if (this.f1205d) {
            Iterator it = this.f1202a.iterator();
            while (it.hasNext()) {
                super.drawChild(canvas, (View) it.next(), getDrawingTime());
            }
        }
        super.dispatchDraw(canvas);
    }

    @Override // android.view.ViewGroup
    public final boolean drawChild(Canvas canvas, View view, long j4) {
        J3.i.e(canvas, "canvas");
        J3.i.e(view, "child");
        if (this.f1205d) {
            ArrayList arrayList = this.f1202a;
            if (!arrayList.isEmpty() && arrayList.contains(view)) {
                return false;
            }
        }
        return super.drawChild(canvas, view, j4);
    }

    @Override // android.view.ViewGroup
    public final void endViewTransition(View view) {
        J3.i.e(view, "view");
        this.f1203b.remove(view);
        if (this.f1202a.remove(view)) {
            this.f1205d = true;
        }
        super.endViewTransition(view);
    }

    public final <F extends AbstractComponentCallbacksC0109u> F getFragment() {
        AbstractActivityC0114z abstractActivityC0114z;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u;
        N nM;
        View view = this;
        while (true) {
            abstractActivityC0114z = null;
            if (view == null) {
                abstractComponentCallbacksC0109u = null;
                break;
            }
            Object tag = view.getTag(R.id.fragment_container_view_tag);
            abstractComponentCallbacksC0109u = tag instanceof AbstractComponentCallbacksC0109u ? (AbstractComponentCallbacksC0109u) tag : null;
            if (abstractComponentCallbacksC0109u != null) {
                break;
            }
            Object parent = view.getParent();
            view = parent instanceof View ? (View) parent : null;
        }
        if (abstractComponentCallbacksC0109u == null) {
            Context context = getContext();
            while (true) {
                if (!(context instanceof ContextWrapper)) {
                    break;
                }
                if (context instanceof AbstractActivityC0114z) {
                    abstractActivityC0114z = (AbstractActivityC0114z) context;
                    break;
                }
                context = ((ContextWrapper) context).getBaseContext();
            }
            if (abstractActivityC0114z == null) {
                throw new IllegalStateException("View " + this + " is not within a subclass of FragmentActivity.");
            }
            nM = ((C0113y) abstractActivityC0114z.f1438x.f104b).e;
        } else {
            if (abstractComponentCallbacksC0109u.f1425z == null || !abstractComponentCallbacksC0109u.f1417q) {
                throw new IllegalStateException("The Fragment " + abstractComponentCallbacksC0109u + " that owns View " + this + " has already been destroyed. Nested fragments should always use the child FragmentManager.");
            }
            nM = abstractComponentCallbacksC0109u.m();
        }
        return (F) nM.B(getId());
    }

    @Override // android.view.View
    public final WindowInsets onApplyWindowInsets(WindowInsets windowInsets) {
        J3.i.e(windowInsets, "insets");
        return windowInsets;
    }

    @Override // android.view.ViewGroup
    public final void removeAllViewsInLayout() {
        int childCount = getChildCount();
        while (true) {
            childCount--;
            if (-1 >= childCount) {
                super.removeAllViewsInLayout();
                return;
            } else {
                View childAt = getChildAt(childCount);
                J3.i.d(childAt, "view");
                a(childAt);
            }
        }
    }

    @Override // android.view.ViewGroup, android.view.ViewManager
    public final void removeView(View view) {
        J3.i.e(view, "view");
        a(view);
        super.removeView(view);
    }

    @Override // android.view.ViewGroup
    public final void removeViewAt(int i4) {
        View childAt = getChildAt(i4);
        J3.i.d(childAt, "view");
        a(childAt);
        super.removeViewAt(i4);
    }

    @Override // android.view.ViewGroup
    public final void removeViewInLayout(View view) {
        J3.i.e(view, "view");
        a(view);
        super.removeViewInLayout(view);
    }

    @Override // android.view.ViewGroup
    public final void removeViews(int i4, int i5) {
        int i6 = i4 + i5;
        for (int i7 = i4; i7 < i6; i7++) {
            View childAt = getChildAt(i7);
            J3.i.d(childAt, "view");
            a(childAt);
        }
        super.removeViews(i4, i5);
    }

    @Override // android.view.ViewGroup
    public final void removeViewsInLayout(int i4, int i5) {
        int i6 = i4 + i5;
        for (int i7 = i4; i7 < i6; i7++) {
            View childAt = getChildAt(i7);
            J3.i.d(childAt, "view");
            a(childAt);
        }
        super.removeViewsInLayout(i4, i5);
    }

    public final void setDrawDisappearingViewsLast(boolean z4) {
        this.f1205d = z4;
    }

    @Override // android.view.ViewGroup
    public void setLayoutTransition(LayoutTransition layoutTransition) {
        throw new UnsupportedOperationException("FragmentContainerView does not support Layout Transitions or animateLayoutChanges=\"true\".");
    }

    @Override // android.view.View
    public void setOnApplyWindowInsetsListener(View.OnApplyWindowInsetsListener onApplyWindowInsetsListener) {
        J3.i.e(onApplyWindowInsetsListener, "listener");
        this.f1204c = onApplyWindowInsetsListener;
    }

    @Override // android.view.ViewGroup
    public final void startViewTransition(View view) {
        J3.i.e(view, "view");
        if (view.getParent() == this) {
            this.f1203b.add(view);
        }
        super.startViewTransition(view);
    }
}
