package com.google.android.gms.common.internal;

import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.RemoteException;
import android.util.Log;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class J extends C {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final IBinder f3527g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final /* synthetic */ AbstractC0283f f3528h;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public J(AbstractC0283f abstractC0283f, int i4, IBinder iBinder, Bundle bundle) {
        super(abstractC0283f, i4, bundle);
        this.f3528h = abstractC0283f;
        this.f3527g = iBinder;
    }

    @Override // com.google.android.gms.common.internal.C
    public final void a(C0771b c0771b) {
        AbstractC0283f abstractC0283f = this.f3528h;
        if (abstractC0283f.zzx != null) {
            ((InterfaceC0267o) ((t) abstractC0283f.zzx).f3601a).a(c0771b);
        }
        abstractC0283f.onConnectionFailed(c0771b);
    }

    @Override // com.google.android.gms.common.internal.C
    public final boolean b() {
        IBinder iBinder = this.f3527g;
        try {
            F.g(iBinder);
            String interfaceDescriptor = iBinder.getInterfaceDescriptor();
            AbstractC0283f abstractC0283f = this.f3528h;
            if (!abstractC0283f.getServiceDescriptor().equals(interfaceDescriptor)) {
                Log.w("GmsClient", "service descriptor mismatch: " + abstractC0283f.getServiceDescriptor() + " vs. " + interfaceDescriptor);
                return false;
            }
            IInterface iInterfaceCreateServiceInterface = abstractC0283f.createServiceInterface(iBinder);
            if (iInterfaceCreateServiceInterface == null || !(AbstractC0283f.zzn(abstractC0283f, 2, 4, iInterfaceCreateServiceInterface) || AbstractC0283f.zzn(abstractC0283f, 3, 4, iInterfaceCreateServiceInterface))) {
                return false;
            }
            abstractC0283f.zzB = null;
            abstractC0283f.getConnectionHint();
            if (abstractC0283f.zzw == null) {
                return true;
            }
            ((InterfaceC0258f) ((t) abstractC0283f.zzw).f3601a).d();
            return true;
        } catch (RemoteException unused) {
            Log.w("GmsClient", "service probably died");
            return false;
        }
    }
}
