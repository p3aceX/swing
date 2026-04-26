package com.google.android.gms.internal.auth;

import android.content.Context;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import android.util.Log;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import q0.AbstractC0632f;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
final class zzi extends AbstractC0288k {
    public zzi(Context context, Looper looper, C0285h c0285h, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        super(context, looper, 224, c0285h, interfaceC0258f, interfaceC0267o);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final /* synthetic */ IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.auth.account.data.IGoogleAuthService");
        return iInterfaceQueryLocalInterface instanceof zzp ? (zzp) iInterfaceQueryLocalInterface : new zzp(iBinder);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final void disconnect(String str) {
        Log.w("GoogleAuthSvcClientImpl", "GoogleAuthServiceClientImpl disconnected with reason: ".concat(String.valueOf(str)));
        super.disconnect(str);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final C0773d[] getApiFeatures() {
        return new C0773d[]{AbstractC0632f.f6257c, AbstractC0632f.f6256b, AbstractC0632f.f6255a};
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 17895000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.auth.account.data.IGoogleAuthService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.auth.account.authapi.START";
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
