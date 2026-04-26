package com.google.android.gms.common.internal;

import android.accounts.Account;
import android.content.Context;
import android.os.Looper;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import java.util.Collections;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.Executor;
import z0.C0773d;
import z0.C0774e;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0288k extends AbstractC0283f implements com.google.android.gms.common.api.g {
    private static volatile Executor zaa;
    private final C0285h zab;
    private final Set<Scope> zac;
    private final Account zad;

    /* JADX WARN: Illegal instructions before constructor call */
    public AbstractC0288k(Context context, Looper looper, int i4, C0285h c0285h, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        P pA = AbstractC0289l.a(context);
        Object obj = C0774e.f6958c;
        F.g(interfaceC0258f);
        F.g(interfaceC0267o);
        super(context, looper, pA, i4, new t(interfaceC0258f), new t(interfaceC0267o), c0285h.e);
        this.zab = c0285h;
        this.zad = null;
        Set<Scope> set = c0285h.f3558b;
        Set<Scope> setValidateScopes = validateScopes(set);
        Iterator<Scope> it = setValidateScopes.iterator();
        while (it.hasNext()) {
            if (!set.contains(it.next())) {
                throw new IllegalStateException("Expanding scopes is not permitted, use implied scopes instead");
            }
        }
        this.zac = setValidateScopes;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Account getAccount() {
        return this.zad;
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Executor getBindServiceExecutor() {
        return null;
    }

    public final C0285h getClientSettings() {
        return this.zab;
    }

    public C0773d[] getRequiredFeatures() {
        return new C0773d[0];
    }

    @Override // com.google.android.gms.common.internal.AbstractC0283f
    public final Set<Scope> getScopes() {
        return this.zac;
    }

    @Override // com.google.android.gms.common.api.g
    public Set<Scope> getScopesForConnectionlessNonSignIn() {
        return requiresSignIn() ? this.zac : Collections.EMPTY_SET;
    }

    public Set<Scope> validateScopes(Set<Scope> set) {
        return set;
    }
}
