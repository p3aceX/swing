package io.flutter.plugin.editing;

import A.C0012l;
import B.k;
import D2.v;
import I.C0053n;
import N2.n;
import android.graphics.Rect;
import android.os.Build;
import android.os.IBinder;
import android.util.SparseArray;
import android.view.View;
import android.view.autofill.AutofillManager;
import android.view.autofill.AutofillValue;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import io.flutter.plugin.platform.p;
import io.flutter.plugin.platform.q;
import u1.C0690c;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class i implements e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f4586a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final InputMethodManager f4587b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AutofillManager f4588c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final v f4589d;
    public C0012l e = new C0012l(1, 0);

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public n f4590f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public SparseArray f4591g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public f f4592h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f4593i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public InputConnection f4594j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final q f4595k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final p f4596l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Rect f4597m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final ImeSyncDeferringInsetsCallback f4598n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public N2.p f4599o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f4600p;

    public i(View view, v vVar, C0690c c0690c, q qVar, p pVar) {
        this.f4586a = view;
        this.f4592h = new f(null, view);
        this.f4587b = (InputMethodManager) view.getContext().getSystemService("input_method");
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 26) {
            this.f4588c = B.d.f(view.getContext().getSystemService(B.d.l()));
        } else {
            this.f4588c = null;
        }
        if (i4 >= 30) {
            ImeSyncDeferringInsetsCallback imeSyncDeferringInsetsCallback = new ImeSyncDeferringInsetsCallback(view);
            this.f4598n = imeSyncDeferringInsetsCallback;
            imeSyncDeferringInsetsCallback.install();
            imeSyncDeferringInsetsCallback.setImeVisibilityListener(new k(this, 22));
        }
        this.f4589d = vVar;
        vVar.f261c = new C0690c(this, 26);
        ((C0747k) vVar.f260b).O("TextInputClient.requestExistingInputState", null, null);
        this.f4595k = qVar;
        qVar.f4671m = this;
        this.f4596l = pVar;
        pVar.f4652f = this;
    }

    /* JADX WARN: Code restructure failed: missing block: B:22:0x0085, code lost:
    
        if (r10 == r0.e) goto L44;
     */
    /* JADX WARN: Unreachable blocks removed: 2, instructions: 2 */
    @Override // io.flutter.plugin.editing.e
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void a(boolean r19) {
        /*
            Method dump skipped, instruction units count: 398
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.plugin.editing.i.a(boolean):void");
    }

    public final void b(int i4) {
        C0012l c0012l = this.e;
        int i5 = c0012l.f55b;
        if ((i5 == 3 || i5 == 4) && c0012l.f56c == i4) {
            this.e = new C0012l(1, 0);
            d();
            View view = this.f4586a;
            IBinder applicationWindowToken = view.getApplicationWindowToken();
            InputMethodManager inputMethodManager = this.f4587b;
            inputMethodManager.hideSoftInputFromWindow(applicationWindowToken, 0);
            inputMethodManager.restartInput(view);
            this.f4593i = false;
        }
    }

    public final void c() {
        this.f4595k.f4671m = null;
        this.f4596l.f4652f = null;
        this.f4589d.f261c = null;
        d();
        this.f4592h.e(this);
        ImeSyncDeferringInsetsCallback imeSyncDeferringInsetsCallback = this.f4598n;
        if (imeSyncDeferringInsetsCallback != null) {
            imeSyncDeferringInsetsCallback.remove();
        }
    }

    public final void d() {
        AutofillManager autofillManager;
        n nVar;
        C0053n c0053n;
        if (Build.VERSION.SDK_INT < 26 || (autofillManager = this.f4588c) == null || (nVar = this.f4590f) == null || (c0053n = nVar.f1187j) == null || this.f4591g == null) {
            return;
        }
        autofillManager.notifyViewExited(this.f4586a, ((String) c0053n.f706b).hashCode());
    }

    public final void e(n nVar) {
        C0053n c0053n;
        if (Build.VERSION.SDK_INT < 26) {
            return;
        }
        if (nVar == null || (c0053n = nVar.f1187j) == null) {
            this.f4591g = null;
            return;
        }
        SparseArray sparseArray = new SparseArray();
        this.f4591g = sparseArray;
        n[] nVarArr = nVar.f1189l;
        if (nVarArr == null) {
            sparseArray.put(((String) c0053n.f706b).hashCode(), nVar);
            return;
        }
        for (n nVar2 : nVarArr) {
            C0053n c0053n2 = nVar2.f1187j;
            if (c0053n2 != null) {
                SparseArray sparseArray2 = this.f4591g;
                String str = (String) c0053n2.f706b;
                sparseArray2.put(str.hashCode(), nVar2);
                this.f4588c.notifyValueChanged(this.f4586a, str.hashCode(), AutofillValue.forText(((N2.p) c0053n2.f708d).f1194a));
            }
        }
    }
}
