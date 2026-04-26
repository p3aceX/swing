package B0;

import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.common.internal.w;
import com.google.android.gms.internal.base.zad;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class d extends AbstractC0288k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final w f107a;

    public d(Context context, Looper looper, C0285h c0285h, w wVar, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        super(context, looper, 270, c0285h, interfaceC0258f, interfaceC0267o);
        this.f107a = wVar;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.common.internal.service.IClientTelemetryService");
        return iInterfaceQueryLocalInterface instanceof a ? (a) iInterfaceQueryLocalInterface : new a(iBinder, "com.google.android.gms.common.internal.service.IClientTelemetryService");
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final C0773d[] getApiFeatures() {
        return zad.zab;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Bundle getGetServiceRequestExtraArgs() {
        this.f107a.getClass();
        return new Bundle();
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 203400000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.common.internal.service.IClientTelemetryService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.common.telemetry.service.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean getUseDynamicLookup() {
        return true;
    }
}
