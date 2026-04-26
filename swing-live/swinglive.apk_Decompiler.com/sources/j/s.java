package j;

import A.C;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;
import com.swing.live.R;
import java.lang.reflect.Field;
import k.M;
import k.N;

/* JADX INFO: loaded from: classes.dex */
public final class s extends l implements PopupWindow.OnDismissListener, View.OnKeyListener {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Context f5138b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final j f5139c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final h f5140d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f5141f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final int f5142m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final N f5143n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final c f5144o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final d f5145p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public m f5146q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public View f5147r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public View f5148s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public o f5149t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public ViewTreeObserver f5150u;
    public boolean v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f5151w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f5152x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f5153y = 0;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public boolean f5154z;

    public s(int i4, Context context, View view, j jVar, boolean z4) {
        int i5 = 1;
        this.f5144o = new c(this, i5);
        this.f5145p = new d(this, i5);
        this.f5138b = context;
        this.f5139c = jVar;
        this.e = z4;
        this.f5140d = new h(jVar, LayoutInflater.from(context), z4, R.layout.abc_popup_menu_item_layout);
        this.f5142m = i4;
        Resources resources = context.getResources();
        this.f5141f = Math.max(resources.getDisplayMetrics().widthPixels / 2, resources.getDimensionPixelSize(R.dimen.abc_config_prefDialogWidth));
        this.f5147r = view;
        this.f5143n = new N(context, i4);
        jVar.b(this, context);
    }

    @Override // j.p
    public final void a(j jVar, boolean z4) {
        if (jVar != this.f5139c) {
            return;
        }
        dismiss();
        o oVar = this.f5149t;
        if (oVar != null) {
            oVar.a(jVar, z4);
        }
    }

    @Override // j.r
    public final void b() {
        View view;
        if (g()) {
            return;
        }
        if (this.v || (view = this.f5147r) == null) {
            throw new IllegalStateException("StandardMenuPopup cannot be used without an anchor");
        }
        this.f5148s = view;
        N n4 = this.f5143n;
        n4.f5292B.setOnDismissListener(this);
        n4.f5304s = this;
        n4.f5291A = true;
        n4.f5292B.setFocusable(true);
        View view2 = this.f5148s;
        boolean z4 = this.f5150u == null;
        ViewTreeObserver viewTreeObserver = view2.getViewTreeObserver();
        this.f5150u = viewTreeObserver;
        if (z4) {
            viewTreeObserver.addOnGlobalLayoutListener(this.f5144o);
        }
        view2.addOnAttachStateChangeListener(this.f5145p);
        n4.f5303r = view2;
        n4.f5301p = this.f5153y;
        boolean z5 = this.f5151w;
        Context context = this.f5138b;
        h hVar = this.f5140d;
        if (!z5) {
            this.f5152x = l.m(hVar, context, this.f5141f);
            this.f5151w = true;
        }
        int i4 = this.f5152x;
        Drawable background = n4.f5292B.getBackground();
        if (background != null) {
            Rect rect = n4.f5309y;
            background.getPadding(rect);
            n4.f5296d = rect.left + rect.right + i4;
        } else {
            n4.f5296d = i4;
        }
        n4.f5292B.setInputMethodMode(2);
        Rect rect2 = this.f5126a;
        n4.f5310z = rect2 != null ? new Rect(rect2) : null;
        n4.b();
        M m4 = n4.f5295c;
        m4.setOnKeyListener(this);
        if (this.f5154z) {
            j jVar = this.f5139c;
            if (jVar.f5091l != null) {
                FrameLayout frameLayout = (FrameLayout) LayoutInflater.from(context).inflate(R.layout.abc_popup_menu_header_item_layout, (ViewGroup) m4, false);
                TextView textView = (TextView) frameLayout.findViewById(android.R.id.title);
                if (textView != null) {
                    textView.setText(jVar.f5091l);
                }
                frameLayout.setEnabled(false);
                m4.addHeaderView(frameLayout, null, false);
            }
        }
        n4.c(hVar);
        n4.b();
    }

