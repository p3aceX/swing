package com.google.android.gms.internal.auth;

import android.accounts.Account;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.H;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.q;
import r0.AbstractC0648a;

/* JADX INFO: loaded from: classes.dex */
public final class zzal {
    private static final Status zza = new Status(13, null);

    public final q addWorkAccount(o oVar, String str) {
        return ((H) oVar).f3412b.doWrite(new zzae(this, AbstractC0648a.f6304a, oVar, str));
    }

    public final q removeWorkAccount(o oVar, Account account) {
        return ((H) oVar).f3412b.doWrite(new zzag(this, AbstractC0648a.f6304a, oVar, account));
    }

    public final void setWorkAuthenticatorEnabled(o oVar, boolean z4) {
        setWorkAuthenticatorEnabledWithResult(oVar, z4);
    }

    public final q setWorkAuthenticatorEnabledWithResult(o oVar, boolean z4) {
        return ((H) oVar).f3412b.doWrite(new zzac(this, AbstractC0648a.f6304a, oVar, z4));
    }
}
