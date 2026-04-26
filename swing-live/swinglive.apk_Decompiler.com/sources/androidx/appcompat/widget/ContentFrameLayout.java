package androidx.appcompat.widget;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.widget.FrameLayout;
import k.InterfaceC0506x;

/* JADX INFO: loaded from: classes.dex */
public class ContentFrameLayout extends FrameLayout {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public TypedValue f2725a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public TypedValue f2726b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public TypedValue f2727c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public TypedValue f2728d;
    public TypedValue e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public TypedValue f2729f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Rect f2730m;

    public ContentFrameLayout(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, 0);
        this.f2730m = new Rect();
    }

    public final void a(Rect rect) {
        fitSystemWindows(rect);
    }

    public TypedValue getFixedHeightMajor() {
        if (this.e == null) {
            this.e = new TypedValue();
        }
        return this.e;
    }

    public TypedValue getFixedHeightMinor() {
        if (this.f2729f == null) {
            this.f2729f = new TypedValue();
        }
        return this.f2729f;
    }

    public TypedValue getFixedWidthMajor() {
        if (this.f2727c == null) {
            this.f2727c = new TypedValue();
        }
        return this.f2727c;
    }

    public TypedValue getFixedWidthMinor() {
        if (this.f2728d == null) {
            this.f2728d = new TypedValue();
        }
        return this.f2728d;
    }

    public TypedValue getMinWidthMajor() {
        if (this.f2725a == null) {
            this.f2725a = new TypedValue();
        }
        return this.f2725a;
    }

    public TypedValue getMinWidthMinor() {
        if (this.f2726b == null) {
            this.f2726b = new TypedValue();
        }
        return this.f2726b;
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onAttachedToWindow() {
        super.onAttachedToWindow();
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        super.onDetachedFromWindow();
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x004e  */
    /* JADX WARN: Removed duplicated region for block: B:22:0x0062  */
    /* JADX WARN: Removed duplicated region for block: B:37:0x008a  */
    /* JADX WARN: Removed duplicated region for block: B:38:0x009d  */
    /* JADX WARN: Removed duplicated region for block: B:55:0x00d1  */
    /* JADX WARN: Removed duplicated region for block: B:57:0x00d9  */
    /* JADX WARN: Removed duplicated region for block: B:58:0x00de  */
    @Override // android.widget.FrameLayout, android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void onMeasure(int r17, int r18) {
        /*
            Method dump skipped, instruction units count: 229
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.appcompat.widget.ContentFrameLayout.onMeasure(int, int):void");
    }

    public void setAttachListener(InterfaceC0506x interfaceC0506x) {
    }
}
