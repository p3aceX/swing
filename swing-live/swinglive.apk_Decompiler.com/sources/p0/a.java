package P0;

import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.common.api.m;
import com.google.android.gms.common.api.n;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;

/* JADX INFO: loaded from: classes.dex */
public final class a extends AbstractC0288k implements com.google.android.gms.common.api.g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f1476a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0285h f1477b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Bundle f1478c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Integer f1479d;

    public a(Context context, Looper looper, C0285h c0285h, Bundle bundle, m mVar, n nVar) {
        super(context, looper, 44, c0285h, mVar, nVar);
        this.f1476a = true;
        this.f1477b = c0285h;
        this.f1478c = bundle;
        this.f1479d = c0285h.f3562g;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.signin.internal.ISignInService");
        return iInterfaceQueryLocalInterface instanceof d ? (d) iInterfaceQueryLocalInterface : new d(iBinder, "com.google.android.gms.signin.internal.ISignInService");
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Bundle getGetServiceRequestExtraArgs() {
        C0285h c0285h = this.f1477b;
        boolean zEquals = getContext().getPackageName().equals(c0285h.f3560d);
        Bundle bundle = this.f1478c;
        if (!zEquals) {
            bundle.putString("com.google.android.gms.signin.internal.realClientPackageName", c0285h.f3560d);
        }
        return bundle;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 12451000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.signin.internal.ISignInService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.signin.service.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final boolean requiresSignIn() {
        return this.f1476a;
    }
}
