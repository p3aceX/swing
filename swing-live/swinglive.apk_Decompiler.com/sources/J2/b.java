package J2;

import D2.C0026a;
import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.accessibility.AccessibilityEvent;
import android.widget.FrameLayout;
import io.flutter.embedding.engine.mutatorsstack.FlutterMutatorsStack;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class b extends FrameLayout {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public FlutterMutatorsStack f807a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float f808b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f809c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f810d;
    public final C0026a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Paint f811f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public a f812m;

    public b(Activity activity, float f4, C0026a c0026a) {
        super(activity, null);
        this.f808b = f4;
        this.e = c0026a;
        this.f811f = new Paint();
    }

    private Matrix getPlatformViewMatrix() {
        Matrix matrix = new Matrix(this.f807a.getFinalMatrix());
        float f4 = this.f808b;
        matrix.preScale(1.0f / f4, 1.0f / f4);
        matrix.postTranslate(-this.f809c, -this.f810d);
        return matrix;
    }

    public final void a() {
        a aVar;
        ViewTreeObserver viewTreeObserver = getViewTreeObserver();
        if (!viewTreeObserver.isAlive() || (aVar = this.f812m) == null) {
            return;
        }
        this.f812m = null;
        viewTreeObserver.removeOnGlobalFocusChangeListener(aVar);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void dispatchDraw(Canvas canvas) {
        canvas.save();
        canvas.concat(getPlatformViewMatrix());
        super.dispatchDraw(canvas);
        canvas.restore();
    }

    @Override // android.view.View
    public final void draw(Canvas canvas) {
        canvas.save();
        Iterator<Path> it = this.f807a.getFinalClippingPaths().iterator();
        while (it.hasNext()) {
            Path path = new Path(it.next());
            path.offset(-this.f809c, -this.f810d);
            canvas.clipPath(path);
        }
        int finalOpacity = (int) (this.f807a.getFinalOpacity() * 255.0f);
        Paint paint = this.f811f;
        if (paint.getAlpha() != finalOpacity) {
            paint.setAlpha((int) (this.f807a.getFinalOpacity() * 255.0f));
            setLayerType(2, paint);
        }
        super.draw(canvas);
        canvas.restore();
    }

    @Override // android.view.ViewGroup
    public final boolean onInterceptTouchEvent(MotionEvent motionEvent) {
        return true;
    }

    @Override // android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        C0026a c0026a = this.e;
        if (c0026a == null) {
            return super.onTouchEvent(motionEvent);
        }
        Matrix matrix = new Matrix();
        matrix.postTranslate(getLeft(), getTop());
        c0026a.d(motionEvent, matrix);
        return true;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean requestSendAccessibilityEvent(View view, AccessibilityEvent accessibilityEvent) {
        View childAt = getChildAt(0);
        if (childAt == null || childAt.getImportantForAccessibility() != 4) {
            return super.requestSendAccessibilityEvent(view, accessibilityEvent);
        }
        return false;
    }

    public void setOnDescendantFocusChangeListener(View.OnFocusChangeListener onFocusChangeListener) {
        a();
        ViewTreeObserver viewTreeObserver = getViewTreeObserver();
        if (viewTreeObserver.isAlive() && this.f812m == null) {
            a aVar = new a(onFocusChangeListener, this);
            this.f812m = aVar;
            viewTreeObserver.addOnGlobalFocusChangeListener(aVar);
        }
    }
}
