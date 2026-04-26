package com.google.android.gms.common.internal;

import android.content.ComponentName;
import android.content.Context;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.IBinder;
import android.os.StrictMode;
import java.util.HashMap;
import java.util.Iterator;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public final class N implements ServiceConnection {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f3538a = new HashMap();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f3539b = 2;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f3540c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public IBinder f3541d;
    public final M e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ComponentName f3542f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final /* synthetic */ P f3543g;

    public N(P p4, M m4) {
        this.f3543g = p4;
        this.e = m4;
    }

    public final void a(String str, Executor executor) throws Throwable {
        this.f3539b = 3;
        StrictMode.VmPolicy vmPolicy = StrictMode.getVmPolicy();
        if (Build.VERSION.SDK_INT >= 31) {
            StrictMode.setVmPolicy(new StrictMode.VmPolicy.Builder(vmPolicy).permitUnsafeIntentLaunch().build());
        }
        try {
            P p4 = this.f3543g;
            F0.a aVar = p4.f3547g;
            Context context = p4.e;
            try {
                boolean zB = aVar.b(context, str, this.e.a(context), this, executor);
                this.f3540c = zB;
                if (zB) {
                    this.f3543g.f3546f.sendMessageDelayed(this.f3543g.f3546f.obtainMessage(1, this.e), this.f3543g.f3549i);
                } else {
                    this.f3539b = 2;
                    try {
                        P p5 = this.f3543g;
                        p5.f3547g.a(p5.e, this);
                    } catch (IllegalArgumentException unused) {
                    }
                }
                StrictMode.setVmPolicy(vmPolicy);
            } catch (Throwable th) {
                th = th;
                Throwable th2 = th;
                StrictMode.setVmPolicy(vmPolicy);
                throw th2;
            }
        } catch (Throwable th3) {
            th = th3;
        }
    }

    @Override // android.content.ServiceConnection
    public final void onBindingDied(ComponentName componentName) {
        onServiceDisconnected(componentName);
    }

    @Override // android.content.ServiceConnection
    public final void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        synchronized (this.f3543g.f3545d) {
            try {
                this.f3543g.f3546f.removeMessages(1, this.e);
                this.f3541d = iBinder;
                this.f3542f = componentName;
                Iterator it = this.f3538a.values().iterator();
                while (it.hasNext()) {
                    ((ServiceConnection) it.next()).onServiceConnected(componentName, iBinder);
                }
                this.f3539b = 1;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // android.content.ServiceConnection
    public final void onServiceDisconnected(ComponentName componentName) {
        synchronized (this.f3543g.f3545d) {
            try {
                this.f3543g.f3546f.removeMessages(1, this.e);
                this.f3541d = null;
                this.f3542f = componentName;
                Iterator it = this.f3538a.values().iterator();
                while (it.hasNext()) {
                    ((ServiceConnection) it.next()).onServiceDisconnected(componentName);
                }
                this.f3539b = 2;
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
