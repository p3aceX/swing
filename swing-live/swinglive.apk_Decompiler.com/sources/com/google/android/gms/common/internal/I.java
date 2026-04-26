package com.google.android.gms.common.internal;

import android.content.ComponentName;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.IInterface;

/* JADX INFO: loaded from: classes.dex */
public final class I implements ServiceConnection {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3525a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ AbstractC0283f f3526b;

    public I(AbstractC0283f abstractC0283f, int i4) {
        this.f3526b = abstractC0283f;
        this.f3525a = i4;
    }

    @Override // android.content.ServiceConnection
    public final void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        AbstractC0283f abstractC0283f = this.f3526b;
        if (iBinder == null) {
            AbstractC0283f.zzk(abstractC0283f, 16);
            return;
        }
        synchronized (abstractC0283f.zzq) {
            try {
                AbstractC0283f abstractC0283f2 = this.f3526b;
                IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.common.internal.IGmsServiceBroker");
                abstractC0283f2.zzr = (iInterfaceQueryLocalInterface == null || !(iInterfaceQueryLocalInterface instanceof InterfaceC0292o)) ? new E(iBinder) : (InterfaceC0292o) iInterfaceQueryLocalInterface;
            } catch (Throwable th) {
                throw th;
            }
        }
        this.f3526b.zzl(0, null, this.f3525a);
    }

    @Override // android.content.ServiceConnection
    public final void onServiceDisconnected(ComponentName componentName) {
        synchronized (this.f3526b.zzq) {
            this.f3526b.zzr = null;
        }
        Handler handler = this.f3526b.zzb;
        handler.sendMessage(handler.obtainMessage(6, this.f3525a, 1));
    }
}
