package com.google.android.gms.common.internal;

import android.content.Context;
import android.content.ServiceConnection;
import android.os.Looper;
import com.google.android.gms.internal.common.zzi;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public final class P extends AbstractC0289l {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final HashMap f3545d = new HashMap();
    public final Context e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public volatile zzi f3546f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final F0.a f3547g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final long f3548h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final long f3549i;

    public P(Context context, Looper looper) {
        O o4 = new O(this);
        this.e = context.getApplicationContext();
        this.f3546f = new zzi(looper, o4);
        if (F0.a.f415b == null) {
            synchronized (F0.a.f414a) {
                try {
                    if (F0.a.f415b == null) {
                        F0.a aVar = new F0.a();
                        new ConcurrentHashMap();
                        F0.a.f415b = aVar;
                    }
                } finally {
                }
            }
        }
        F0.a aVar2 = F0.a.f415b;
        F.g(aVar2);
        this.f3547g = aVar2;
        this.f3548h = 5000L;
        this.f3549i = 300000L;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0289l
    public final void b(M m4, ServiceConnection serviceConnection) {
        F.h(serviceConnection, "ServiceConnection must not be null");
        synchronized (this.f3545d) {
            try {
                N n4 = (N) this.f3545d.get(m4);
                if (n4 == null) {
                    throw new IllegalStateException("Nonexistent connection status for service config: " + m4.toString());
                }
                if (!n4.f3538a.containsKey(serviceConnection)) {
                    throw new IllegalStateException("Trying to unbind a GmsServiceConnection  that was not bound before.  config=" + m4.toString());
                }
                n4.f3538a.remove(serviceConnection);
                if (n4.f3538a.isEmpty()) {
                    this.f3546f.sendMessageDelayed(this.f3546f.obtainMessage(0, m4), this.f3548h);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // com.google.android.gms.common.internal.AbstractC0289l
    public final boolean c(M m4, ServiceConnection serviceConnection, String str, Executor executor) {
        boolean z4;
        synchronized (this.f3545d) {
            try {
                N n4 = (N) this.f3545d.get(m4);
                if (executor == null) {
                    executor = null;
                }
                if (n4 == null) {
                    n4 = new N(this, m4);
                    n4.f3538a.put(serviceConnection, serviceConnection);
                    n4.a(str, executor);
                    this.f3545d.put(m4, n4);
                } else {
                    this.f3546f.removeMessages(0, m4);
                    if (n4.f3538a.containsKey(serviceConnection)) {
                        throw new IllegalStateException("Trying to bind a GmsServiceConnection that was already connected before.  config=" + m4.toString());
                    }
                    n4.f3538a.put(serviceConnection, serviceConnection);
                    int i4 = n4.f3539b;
                    if (i4 == 1) {
                        serviceConnection.onServiceConnected(n4.f3542f, n4.f3541d);
                    } else if (i4 == 2) {
                        n4.a(str, executor);
                    }
                }
                z4 = n4.f3540c;
            } catch (Throwable th) {
                throw th;
            }
        }
        return z4;
    }
}
