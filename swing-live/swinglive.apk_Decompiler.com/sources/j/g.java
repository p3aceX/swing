package j;

import A.C;
import android.content.Context;
import android.content.res.Resources;
import android.os.Handler;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.HeaderViewListAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;
import com.swing.live.R;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.CopyOnWriteArrayList;
import k.N;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class g extends l implements View.OnKeyListener, PopupWindow.OnDismissListener {

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public boolean f5053B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public o f5054C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public ViewTreeObserver f5055D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public m f5056E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public boolean f5057F;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Context f5058b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5059c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f5060d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Handler f5061f;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final c f5064o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final d f5065p;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public View f5069t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public View f5070u;
    public int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f5071w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public boolean f5072x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f5073y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public int f5074z;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final ArrayList f5062m = new ArrayList();

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final ArrayList f5063n = new ArrayList();

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final C0779j f5066q = new C0779j(this, 26);

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f5067r = 0;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f5068s = 0;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public boolean f5052A = false;

    public g(Context context, View view, int i4, boolean z4) {
        this.f5064o = new c(this, i);
        this.f5065p = new d(this, i);
        this.f5058b = context;
        this.f5069t = view;
        this.f5060d = i4;
        this.e = z4;
        Field field = C.f4a;
        this.v = view.getLayoutDirection() != 1 ? 1 : 0;
        Resources resources = context.getResources();
        this.f5059c = Math.max(resources.getDisplayMetrics().widthPixels / 2, resources.getDimensionPixelSize(R.dimen.abc_config_prefDialogWidth));
        this.f5061f = new Handler();
    }

    @Override // j.p
    public final void a(j jVar, boolean z4) {
        ArrayList arrayList = this.f5063n;
        int size = arrayList.size();
        int i4 = 0;
        while (true) {
            if (i4 >= size) {
                i4 = -1;
                break;
            } else if (jVar == ((f) arrayList.get(i4)).f5050b) {
                break;
            } else {
                i4++;
            }
        }
        if (i4 < 0) {
            return;
        }
        int i5 = i4 + 1;
        if (i5 < arrayList.size()) {
            ((f) arrayList.get(i5)).f5050b.c(false);
        }
        f fVar = (f) arrayList.remove(i4);
        CopyOnWriteArrayList<WeakReference> copyOnWriteArrayList = fVar.f5050b.f5097r;
        for (WeakReference weakReference : copyOnWriteArrayList) {
            p pVar = (p) weakReference.get();
            if (pVar == null || pVar == this) {
                copyOnWriteArrayList.remove(weakReference);
            }
        }
        boolean z5 = this.f5057F;
        N n4 = fVar.f5049a;
        if (z5) {
            n4.f5292B.setExitTransition(null);
            n4.f5292B.setAnimationStyle(0);
        }
        n4.dismiss();
        int size2 = arrayList.size();
        if (size2 > 0) {
            this.v = ((f) arrayList.get(size2 - 1)).f5051c;
        } else {
            View view = this.f5069t;
            Field field = C.f4a;
            this.v = view.getLayoutDirection() == 1 ? 0 : 1;
        }
        if (size2 != 0) {
            if (z4) {
                ((f) arrayList.get(0)).f5050b.c(false);
                return;
            }
            return;
        }
        dismiss();
        o oVar = this.f5054C;
        if (oVar != null) {
            oVar.a(jVar, true);
        }
        ViewTreeObserver viewTreeObserver = this.f5055D;
        if (viewTreeObserver != null) {
            if (viewTreeObserver.isAlive()) {
                this.f5055D.removeGlobalOnLayoutListener(this.f5064o);
            }
            this.f5055D = null;
        }
        this.f5070u.removeOnAttachStateChangeListener(this.f5065p);
        this.f5056E.onDismiss();
    }

    @Override // j.r
    public final void b() {
        if (g()) {
            return;
        }
        ArrayList arrayList = this.f5062m;
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            v((j) it.next());
        }
        arrayList.clear();
        View view = this.f5069t;
        this.f5070u = view;
        if (view != null) {
            boolean z4 = this.f5055D == null;
            ViewTreeObserver viewTreeObserver = view.getViewTreeObserver();
            this.f5055D = viewTreeObserver;
            if (z4) {
                viewTreeObserver.addOnGlobalLayoutListener(this.f5064o);
            }
            this.f5070u.addOnAttachStateChangeListener(this.f5065p);
        }
    }

    @Override // j.p
    public final boolean d() {
        return false;
    }

    @Override // j.r
    public final void dismiss() {
        ArrayList arrayList = this.f5063n;
        int size = arrayList.size();
        if (size > 0) {
            f[] fVarArr = (f[]) arrayList.toArray(new f[size]);
            for (int i4 = size - 1; i4 >= 0; i4--) {
                f fVar = fVarArr[i4];
                if (fVar.f5049a.f5292B.isShowing()) {
                    fVar.f5049a.dismiss();
                }
            }
        }
    }

    @Override // j.p
    public final void f() {
        Iterator it = this.f5063n.iterator();
        while (it.hasNext()) {
            ListAdapter adapter = ((f) it.next()).f5049a.f5295c.getAdapter();
            if (adapter instanceof HeaderViewListAdapter) {
                adapter = ((HeaderViewListAdapter) adapter).getWrappedAdapter();
            }
            ((h) adapter).notifyDataSetChanged();
        }
    }

    @Override // j.r
    public final boolean g() {
        ArrayList arrayList = this.f5063n;
        return arrayList.size() > 0 && ((f) arrayList.get(0)).f5049a.f5292B.isShowing();
    }

    @Override // j.r
    public final ListView h() {
        ArrayList arrayList = this.f5063n;
        if (arrayList.isEmpty()) {
            return null;
        }
        return ((f) arrayList.get(arrayList.size() - 1)).f5049a.f5295c;
    }

    @Override // j.p
    public final void j(o oVar) {
        this.f5054C = oVar;
    }

    @Override // j.p
    public final boolean k(t tVar) {
        for (f fVar : this.f5063n) {
            if (tVar == fVar.f5050b) {
                fVar.f5049a.f5295c.requestFocus();
                return true;
            }
        }
        if (!tVar.hasVisibleItems()) {
            return false;
        }
        l(tVar);
        o oVar = this.f5054C;
        if (oVar != null) {
            oVar.h(tVar);
        }
        return true;
    }

    @Override // j.l
    public final void l(j jVar) {
        jVar.b(this, this.f5058b);
        if (g()) {
            v(jVar);
        } else {
            this.f5062m.add(jVar);
        }
    }

    @Override // j.l
    public final void n(View view) {
        if (this.f5069t != view) {
            this.f5069t = view;
            int i4 = this.f5067r;
            Field field = C.f4a;
            this.f5068s = Gravity.getAbsoluteGravity(i4, view.getLayoutDirection());
        }
    }

    @Override // j.l
    public final void o(boolean z4) {
        this.f5052A = z4;
    }

    @Override // android.widget.PopupWindow.OnDismissListener
    public final void onDismiss() {
        f fVar;
        ArrayList arrayList = this.f5063n;
        int size = arrayList.size();
        int i4 = 0;
        while (true) {
            if (i4 >= size) {
                fVar = null;
                break;
            }
            fVar = (f) arrayList.get(i4);
            if (!fVar.f5049a.f5292B.isShowing()) {
                break;
            } else {
                i4++;
            }
        }
        if (fVar != null) {
            fVar.f5050b.c(false);
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
        if (this.f5067r != i4) {
            this.f5067r = i4;
            View view = this.f5069t;
            Field field = C.f4a;
            this.f5068s = Gravity.getAbsoluteGravity(i4, view.getLayoutDirection());
        }
    }

    @Override // j.l
    public final void q(int i4) {
        this.f5071w = true;
        this.f5073y = i4;
    }

    @Override // j.l
    public final void r(PopupWindow.OnDismissListener onDismissListener) {
        this.f5056E = (m) onDismissListener;
    }

    @Override // j.l
    public final void s(boolean z4) {
        this.f5053B = z4;
    }

    @Override // j.l
    public final void t(int i4) {
        this.f5072x = true;
        this.f5074z = i4;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:61:0x0162  */
    /* JADX WARN: Removed duplicated region for block: B:63:0x0166  */
    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void v(j.j r19) {
        /*
            Method dump skipped, instruction units count: 567
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: j.g.v(j.j):void");
    }
}
