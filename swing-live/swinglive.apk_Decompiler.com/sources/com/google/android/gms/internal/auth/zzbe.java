package com.google.android.gms.internal.auth;

import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import android.text.TextUtils;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import s0.AbstractC0661b;
import s0.C0662c;

/* JADX INFO: loaded from: classes.dex */
public final class zzbe extends AbstractC0288k {
    private final Bundle zze;

    public zzbe(Context context, Looper looper, C0285h c0285h, C0662c c0662c, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        super(context, looper, 16, c0285h, interfaceC0258f, interfaceC0267o);
        this.zze = c0662c == null ? new Bundle() : new Bundle(c0662c.f6474a);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final /* synthetic */ IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.auth.api.internal.IAuthService");
        return iInterfaceQueryLocalInterface instanceof zzbh ? (zzbh) iInterfaceQueryLocalInterface : new zzbh(iBinder);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Bundle getGetServiceRequestExtraArgs() {
        return this.zze;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 12451000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.auth.api.internal.IAuthService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.auth.service.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final boolean requiresSignIn() {
        C0285h clientSettings = getClientSettings();
        clientSettings.getClass();
        if (TextUtils.isEmpty(null)) {
            return false;
        }
        if (clientSettings.f3559c.get(AbstractC0661b.f6472a) == null) {
            return !clientSettings.f3557a.isEmpty();
        }
        throw new ClassCastException();
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean usesClientTelemetry() {
        return true;
    }
}
