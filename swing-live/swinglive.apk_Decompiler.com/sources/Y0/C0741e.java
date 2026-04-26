package y0;

import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.internal.AbstractC0288k;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.internal.p000authapi.zbat;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import x0.C0714b;

/* JADX INFO: renamed from: y0.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0741e extends AbstractC0288k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final GoogleSignInOptions f6822a;

    public C0741e(Context context, Looper looper, C0285h c0285h, GoogleSignInOptions googleSignInOptions, com.google.android.gms.common.api.m mVar, com.google.android.gms.common.api.n nVar) {
        super(context, looper, 91, c0285h, mVar, nVar);
        C0714b c0714b = googleSignInOptions != null ? new C0714b(googleSignInOptions) : new C0714b();
        c0714b.f6757i = zbat.zba();
        Set<Scope> set = c0285h.f3558b;
        if (!set.isEmpty()) {
            for (Scope scope : set) {
                HashSet hashSet = c0714b.f6750a;
                hashSet.add(scope);
                hashSet.addAll(Arrays.asList(new Scope[0]));
            }
        }
        this.f6822a = c0714b.a();
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final IInterface createServiceInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.auth.api.signin.internal.ISignInService");
        return iInterfaceQueryLocalInterface instanceof C0749m ? (C0749m) iInterfaceQueryLocalInterface : new C0749m(iBinder, "com.google.android.gms.auth.api.signin.internal.ISignInService");
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f, com.google.android.gms.common.api.g
    public final int getMinApkVersion() {
        return 12451000;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getServiceDescriptor() {
        return "com.google.android.gms.auth.api.signin.internal.ISignInService";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Intent getSignInIntent() {
        return AbstractC0746j.a(getContext(), this.f6822a);
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final String getStartServiceAction() {
        return "com.google.android.gms.auth.api.signin.service.START";
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final boolean providesSignIn() {
        return true;
    }
}
