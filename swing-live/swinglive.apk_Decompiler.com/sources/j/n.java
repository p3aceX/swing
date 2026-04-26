package j;

import A.C;
import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import com.swing.live.R;
import java.lang.reflect.Field;

/* JADX INFO: loaded from: classes.dex */
public class n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5128a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final j f5129b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f5130c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f5131d;
    public View e;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f5133g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public o f5134h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public l f5135i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public m f5136j;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5132f = 8388611;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final m f5137k = new m(this);

    public n(int i4, Context context, View view, j jVar, boolean z4) {
        this.f5128a = context;
        this.f5129b = jVar;
        this.e = view;
        this.f5130c = z4;
        this.f5131d = i4;
    }

    public final l a() {
        l sVar;
        if (this.f5135i == null) {
            Context context = this.f5128a;
            Display defaultDisplay = ((WindowManager) context.getSystemService("window")).getDefaultDisplay();
            Point point = new Point();
            defaultDisplay.getRealSize(point);
            if (Math.min(point.x, point.y) >= context.getResources().getDimensionPixelSize(R.dimen.abc_cascading_menus_min_smallest_width)) {
                sVar = new g(context, this.e, this.f5131d, this.f5130c);
            } else {
                View view = this.e;
                Context context2 = this.f5128a;
                boolean z4 = this.f5130c;
                sVar = new s(this.f5131d, context2, view, this.f5129b, z4);
            }
            sVar.l(this.f5129b);
            sVar.r(this.f5137k);
            sVar.n(this.e);
            sVar.j(this.f5134h);
            sVar.o(this.f5133g);
            sVar.p(this.f5132f);
            this.f5135i = sVar;
        }
        return this.f5135i;
    }

    public final boolean b() {
        l lVar = this.f5135i;
        return lVar != null && lVar.g();
    }

    public void c() {
        this.f5135i = null;
        m mVar = this.f5136j;
        if (mVar != null) {
            mVar.onDismiss();
        }
    }

    public final void d(int i4, int i5, boolean z4, boolean z5) {
        l lVarA = a();
        lVarA.s(z5);
        if (z4) {
            int i6 = this.f5132f;
            View view = this.e;
            Field field = C.f4a;
            if ((Gravity.getAbsoluteGravity(i6, view.getLayoutDirection()) & 7) == 5) {
                i4 -= this.e.getWidth();
            }
            lVarA.q(i4);
            lVarA.t(i5);
            int i7 = (int) ((this.f5128a.getResources().getDisplayMetrics().density * 48.0f) / 2.0f);
            lVarA.f5126a = new Rect(i4 - i7, i5 - i7, i4 + i7, i5 + i7);
        }
        lVarA.b();
    }
}
