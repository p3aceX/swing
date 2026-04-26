package com.google.android.gms.internal.fido;

import K0.a;
import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.common.api.m;
import com.google.android.gms.common.api.n;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zzp extends AbstractC0288k {
    public zzp(Context context, Looper looper, C0285h c0285h, m mVar, n nVar) {
        super(context, looper, 148, c0285h, mVar, nVar);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final /* synthetic */ IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.fido.fido2.internal.regular.IFido2AppService");
        return iInterfaceQueryLocalInterface instanceof zzs ? (zzs) iInterfaceQueryLocalInterface : new zzs(iBinder);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final C0773d[] getApiFeatures() {
        return new C0773d[]{a.f845b, a.f844a};
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Bundle getGetServiceRequestExtraArgs() {
        Bundle bundle = new Bundle();
        bundle.putString("FIDO2_ACTION_START_SERVICE", "com.google.android.gms.fido.fido2.regular.START");
        return bundle;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 13000000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.fido.fido2.internal.regular.IFido2AppService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.fido.fido2.regular.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean usesClientTelemetry() {
        return true;
    }
}
