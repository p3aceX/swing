package O;

import a.AbstractC0184a;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import b.DialogC0235l;
import com.swing.live.R;
import m.C0541c;
import m.C0544f;
import z0.C0779j;

/* JADX INFO: renamed from: O.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class DialogInterfaceOnCancelListenerC0106q extends AbstractComponentCallbacksC0109u implements DialogInterface.OnCancelListener, DialogInterface.OnDismissListener {

    /* JADX INFO: renamed from: Y, reason: collision with root package name */
    public final DialogInterfaceOnCancelListenerC0103n f1361Y;

    /* JADX INFO: renamed from: Z, reason: collision with root package name */
    public final DialogInterfaceOnDismissListenerC0104o f1362Z;

    /* JADX INFO: renamed from: a0, reason: collision with root package name */
    public int f1363a0;

    /* JADX INFO: renamed from: b0, reason: collision with root package name */
    public int f1364b0;

    /* JADX INFO: renamed from: c0, reason: collision with root package name */
    public boolean f1365c0;

    /* JADX INFO: renamed from: d0, reason: collision with root package name */
    public boolean f1366d0;

    /* JADX INFO: renamed from: e0, reason: collision with root package name */
    public int f1367e0;

    /* JADX INFO: renamed from: f0, reason: collision with root package name */
    public boolean f1368f0;

    /* JADX INFO: renamed from: g0, reason: collision with root package name */
    public final C0779j f1369g0;
    public Dialog h0;

    /* JADX INFO: renamed from: i0, reason: collision with root package name */
    public boolean f1370i0;

    /* JADX INFO: renamed from: j0, reason: collision with root package name */
    public boolean f1371j0;

    /* JADX INFO: renamed from: k0, reason: collision with root package name */
    public boolean f1372k0;

    /* JADX INFO: renamed from: l0, reason: collision with root package name */
    public boolean f1373l0;

    public DialogInterfaceOnCancelListenerC0106q() {
        new F.b(this, 1);
        this.f1361Y = new DialogInterfaceOnCancelListenerC0103n(this);
        this.f1362Z = new DialogInterfaceOnDismissListenerC0104o(this);
        this.f1363a0 = 0;
        this.f1364b0 = 0;
        this.f1365c0 = true;
        this.f1366d0 = true;
        this.f1367e0 = -1;
        this.f1369g0 = new C0779j(this, 14);
        this.f1373l0 = false;
    }

    /* JADX WARN: Removed duplicated region for block: B:26:0x0043  */
    /* JADX WARN: Removed duplicated region for block: B:27:0x0044 A[Catch: all -> 0x004e, TryCatch #0 {all -> 0x004e, blocks: (B:12:0x001a, B:14:0x0027, B:24:0x003f, B:29:0x0048, B:32:0x0050, B:27:0x0044, B:20:0x0031, B:22:0x0037, B:23:0x003c, B:33:0x0068), top: B:52:0x001a }] */
    /* JADX WARN: Removed duplicated region for block: B:29:0x0048 A[Catch: all -> 0x004e, TryCatch #0 {all -> 0x004e, blocks: (B:12:0x001a, B:14:0x0027, B:24:0x003f, B:29:0x0048, B:32:0x0050, B:27:0x0044, B:20:0x0031, B:22:0x0037, B:23:0x003c, B:33:0x0068), top: B:52:0x001a }] */
    @Override // O.AbstractComponentCallbacksC0109u
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.view.LayoutInflater A(android.os.Bundle r9) {
        /*
            Method dump skipped, instruction units count: 213
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: O.DialogInterfaceOnCancelListenerC0106q.A(android.os.Bundle):android.view.LayoutInflater");
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void C(Bundle bundle) {
        Dialog dialog = this.h0;
        if (dialog != null) {
            Bundle bundleOnSaveInstanceState = dialog.onSaveInstanceState();
            bundleOnSaveInstanceState.putBoolean("android:dialogShowing", false);
            bundle.putBundle("android:savedDialogState", bundleOnSaveInstanceState);
        }
        int i4 = this.f1363a0;
        if (i4 != 0) {
            bundle.putInt("android:style", i4);
        }
        int i5 = this.f1364b0;
        if (i5 != 0) {
            bundle.putInt("android:theme", i5);
        }
        boolean z4 = this.f1365c0;
        if (!z4) {
            bundle.putBoolean("android:cancelable", z4);
        }
        boolean z5 = this.f1366d0;
        if (!z5) {
            bundle.putBoolean("android:showsDialog", z5);
        }
        int i6 = this.f1367e0;
        if (i6 != -1) {
            bundle.putInt("android:backStackId", i6);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void D() {
        this.J = true;
        Dialog dialog = this.h0;
        if (dialog != null) {
            this.f1370i0 = false;
            dialog.show();
            View decorView = this.h0.getWindow().getDecorView();
            J3.i.e(decorView, "<this>");
            decorView.setTag(R.id.view_tree_lifecycle_owner, this);
            decorView.setTag(R.id.view_tree_view_model_store_owner, this);
            decorView.setTag(R.id.view_tree_saved_state_registry_owner, this);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void E() {
        this.J = true;
        Dialog dialog = this.h0;
        if (dialog != null) {
            dialog.hide();
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void F(LayoutInflater layoutInflater, ViewGroup viewGroup, Bundle bundle) {
        Bundle bundle2;
        super.F(layoutInflater, viewGroup, bundle);
        if (this.h0 == null || bundle == null || (bundle2 = bundle.getBundle("android:savedDialogState")) == null) {
            return;
        }
        this.h0.onRestoreInstanceState(bundle2);
    }

    public Dialog I() {
        if (N.J(3)) {
            Log.d("FragmentManager", "onCreateDialog called for DialogFragment " + this);
        }
        return new DialogC0235l(G(), this.f1364b0);
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final AbstractC0184a j() {
        return new C0105p(this, new C0107s(this));
    }

    @Override // android.content.DialogInterface.OnDismissListener
    public final void onDismiss(DialogInterface dialogInterface) {
        if (this.f1370i0) {
            return;
        }
        if (N.J(3)) {
            Log.d("FragmentManager", "onDismiss called for DialogFragment " + this);
        }
        if (this.f1371j0) {
            return;
        }
        this.f1371j0 = true;
        this.f1372k0 = false;
        Dialog dialog = this.h0;
        if (dialog != null) {
            dialog.setOnDismissListener(null);
            this.h0.dismiss();
        }
        this.f1370i0 = true;
        if (this.f1367e0 >= 0) {
            N nO = o();
            int i4 = this.f1367e0;
            if (i4 < 0) {
                throw new IllegalArgumentException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "Bad id: "));
            }
            nO.x(new L(nO, i4), true);
            this.f1367e0 = -1;
            return;
        }
        C0090a c0090a = new C0090a(o());
        c0090a.f1317o = true;
        N n4 = this.f1424y;
        if (n4 == null || n4 == c0090a.f1318p) {
            c0090a.b(new V(3, this));
            c0090a.d(true);
        } else {
            throw new IllegalStateException("Cannot remove Fragment attached to a different FragmentManager. Fragment " + toString() + " is already attached to a FragmentManager.");
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void t() {
        this.J = true;
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void v(AbstractActivityC0114z abstractActivityC0114z) {
        Object obj;
        super.v(abstractActivityC0114z);
        androidx.lifecycle.u uVar = this.f1404T;
        C0779j c0779j = this.f1369g0;
        uVar.getClass();
        androidx.lifecycle.u.a("observeForever");
        androidx.lifecycle.r rVar = new androidx.lifecycle.r(uVar, c0779j);
        C0544f c0544f = uVar.f3091b;
        C0541c c0541cF = c0544f.f(c0779j);
        if (c0541cF != null) {
            obj = c0541cF.f5752b;
        } else {
            C0541c c0541c = new C0541c(c0779j, rVar);
            c0544f.f5761d++;
            C0541c c0541c2 = c0544f.f5759b;
            if (c0541c2 == null) {
                c0544f.f5758a = c0541c;
                c0544f.f5759b = c0541c;
            } else {
                c0541c2.f5753c = c0541c;
                c0541c.f5754d = c0541c2;
                c0544f.f5759b = c0541c;
            }
            obj = null;
        }
        androidx.lifecycle.t tVar = (androidx.lifecycle.t) obj;
        if (tVar instanceof androidx.lifecycle.s) {
            throw new IllegalArgumentException("Cannot add the same observer with different lifecycles");
        }
        if (tVar == null) {
            rVar.b(true);
        }
        if (this.f1372k0) {
            return;
        }
        this.f1371j0 = false;
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void w(Bundle bundle) {
        Bundle bundle2;
        this.J = true;
        Bundle bundle3 = this.f1409b;
        if (bundle3 != null && (bundle2 = bundle3.getBundle("childFragmentManager")) != null) {
            this.f1386A.U(bundle2);
            N n4 = this.f1386A;
            n4.f1229G = false;
            n4.f1230H = false;
            n4.f1235N.f1273h = false;
            n4.u(1);
        }
        N n5 = this.f1386A;
        if (n5.f1256u < 1) {
            n5.f1229G = false;
            n5.f1230H = false;
            n5.f1235N.f1273h = false;
            n5.u(1);
        }
        new Handler();
        this.f1366d0 = this.f1389D == 0;
        if (bundle != null) {
            this.f1363a0 = bundle.getInt("android:style", 0);
            this.f1364b0 = bundle.getInt("android:theme", 0);
            this.f1365c0 = bundle.getBoolean("android:cancelable", true);
            this.f1366d0 = bundle.getBoolean("android:showsDialog", this.f1366d0);
            this.f1367e0 = bundle.getInt("android:backStackId", -1);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void y() {
        this.J = true;
        Dialog dialog = this.h0;
        if (dialog != null) {
            this.f1370i0 = true;
            dialog.setOnDismissListener(null);
            this.h0.dismiss();
            if (!this.f1371j0) {
                onDismiss(this.h0);
            }
            this.h0 = null;
            this.f1373l0 = false;
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void z() {
        this.J = true;
        if (!this.f1372k0 && !this.f1371j0) {
            this.f1371j0 = true;
        }
        this.f1404T.g(this.f1369g0);
    }

    @Override // android.content.DialogInterface.OnCancelListener
    public void onCancel(DialogInterface dialogInterface) {
    }
}
