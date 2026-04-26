package com.google.android.gms.internal.p000authapi;

import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import u0.o;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zbg extends AbstractC0288k {
    private final Bundle zba;

    public zbg(Context context, Looper looper, o oVar, C0285h c0285h, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        super(context, looper, 219, c0285h, interfaceC0258f, interfaceC0267o);
        oVar.getClass();
        Bundle bundle = new Bundle();
        bundle.putString("session_id", oVar.f6634a);
        this.zba = bundle;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final /* synthetic */ IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.auth.api.identity.internal.IAuthorizationService");
        return iInterfaceQueryLocalInterface instanceof zbk ? (zbk) iInterfaceQueryLocalInterface : new zbk(iBinder);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final C0773d[] getApiFeatures() {
        return zbas.zbi;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Bundle getGetServiceRequestExtraArgs() {
        return this.zba;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 17895000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.auth.api.identity.internal.IAuthorizationService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.auth.api.identity.service.authorization.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean getUseDynamicLookup() {
        return true;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean usesClientTelemetry() {
        return true;
    }
}
