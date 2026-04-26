package com.google.android.gms.common.api.internal;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.util.SparseIntArray;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.internal.base.zaq;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicReference;
import z0.C0771b;
import z0.C0774e;

/* JADX INFO: loaded from: classes.dex */
public final class E implements com.google.android.gms.common.api.m, com.google.android.gms.common.api.n {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final com.google.android.gms.common.api.g f3394b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0253a f3395c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0276y f3396d;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f3398g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final O f3399h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f3400i;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0259g f3404m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final LinkedList f3393a = new LinkedList();
    public final HashSet e = new HashSet();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final HashMap f3397f = new HashMap();

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final ArrayList f3401j = new ArrayList();

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public C0771b f3402k = null;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f3403l = 0;

    public E(C0259g c0259g, com.google.android.gms.common.api.l lVar) {
        this.f3404m = c0259g;
        com.google.android.gms.common.api.g gVarZab = lVar.zab(c0259g.f3481n.getLooper(), this);
        this.f3394b = gVarZab;
        this.f3395c = lVar.getApiKey();
        this.f3396d = new C0276y();
        this.f3398g = lVar.zaa();
        if (!gVarZab.requiresSignIn()) {
            this.f3399h = null;
        } else {
            this.f3399h = lVar.zac(c0259g.e, c0259g.f3481n);
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0267o
    public final void a(C0771b c0771b) {
        p(c0771b, null);
    }

    public final void b(C0771b c0771b) {
        HashSet hashSet = this.e;
        Iterator it = hashSet.iterator();
        if (!it.hasNext()) {
            hashSet.clear();
        } else {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (com.google.android.gms.common.internal.F.j(c0771b, C0771b.e)) {
                this.f3394b.getEndpointPackageName();
            }
            throw null;
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0258f
    public final void c(int i4) {
        Looper looperMyLooper = Looper.myLooper();
        C0259g c0259g = this.f3404m;
        if (looperMyLooper == c0259g.f3481n.getLooper()) {
            i(i4);
        } else {
            c0259g.f3481n.post(new D(this, i4));
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0258f
    public final void d() {
        Looper looperMyLooper = Looper.myLooper();
        C0259g c0259g = this.f3404m;
        if (looperMyLooper == c0259g.f3481n.getLooper()) {
            h();
        } else {
            c0259g.f3481n.post(new F.b(this, 9));
        }
    }

    public final void e(Status status) {
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        f(status, null, false);
    }

    public final void f(Status status, RuntimeException runtimeException, boolean z4) {
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        if ((status == null) == (runtimeException == null)) {
            throw new IllegalArgumentException("Status XOR exception should be null");
        }
        Iterator it = this.f3393a.iterator();
        while (it.hasNext()) {
            X x4 = (X) it.next();
            if (!z4 || x4.f3443a == 2) {
                if (status != null) {
                    x4.a(status);
                } else {
                    x4.b(runtimeException);
                }
                it.remove();
            }
        }
    }

    public final void g() {
        LinkedList linkedList = this.f3393a;
        ArrayList arrayList = new ArrayList(linkedList);
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            X x4 = (X) arrayList.get(i4);
            if (!this.f3394b.isConnected()) {
                return;
            }
            if (k(x4)) {
                linkedList.remove(x4);
            }
        }
    }

    public final void h() {
        C0259g c0259g = this.f3404m;
        com.google.android.gms.common.internal.F.c(c0259g.f3481n);
        this.f3402k = null;
        b(C0771b.e);
        if (this.f3400i) {
            zaq zaqVar = c0259g.f3481n;
            C0253a c0253a = this.f3395c;
            zaqVar.removeMessages(11, c0253a);
            c0259g.f3481n.removeMessages(9, c0253a);
            this.f3400i = false;
        }
        Iterator it = this.f3397f.values().iterator();
        if (it.hasNext()) {
            it.next().getClass();
            throw new ClassCastException();
        }
        g();
        j();
    }

    public final void i(int i4) {
        C0259g c0259g = this.f3404m;
        com.google.android.gms.common.internal.F.c(c0259g.f3481n);
        this.f3402k = null;
        this.f3400i = true;
        String lastDisconnectMessage = this.f3394b.getLastDisconnectMessage();
        C0276y c0276y = this.f3396d;
        c0276y.getClass();
        StringBuilder sb = new StringBuilder("The connection to Google Play services was lost");
        if (i4 == 1) {
            sb.append(" due to service disconnection.");
        } else if (i4 == 3) {
            sb.append(" due to dead object exception.");
        }
        if (lastDisconnectMessage != null) {
            sb.append(" Last reason for disconnect: ");
            sb.append(lastDisconnectMessage);
        }
        c0276y.a(new Status(20, sb.toString()), true);
        zaq zaqVar = c0259g.f3481n;
        C0253a c0253a = this.f3395c;
        zaqVar.sendMessageDelayed(Message.obtain(zaqVar, 9, c0253a), 5000L);
        zaq zaqVar2 = c0259g.f3481n;
        zaqVar2.sendMessageDelayed(Message.obtain(zaqVar2, 11, c0253a), 120000L);
        ((SparseIntArray) c0259g.f3474g.f3597b).clear();
        Iterator it = this.f3397f.values().iterator();
        if (it.hasNext()) {
            B1.a.p(it.next());
            throw null;
        }
    }

    public final void j() {
        C0259g c0259g = this.f3404m;
        zaq zaqVar = c0259g.f3481n;
        C0253a c0253a = this.f3395c;
        zaqVar.removeMessages(12, c0253a);
        zaq zaqVar2 = c0259g.f3481n;
        zaqVar2.sendMessageDelayed(zaqVar2.obtainMessage(12, c0253a), c0259g.f3469a);
    }

    /* JADX WARN: Removed duplicated region for block: B:29:0x0075  */
    /* JADX WARN: Removed duplicated region for block: B:34:0x008b  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean k(com.google.android.gms.common.api.internal.X r15) {
        /*
            Method dump skipped, instruction units count: 342
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.common.api.internal.E.k(com.google.android.gms.common.api.internal.X):boolean");
    }

    public final boolean l(C0771b c0771b) {
        synchronized (C0259g.f3467r) {
            try {
                C0259g c0259g = this.f3404m;
                if (c0259g.f3478k == null || !c0259g.f3479l.contains(this.f3395c)) {
                    return false;
                }
                DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z = this.f3404m.f3478k;
                int i4 = this.f3398g;
                dialogInterfaceOnCancelListenerC0277z.getClass();
                Y y4 = new Y(c0771b, i4);
                AtomicReference atomicReference = dialogInterfaceOnCancelListenerC0277z.f3495b;
                while (true) {
                    if (atomicReference.compareAndSet(null, y4)) {
                        dialogInterfaceOnCancelListenerC0277z.f3496c.post(new Z(0, dialogInterfaceOnCancelListenerC0277z, y4));
                        break;
                    }
                    if (atomicReference.get() != null) {
                        break;
                    }
                }
                return true;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final boolean m(boolean z4) {
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        com.google.android.gms.common.api.g gVar = this.f3394b;
        if (gVar.isConnected() && this.f3397f.size() == 0) {
            C0276y c0276y = this.f3396d;
            if (((Map) c0276y.f3492a).isEmpty() && ((Map) c0276y.f3493b).isEmpty()) {
                gVar.disconnect("Timing out service connection.");
                return true;
            }
            if (z4) {
                j();
            }
        }
        return false;
    }

    public final void n() {
        C0259g c0259g = this.f3404m;
        com.google.android.gms.common.internal.F.c(c0259g.f3481n);
        com.google.android.gms.common.api.g gVar = this.f3394b;
        if (gVar.isConnected() || gVar.isConnecting()) {
            return;
        }
        try {
            com.google.android.gms.common.internal.r rVar = c0259g.f3474g;
            Context context = c0259g.e;
            rVar.getClass();
            com.google.android.gms.common.internal.F.g(context);
            int iC = 0;
            if (gVar.requiresGooglePlayServices()) {
                int minApkVersion = gVar.getMinApkVersion();
                SparseIntArray sparseIntArray = (SparseIntArray) rVar.f3597b;
                int i4 = sparseIntArray.get(minApkVersion, -1);
                if (i4 != -1) {
                    iC = i4;
                } else {
                    int i5 = 0;
                    while (true) {
                        if (i5 >= sparseIntArray.size()) {
                            iC = -1;
                            break;
                        }
                        int iKeyAt = sparseIntArray.keyAt(i5);
                        if (iKeyAt > minApkVersion && sparseIntArray.get(iKeyAt) == 0) {
                            break;
                        } else {
                            i5++;
                        }
                    }
                    if (iC == -1) {
                        iC = ((C0774e) rVar.f3598c).c(context, minApkVersion);
                    }
                    sparseIntArray.put(minApkVersion, iC);
                }
            }
            if (iC != 0) {
                C0771b c0771b = new C0771b(iC, null);
                String name = gVar.getClass().getName();
                String string = c0771b.toString();
                StringBuilder sb = new StringBuilder(name.length() + 35 + string.length());
                sb.append("The service for ");
                sb.append(name);
                sb.append(" is not available: ");
                sb.append(string);
                Log.w("GoogleApiManager", sb.toString());
                p(c0771b, null);
                return;
            }
            G g4 = new G(c0259g, gVar, this.f3395c);
            if (gVar.requiresSignIn()) {
                O o4 = this.f3399h;
                com.google.android.gms.common.internal.F.g(o4);
                P0.a aVar = o4.f3431f;
                if (aVar != null) {
                    aVar.disconnect();
                }
                Integer numValueOf = Integer.valueOf(System.identityHashCode(o4));
                C0285h c0285h = o4.e;
                c0285h.f3562g = numValueOf;
                Handler handler = o4.f3428b;
                o4.f3431f = (P0.a) o4.f3429c.buildClient(o4.f3427a, handler.getLooper(), c0285h, (Object) c0285h.f3561f, (com.google.android.gms.common.api.m) o4, (com.google.android.gms.common.api.n) o4);
                o4.f3432g = g4;
                Set set = o4.f3430d;
                if (set == null || set.isEmpty()) {
                    handler.post(new F.b(o4, 11));
                } else {
                    P0.a aVar2 = o4.f3431f;
                    aVar2.getClass();
                    aVar2.connect(new com.google.android.gms.common.internal.t(aVar2));
                }
            }
            try {
                gVar.connect(g4);
            } catch (SecurityException e) {
                p(new C0771b(10), e);
            }
        } catch (IllegalStateException e4) {
            p(new C0771b(10), e4);
        }
    }

    public final void o(X x4) {
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        boolean zIsConnected = this.f3394b.isConnected();
        LinkedList linkedList = this.f3393a;
        if (zIsConnected) {
            if (k(x4)) {
                j();
                return;
            } else {
                linkedList.add(x4);
                return;
            }
        }
        linkedList.add(x4);
        C0771b c0771b = this.f3402k;
        if (c0771b == null || c0771b.f6949b == 0 || c0771b.f6950c == null) {
            n();
        } else {
            p(c0771b, null);
        }
    }

    public final void p(C0771b c0771b, RuntimeException runtimeException) {
        P0.a aVar;
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        O o4 = this.f3399h;
        if (o4 != null && (aVar = o4.f3431f) != null) {
            aVar.disconnect();
        }
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        this.f3402k = null;
        ((SparseIntArray) this.f3404m.f3474g.f3597b).clear();
        b(c0771b);
        if ((this.f3394b instanceof B0.d) && c0771b.f6949b != 24) {
            C0259g c0259g = this.f3404m;
            c0259g.f3470b = true;
            zaq zaqVar = c0259g.f3481n;
            zaqVar.sendMessageDelayed(zaqVar.obtainMessage(19), 300000L);
        }
        if (c0771b.f6949b == 4) {
            e(C0259g.f3466q);
            return;
        }
        if (this.f3393a.isEmpty()) {
            this.f3402k = c0771b;
            return;
        }
        if (runtimeException != null) {
            com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
            f(null, runtimeException, false);
            return;
        }
        if (!this.f3404m.f3482o) {
            e(C0259g.e(this.f3395c, c0771b));
            return;
        }
        f(C0259g.e(this.f3395c, c0771b), null, true);
        if (this.f3393a.isEmpty() || l(c0771b) || this.f3404m.d(c0771b, this.f3398g)) {
            return;
        }
        if (c0771b.f6949b == 18) {
            this.f3400i = true;
        }
        if (!this.f3400i) {
            e(C0259g.e(this.f3395c, c0771b));
            return;
        }
        zaq zaqVar2 = this.f3404m.f3481n;
        Message messageObtain = Message.obtain(zaqVar2, 9, this.f3395c);
        this.f3404m.getClass();
        zaqVar2.sendMessageDelayed(messageObtain, 5000L);
    }

    public final void q() {
        com.google.android.gms.common.internal.F.c(this.f3404m.f3481n);
        Status status = C0259g.f3465p;
        e(status);
        this.f3396d.a(status, false);
        for (AbstractC0264l abstractC0264l : (AbstractC0264l[]) this.f3397f.keySet().toArray(new AbstractC0264l[0])) {
            o(new W(4, new TaskCompletionSource()));
        }
        b(new C0771b(4));
        com.google.android.gms.common.api.g gVar = this.f3394b;
        if (gVar.isConnected()) {
            gVar.onUserSignOut(new B.k(this, 19));
        }
    }
}
