package com.google.android.gms.common.api.internal;

import O.AbstractComponentCallbacksC0109u;
import O.C0113y;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Looper;
import com.google.android.gms.internal.common.zzi;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;
import java.util.WeakHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class c0 extends AbstractComponentCallbacksC0109u implements InterfaceC0263k {

    /* JADX INFO: renamed from: b0, reason: collision with root package name */
    public static final WeakHashMap f3461b0 = new WeakHashMap();

    /* JADX INFO: renamed from: Y, reason: collision with root package name */
    public final Map f3462Y = Collections.synchronizedMap(new n.b());

    /* JADX INFO: renamed from: Z, reason: collision with root package name */
    public int f3463Z = 0;

    /* JADX INFO: renamed from: a0, reason: collision with root package name */
    public Bundle f3464a0;

    @Override // O.AbstractComponentCallbacksC0109u
    public final void B() {
        this.J = true;
        this.f3463Z = 3;
        Iterator it = this.f3462Y.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onResume();
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void C(Bundle bundle) {
        for (Map.Entry entry : this.f3462Y.entrySet()) {
            Bundle bundle2 = new Bundle();
            ((LifecycleCallback) entry.getValue()).onSaveInstanceState(bundle2);
            bundle.putBundle((String) entry.getKey(), bundle2);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void D() {
        this.J = true;
        this.f3463Z = 2;
        Iterator it = this.f3462Y.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onStart();
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void E() {
        this.J = true;
        this.f3463Z = 4;
        Iterator it = this.f3462Y.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onStop();
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0263k
    public final void d(String str, LifecycleCallback lifecycleCallback) {
        Map map = this.f3462Y;
        if (map.containsKey(str)) {
            throw new IllegalArgumentException(com.google.crypto.tink.shaded.protobuf.S.g("LifecycleCallback with tag ", str, " already added to this fragment."));
        }
        map.put(str, lifecycleCallback);
        if (this.f3463Z > 0) {
            new zzi(Looper.getMainLooper()).post(new T2.r(this, lifecycleCallback, str, 2));
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0263k
    public final LifecycleCallback e(Class cls, String str) {
        return (LifecycleCallback) cls.cast(this.f3462Y.get(str));
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0263k
    public final Activity h() {
        C0113y c0113y = this.f1425z;
        if (c0113y == null) {
            return null;
        }
        return c0113y.f1432b;
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void k(String str, FileDescriptor fileDescriptor, PrintWriter printWriter, String[] strArr) {
        super.k(str, fileDescriptor, printWriter, strArr);
        Iterator it = this.f3462Y.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).dump(str, fileDescriptor, printWriter, strArr);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void u(int i4, int i5, Intent intent) {
        super.u(i4, i5, intent);
        Iterator it = this.f3462Y.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onActivityResult(i4, i5, intent);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void w(Bundle bundle) {
        Bundle bundle2;
        this.J = true;
        Bundle bundle3 = this.f1409b;
        if (bundle3 != null && (bundle2 = bundle3.getBundle("childFragmentManager")) != null) {
            this.f1386A.U(bundle2);
            O.N n4 = this.f1386A;
            n4.f1229G = false;
            n4.f1230H = false;
            n4.f1235N.f1273h = false;
            n4.u(1);
        }
        O.N n5 = this.f1386A;
        if (n5.f1256u < 1) {
            n5.f1229G = false;
            n5.f1230H = false;
            n5.f1235N.f1273h = false;
            n5.u(1);
        }
        this.f3463Z = 1;
        this.f3464a0 = bundle;
        for (Map.Entry entry : this.f3462Y.entrySet()) {
            ((LifecycleCallback) entry.getValue()).onCreate(bundle != null ? bundle.getBundle((String) entry.getKey()) : null);
        }
    }

    @Override // O.AbstractComponentCallbacksC0109u
    public final void x() {
        this.J = true;
        this.f3463Z = 5;
        Iterator it = this.f3462Y.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onDestroy();
        }
    }
}
