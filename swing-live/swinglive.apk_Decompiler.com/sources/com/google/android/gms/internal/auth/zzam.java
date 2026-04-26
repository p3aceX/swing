package com.google.android.gms.internal.auth;

import android.content.Context;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.common.api.m;
import com.google.android.gms.common.api.n;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import q0.AbstractC0632f;
import r0.AbstractBinderC0652e;
import r0.C0651d;
import r0.InterfaceC0653f;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zzam extends AbstractC0288k {
    public zzam(Context context, Looper looper, C0285h c0285h, m mVar, n nVar) {
        super(context, looper, 120, c0285h, mVar, nVar);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final IInterface createServiceInterface(IBinder iBinder) {
        int i4 = AbstractBinderC0652e.f6305a;
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.auth.account.IWorkAccountService");
        return iInterfaceQueryLocalInterface instanceof InterfaceC0653f ? (InterfaceC0653f) iInterfaceQueryLocalInterface : new C0651d(iBinder, "com.google.android.gms.auth.account.IWorkAccountService");
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final C0773d[] getApiFeatures() {
        return new C0773d[]{AbstractC0632f.f6258d};
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 12451000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.auth.account.IWorkAccountService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.auth.account.workaccount.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean usesClientTelemetry() {
        return true;
    }
}
