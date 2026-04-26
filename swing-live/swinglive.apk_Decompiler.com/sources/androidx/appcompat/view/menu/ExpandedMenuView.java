package androidx.appcompat.view.menu;

import android.R;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import j.i;
import j.k;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class ExpandedMenuView extends ListView implements i, AdapterView.OnItemClickListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final int[] f2656a = {R.attr.background, R.attr.divider};

    public ExpandedMenuView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        setOnItemClickListener(this);
        C0747k c0747kP = C0747k.P(context, attributeSet, f2656a, R.attr.listViewStyle);
        TypedArray typedArray = (TypedArray) c0747kP.f6832c;
        if (typedArray.hasValue(0)) {
            setBackgroundDrawable(c0747kP.F(0));
        }
        if (typedArray.hasValue(1)) {
            setDivider(c0747kP.F(1));
        }
        c0747kP.T();
    }

    @Override // j.i
    public final boolean a(k kVar) {
        throw null;
    }

    public int getWindowAnimations() {
        return 0;
    }

    @Override // android.widget.ListView, android.widget.AbsListView, android.widget.AdapterView, android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        setChildrenDrawingCacheEnabled(false);
    }

    @Override // android.widget.AdapterView.OnItemClickListener
    public final void onItemClick(AdapterView adapterView, View view, int i4, long j4) {
        throw null;
    }
}