    @Override // j.p
    public final boolean d() {
        return false;
    }

    @Override // j.r
    public final void dismiss() {
        if (g()) {
            this.f5143n.dismiss();
        }
    }

    @Override // j.p
    public final void f() {
        this.f5151w = false;
        h hVar = this.f5140d;
        if (hVar != null) {
            hVar.notifyDataSetChanged();
        }
    }

    @Override // j.r
    public final boolean g() {
        return !this.v && this.f5143n.f5292B.isShowing();
    }

    @Override // j.r
    public final ListView h() {
        return this.f5143n.f5295c;
    }

    @Override // j.p
    public final void j(o oVar) {
        this.f5149t = oVar;
    }

    @Override // j.p
    public final boolean k(t tVar) {
        if (tVar.hasVisibleItems()) {
            n nVar = new n(this.f5142m, this.f5138b, this.f5148s, tVar, this.e);
            o oVar = this.f5149t;
            nVar.f5134h = oVar;
            l lVar = nVar.f5135i;
            if (lVar != null) {
                lVar.j(oVar);
            }
            boolean zU = l.u(tVar);
            nVar.f5133g = zU;
            l lVar2 = nVar.f5135i;
            if (lVar2 != null) {
                lVar2.o(zU);
            }
            nVar.f5136j = this.f5146q;
            this.f5146q = null;
            this.f5139c.c(false);
            N n4 = this.f5143n;
            int width = n4.e;
            int i4 = !n4.f5298m ? 0 : n4.f5297f;
            int i5 = this.f5153y;
            View view = this.f5147r;
            Field field = C.f4a;
            if ((Gravity.getAbsoluteGravity(i5, view.getLayoutDirection()) & 7) == 5) {
                width += this.f5147r.getWidth();
            }
            if (!nVar.b()) {
                if (nVar.e != null) {
                    nVar.d(width, i4, true, true);
                }
            }
            o oVar2 = this.f5149t;
            if (oVar2 != null) {
                oVar2.h(tVar);
            }
            return true;
        }
        return false;
    }

    @Override // j.l
    public final void n(View view) {
        this.f5147r = view;
    }

    @Override // j.l
    public final void o(boolean z4) {
        this.f5140d.f5077c = z4;
    }

    @Override // android.widget.PopupWindow.OnDismissListener
    public final void onDismiss() {
        this.v = true;
        this.f5139c.c(true);
        ViewTreeObserver viewTreeObserver = this.f5150u;
        if (viewTreeObserver != null) {
            if (!viewTreeObserver.isAlive()) {
                this.f5150u = this.f5148s.getViewTreeObserver();
            }
            this.f5150u.removeGlobalOnLayoutListener(this.f5144o);
            this.f5150u = null;
        }
        this.f5148s.removeOnAttachStateChangeListener(this.f5145p);
        m mVar = this.f5146q;
        if (mVar != null) {
            mVar.onDismiss();
        }
    }

    @Override // android.view.View.OnKeyListener
    public final boolean onKey(View view, int i4, KeyEvent keyEvent) {
        if (keyEvent.getAction() != 1 || i4 != 82) {
            return false;
        }
        dismiss();
        return true;
    }

    @Override // j.l
    public final void p(int i4) {
        this.f5153y = i4;
    }

    @Override // j.l
    public final void q(int i4) {
        this.f5143n.e = i4;
    }

    @Override // j.l
    public final void r(PopupWindow.OnDismissListener onDismissListener) {
        this.f5146q = (m) onDismissListener;
    }

    @Override // j.l
    public final void s(boolean z4) {
        this.f5154z = z4;
    }

    @Override // j.l
    public final void t(int i4) {
        N n4 = this.f5143n;
        n4.f5297f = i4;
        n4.f5298m = true;
    }

    @Override // j.l
    public final void l(j jVar) {
    }
}
