package com.google.android.gms.internal.p000authapi;

import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.common.api.m;
import com.google.android.gms.common.api.n;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.common.internal.r;
import s0.C0663d;

/* JADX INFO: loaded from: classes.dex */
public final class zbe extends AbstractC0288k {
    private final C0663d zba;

    public zbe(Context context, Looper looper, C0285h c0285h, C0663d c0663d, m mVar, n nVar) {
        super(context, looper, 68, c0285h, mVar, nVar);
        c0663d = c0663d == null ? C0663d.f6475c : c0663d;
        r rVar = new r(20, false);
        rVar.f3597b = Boolean.FALSE;
        C0663d c0663d2 = C0663d.f6475c;
        c0663d.getClass();
        rVar.f3597b = Boolean.valueOf(c0663d.f6476a);
        rVar.f3598c = c0663d.f6477b;
        rVar.f3598c = zbat.zba();
        this.zba = new C0663d(rVar);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final /* synthetic */ IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.auth.api.credentials.internal.ICredentialsService");
        return iInterfaceQueryLocalInterface instanceof zbf ? (zbf) iInterfaceQueryLocalInterface : new zbf(iBinder);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Bundle getGetServiceRequestExtraArgs() {
        C0663d c0663d = this.zba;
        c0663d.getClass();
        Bundle bundle = new Bundle();
        bundle.putString("consumer_package", null);
        bundle.putBoolean("force_save_dialog", c0663d.f6476a);
        bundle.putString("log_session_id", c0663d.f6477b);
        return bundle;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 12800000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.auth.api.credentials.internal.ICredentialsService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.auth.api.credentials.service.START";
    }
}
