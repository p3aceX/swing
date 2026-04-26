package k;

import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.TouchDelegate;
import android.view.View;
import android.view.ViewConfiguration;

/* JADX INFO: loaded from: classes.dex */
public final class d0 extends TouchDelegate {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f5342a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Rect f5343b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Rect f5344c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Rect f5345d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f5346f;

    public d0(Rect rect, Rect rect2, View view) {
        super(rect, view);
        int scaledTouchSlop = ViewConfiguration.get(view.getContext()).getScaledTouchSlop();
        this.e = scaledTouchSlop;
        Rect rect3 = new Rect();
        this.f5343b = rect3;
        Rect rect4 = new Rect();
        this.f5345d = rect4;
        Rect rect5 = new Rect();
        this.f5344c = rect5;
        rect3.set(rect);
        rect4.set(rect);
        int i4 = -scaledTouchSlop;
        rect4.inset(i4, i4);
        rect5.set(rect2);
        this.f5342a = view;
    }

    @Override // android.view.TouchDelegate
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        boolean z4;
        boolean z5;
        int x4 = (int) motionEvent.getX();
        int y4 = (int) motionEvent.getY();
        int action = motionEvent.getAction();
        boolean z6 = true;
        if (action != 0) {
            if (action == 1 || action == 2) {
                z5 = this.f5346f;
                if (z5 && !this.f5345d.contains(x4, y4)) {
                    z6 = z5;
                    z4 = false;
                }
            } else {
                if (action == 3) {
                    z5 = this.f5346f;
                    this.f5346f = false;
                }
                z4 = true;
                z6 = false;
            }
            z6 = z5;
            z4 = true;
        } else if (this.f5343b.contains(x4, y4)) {
            this.f5346f = true;
            z4 = true;
        } else {
            z4 = true;
            z6 = false;
        }
        if (!z6) {
            return false;
        }
        Rect rect = this.f5344c;
        View view = this.f5342a;
        if (!z4 || rect.contains(x4, y4)) {
            motionEvent.setLocation(x4 - rect.left, y4 - rect.top);
        } else {
            motionEvent.setLocation(view.getWidth() / 2, view.getHeight() / 2);
        }
        return view.dispatchTouchEvent(motionEvent);
    }
}
