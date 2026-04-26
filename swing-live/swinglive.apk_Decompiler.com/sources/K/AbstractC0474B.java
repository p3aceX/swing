package k;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.ListAdapter;
import android.widget.ListView;
import com.swing.live.R;
import java.lang.reflect.Field;

/* JADX INFO: renamed from: k.B, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0474B extends ListView {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Rect f5253a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5254b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5255c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5256d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5257f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Field f5258m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public C0473A f5259n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f5260o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final boolean f5261p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public boolean f5262q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public F.g f5263r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public F.b f5264s;

    public AbstractC0474B(Context context, boolean z4) {
        super(context, null, R.attr.dropDownListViewStyle);
        this.f5253a = new Rect();
        this.f5254b = 0;
        this.f5255c = 0;
        this.f5256d = 0;
        this.e = 0;
        this.f5261p = z4;
        setCacheColorHint(0);
        try {
            Field declaredField = AbsListView.class.getDeclaredField("mIsChildViewEnabled");
            this.f5258m = declaredField;
            declaredField.setAccessible(true);
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        }
    }

    public final int a(int i4, int i5) {
        int listPaddingTop = getListPaddingTop();
        int listPaddingBottom = getListPaddingBottom();
        getListPaddingLeft();
        getListPaddingRight();
        int dividerHeight = getDividerHeight();
        Drawable divider = getDivider();
        ListAdapter adapter = getAdapter();
        if (adapter == null) {
            return listPaddingTop + listPaddingBottom;
        }
        int measuredHeight = listPaddingTop + listPaddingBottom;
        if (dividerHeight <= 0 || divider == null) {
            dividerHeight = 0;
        }
        int count = adapter.getCount();
        int i6 = 0;
        View view = null;
        for (int i7 = 0; i7 < count; i7++) {
            int itemViewType = adapter.getItemViewType(i7);
            if (itemViewType != i6) {
                view = null;
                i6 = itemViewType;
            }
            view = adapter.getView(i7, view, this);
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            if (layoutParams == null) {
                layoutParams = generateDefaultLayoutParams();
                view.setLayoutParams(layoutParams);
            }
            int i8 = layoutParams.height;
            view.measure(i4, i8 > 0 ? View.MeasureSpec.makeMeasureSpec(i8, 1073741824) : View.MeasureSpec.makeMeasureSpec(0, 0));
            view.forceLayout();
            if (i7 > 0) {
                measuredHeight += dividerHeight;
            }
            measuredHeight += view.getMeasuredHeight();
            if (measuredHeight >= i5) {
                return i5;
            }
        }
        return measuredHeight;
    }

    /* JADX WARN: Removed duplicated region for block: B:69:0x0130  */
    /* JADX WARN: Removed duplicated region for block: B:71:0x0146  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x014b  */
    /* JADX WARN: Removed duplicated region for block: B:77:0x0161  */
    /* JADX WARN: Removed duplicated region for block: B:9:0x0015  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean b(int r18, android.view.MotionEvent r19) {
        /*
            Method dump skipped, instruction units count: 368
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.AbstractC0474B.b(int, android.view.MotionEvent):boolean");
    }

    @Override // android.widget.ListView, android.widget.AbsListView, android.view.ViewGroup, android.view.View
    public final void dispatchDraw(Canvas canvas) {
        Drawable selector;
        Rect rect = this.f5253a;
        if (!rect.isEmpty() && (selector = getSelector()) != null) {
            selector.setBounds(rect);
            selector.draw(canvas);
        }
        super.dispatchDraw(canvas);
    }

    @Override // android.widget.AbsListView, android.view.ViewGroup, android.view.View
    public final void drawableStateChanged() {
        if (this.f5264s != null) {
            return;
        }
        super.drawableStateChanged();
        C0473A c0473a = this.f5259n;
        if (c0473a != null) {
            c0473a.f5252b = true;
        }
        Drawable selector = getSelector();
        if (selector != null && this.f5262q && isPressed()) {
            selector.setState(getDrawableState());
        }
    }

    @Override // android.view.ViewGroup, android.view.View
    public final boolean hasFocus() {
        return this.f5261p || super.hasFocus();
    }

    @Override // android.view.View
    public final boolean hasWindowFocus() {
        return this.f5261p || super.hasWindowFocus();
    }

    @Override // android.view.View
    public final boolean isFocused() {
        return this.f5261p || super.isFocused();
    }

    @Override // android.view.View
    public final boolean isInTouchMode() {
        return (this.f5261p && this.f5260o) || super.isInTouchMode();
    }

    @Override // android.widget.ListView, android.widget.AbsListView, android.widget.AdapterView, android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        this.f5264s = null;
        super.onDetachedFromWindow();
    }

    @Override // android.view.View
    public boolean onHoverEvent(MotionEvent motionEvent) {
        if (Build.VERSION.SDK_INT < 26) {
            return super.onHoverEvent(motionEvent);
        }
        int actionMasked = motionEvent.getActionMasked();
        if (actionMasked == 10 && this.f5264s == null) {
            F.b bVar = new F.b(this, 12);
            this.f5264s = bVar;
            post(bVar);
        }
        boolean zOnHoverEvent = super.onHoverEvent(motionEvent);
        if (actionMasked != 9 && actionMasked != 7) {
            setSelection(-1);
            return zOnHoverEvent;
        }
        int iPointToPosition = pointToPosition((int) motionEvent.getX(), (int) motionEvent.getY());
        if (iPointToPosition != -1 && iPointToPosition != getSelectedItemPosition()) {
            View childAt = getChildAt(iPointToPosition - getFirstVisiblePosition());
            if (childAt.isEnabled()) {
                setSelectionFromTop(iPointToPosition, childAt.getTop() - getTop());
            }
            Drawable selector = getSelector();
            if (selector != null && this.f5262q && isPressed()) {
                selector.setState(getDrawableState());
            }
        }
        return zOnHoverEvent;
    }

    @Override // android.widget.AbsListView, android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        if (motionEvent.getAction() == 0) {
            this.f5257f = pointToPosition((int) motionEvent.getX(), (int) motionEvent.getY());
        }
        F.b bVar = this.f5264s;
        if (bVar != null) {
            AbstractC0474B abstractC0474B = (AbstractC0474B) bVar.f390b;
            abstractC0474B.f5264s = null;
            abstractC0474B.removeCallbacks(bVar);
        }
        return super.onTouchEvent(motionEvent);
    }

    public void setListSelectionHidden(boolean z4) {
        this.f5260o = z4;
    }

    @Override // android.widget.AbsListView
    public void setSelector(Drawable drawable) {
        C0473A c0473a = null;
        if (drawable != null) {
            C0473A c0473a2 = new C0473A();
            Drawable drawable2 = c0473a2.f5251a;
            if (drawable2 != null) {
                drawable2.setCallback(null);
            }
            c0473a2.f5251a = drawable;
            drawable.setCallback(c0473a2);
            c0473a2.f5252b = true;
            c0473a = c0473a2;
        }
        this.f5259n = c0473a;
        super.setSelector(c0473a);
        Rect rect = new Rect();
        if (drawable != null) {
            drawable.getPadding(rect);
        }
        this.f5254b = rect.left;
        this.f5255c = rect.top;
        this.f5256d = rect.right;
        this.e = rect.bottom;
    }
}
