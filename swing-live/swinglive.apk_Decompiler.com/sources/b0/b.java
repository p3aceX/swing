package B0;

import K.k;
import android.content.Context;
import android.os.Bundle;
import android.os.Looper;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.g;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.api.m;
import com.google.android.gms.common.api.n;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.common.internal.w;
import com.google.android.gms.internal.auth.zzam;
import com.google.android.gms.internal.auth.zzbe;
import com.google.android.gms.internal.p000authapi.zbe;
import com.google.android.gms.internal.p001authapiphone.zzw;
import java.util.Collections;
import java.util.List;
import s0.C0662c;
import s0.C0663d;
import y0.C0741e;

/* JADX INFO: loaded from: classes.dex */
public final class b extends com.google.android.gms.common.api.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f105a;

    public /* synthetic */ b(int i4) {
        this.f105a = i4;
    }

    @Override // com.google.android.gms.common.api.a
    public g buildClient(Context context, Looper looper, C0285h c0285h, Object obj, m mVar, n nVar) {
        switch (this.f105a) {
            case 1:
                c0285h.getClass();
                Integer num = c0285h.f3562g;
                Bundle bundle = new Bundle();
                bundle.putParcelable("com.google.android.gms.signin.internal.clientRequestedAccount", null);
                if (num != null) {
                    bundle.putInt("com.google.android.gms.common.internal.ClientSettings.sessionId", num.intValue());
                }
                bundle.putBoolean("com.google.android.gms.signin.internal.offlineAccessRequested", false);
                bundle.putBoolean("com.google.android.gms.signin.internal.idTokenRequested", false);
                bundle.putString("com.google.android.gms.signin.internal.serverClientId", null);
                bundle.putBoolean("com.google.android.gms.signin.internal.usePromptModeForAuthCode", true);
                bundle.putBoolean("com.google.android.gms.signin.internal.forceCodeForRefreshToken", false);
                bundle.putString("com.google.android.gms.signin.internal.hostedDomain", null);
                bundle.putString("com.google.android.gms.signin.internal.logSessionId", null);
                bundle.putBoolean("com.google.android.gms.signin.internal.waitForAccessTokenRefresh", false);
                return new P0.a(context, looper, c0285h, bundle, mVar, nVar);
            case 2:
                obj.getClass();
                throw new ClassCastException();
            case 3:
                return new zzam(context, looper, c0285h, mVar, nVar);
            case 4:
                return new zbe(context, looper, c0285h, (C0663d) obj, mVar, nVar);
            case 5:
                return new C0741e(context, looper, c0285h, (GoogleSignInOptions) obj, mVar, nVar);
            default:
                return super.buildClient(context, looper, c0285h, obj, mVar, nVar);
        }
    }

    @Override // com.google.android.gms.common.api.f
    public /* bridge */ /* synthetic */ List getImpliedScopes(Object obj) {
        switch (this.f105a) {
            case 5:
                GoogleSignInOptions googleSignInOptions = (GoogleSignInOptions) obj;
                return googleSignInOptions == null ? Collections.EMPTY_LIST : googleSignInOptions.b();
            default:
                return super.getImpliedScopes(obj);
        }
    }

    @Override // com.google.android.gms.common.api.a
    public /* synthetic */ g buildClient(Context context, Looper looper, C0285h c0285h, Object obj, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        switch (this.f105a) {
            case 0:
                return new d(context, looper, c0285h, (w) obj, interfaceC0258f, interfaceC0267o);
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return new zzbe(context, looper, c0285h, (C0662c) obj, interfaceC0258f, interfaceC0267o);
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return new zzw(context, looper, c0285h, interfaceC0258f, interfaceC0267o);
            default:
                return super.buildClient(context, looper, c0285h, obj, interfaceC0258f, interfaceC0267o);
        }
    }
}
