package O;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.MenuItem;
import android.view.View;
import androidx.lifecycle.EnumC0221g;
import androidx.lifecycle.EnumC0222h;
import b.AbstractActivityC0234k;
import c.C0248a;
import z.InterfaceC0769a;

/* JADX INFO: renamed from: O.z, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractActivityC0114z extends AbstractActivityC0234k implements q.d {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public boolean f1436A;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public boolean f1440z;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final B.k f1438x = new B.k(new C0113y(this), 13);

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final androidx.lifecycle.p f1439y = new androidx.lifecycle.p(this);

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public boolean f1437B = true;

    public AbstractActivityC0114z() {
        ((Y.e) this.e.f2464c).b("android:support:lifecycle", new C0110v(this, 0));
        final int i4 = 0;
        d(new InterfaceC0769a(this) { // from class: O.w

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ AbstractActivityC0114z f1429b;

            {
                this.f1429b = this;
            }

            @Override // z.InterfaceC0769a
            public final void accept(Object obj) {
                switch (i4) {
                    case 0:
                        this.f1429b.f1438x.u();
                        break;
                    default:
                        this.f1429b.f1438x.u();
                        break;
                }
            }
        });
        final int i5 = 1;
        this.f3239s.add(new InterfaceC0769a(this) { // from class: O.w

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ AbstractActivityC0114z f1429b;

            {
                this.f1429b = this;
            }

            @Override // z.InterfaceC0769a
            public final void accept(Object obj) {
                switch (i5) {
                    case 0:
                        this.f1429b.f1438x.u();
                        break;
                    default:
                        this.f1429b.f1438x.u();
                        break;
                }
            }
        });
        C0112x c0112x = new C0112x(this, 0);
        C0248a c0248a = this.f3229b;
        c0248a.getClass();
        if (c0248a.f3295b != null) {
            c0112x.a();
        }
        c0248a.f3294a.add(c0112x);
    }

    public static boolean j(N n4) {
        boolean zJ = false;
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : n4.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null) {
                C0113y c0113y = abstractComponentCallbacksC0109u.f1425z;
                if ((c0113y == null ? null : c0113y.f1435f) != null) {
                    zJ |= j(abstractComponentCallbacksC0109u.m());
                }
                if (abstractComponentCallbacksC0109u.f1403S.f3077c.compareTo(EnumC0222h.f3070d) >= 0) {
                    abstractComponentCallbacksC0109u.f1403S.g();
                    zJ = true;
                }
            }
        }
        return zJ;
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    /* JADX WARN: Removed duplicated region for block: B:28:0x0046  */
    @Override // android.app.Activity
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void dump(java.lang.String r4, java.io.FileDescriptor r5, java.io.PrintWriter r6, java.lang.String[] r7) {
        /*
            Method dump skipped, instruction units count: 220
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: O.AbstractActivityC0114z.dump(java.lang.String, java.io.FileDescriptor, java.io.PrintWriter, java.lang.String[]):void");
    }

    @Override // b.AbstractActivityC0234k, android.app.Activity
    public void onActivityResult(int i4, int i5, Intent intent) {
        this.f1438x.u();
        super.onActivityResult(i4, i5, intent);
    }

    @Override // b.AbstractActivityC0234k, q.i, android.app.Activity
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        this.f1439y.e(EnumC0221g.ON_CREATE);
        N n4 = ((C0113y) this.f1438x.f104b).e;
        n4.f1229G = false;
        n4.f1230H = false;
        n4.f1235N.f1273h = false;
        n4.u(1);
    }

    @Override // android.app.Activity, android.view.LayoutInflater.Factory2
    public final View onCreateView(View view, String str, Context context, AttributeSet attributeSet) {
        B b5 = (B) ((C0113y) this.f1438x.f104b).e.f1241f.onCreateView(view, str, context, attributeSet);
        return b5 == null ? super.onCreateView(view, str, context, attributeSet) : b5;
    }

    @Override // android.app.Activity
    public void onDestroy() {
        super.onDestroy();
        ((C0113y) this.f1438x.f104b).e.l();
        this.f1439y.e(EnumC0221g.ON_DESTROY);
    }

    @Override // b.AbstractActivityC0234k, android.app.Activity, android.view.Window.Callback
    public final boolean onMenuItemSelected(int i4, MenuItem menuItem) {
        if (super.onMenuItemSelected(i4, menuItem)) {
            return true;
        }
        if (i4 == 6) {
            return ((C0113y) this.f1438x.f104b).e.j();
        }
        return false;
    }

    @Override // android.app.Activity
    public final void onPause() {
        super.onPause();
        this.f1436A = false;
        ((C0113y) this.f1438x.f104b).e.u(5);
        this.f1439y.e(EnumC0221g.ON_PAUSE);
    }

    @Override // android.app.Activity
    public final void onPostResume() {
        super.onPostResume();
        this.f1439y.e(EnumC0221g.ON_RESUME);
        N n4 = ((C0113y) this.f1438x.f104b).e;
        n4.f1229G = false;
        n4.f1230H = false;
        n4.f1235N.f1273h = false;
        n4.u(7);
    }

    @Override // b.AbstractActivityC0234k, android.app.Activity
    public final void onRequestPermissionsResult(int i4, String[] strArr, int[] iArr) {
        this.f1438x.u();
        super.onRequestPermissionsResult(i4, strArr, iArr);
    }

    @Override // android.app.Activity
    public void onResume() {
        B.k kVar = this.f1438x;
        kVar.u();
        super.onResume();
        this.f1436A = true;
        ((C0113y) kVar.f104b).e.z(true);
    }

    @Override // android.app.Activity
    public final void onStart() {
        B.k kVar = this.f1438x;
        kVar.u();
        super.onStart();
        this.f1437B = false;
        boolean z4 = this.f1440z;
        C0113y c0113y = (C0113y) kVar.f104b;
        if (!z4) {
            this.f1440z = true;
            N n4 = c0113y.e;
            n4.f1229G = false;
            n4.f1230H = false;
            n4.f1235N.f1273h = false;
            n4.u(4);
        }
        c0113y.e.z(true);
        this.f1439y.e(EnumC0221g.ON_START);
        N n5 = c0113y.e;
        n5.f1229G = false;
        n5.f1230H = false;
        n5.f1235N.f1273h = false;
        n5.u(5);
    }

    @Override // android.app.Activity
    public final void onStateNotSaved() {
        this.f1438x.u();
    }

    @Override // android.app.Activity
    public final void onStop() {
        B.k kVar;
        super.onStop();
        this.f1437B = true;
        do {
            kVar = this.f1438x;
        } while (j(((C0113y) kVar.f104b).e));
        N n4 = ((C0113y) kVar.f104b).e;
        n4.f1230H = true;
        n4.f1235N.f1273h = true;
        n4.u(4);
        this.f1439y.e(EnumC0221g.ON_STOP);
    }

    @Override // android.app.Activity, android.view.LayoutInflater.Factory
    public final View onCreateView(String str, Context context, AttributeSet attributeSet) {
        B b5 = (B) ((C0113y) this.f1438x.f104b).e.f1241f.onCreateView(null, str, context, attributeSet);
        return b5 == null ? super.onCreateView(str, context, attributeSet) : b5;
    }
}
