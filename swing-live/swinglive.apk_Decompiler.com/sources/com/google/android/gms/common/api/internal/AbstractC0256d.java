package com.google.android.gms.common.api.internal;

import android.os.DeadObjectException;
import android.os.RemoteException;
import com.google.android.gms.common.api.Status;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0256d extends BasePendingResult {
    private final com.google.android.gms.common.api.i mApi;
    private final com.google.android.gms.common.api.c mClientKey;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public AbstractC0256d(com.google.android.gms.common.api.i iVar, com.google.android.gms.common.api.o oVar) {
        super(oVar);
        com.google.android.gms.common.internal.F.h(oVar, "GoogleApiClient must not be null");
        com.google.android.gms.common.internal.F.h(iVar, "Api must not be null");
        this.mClientKey = iVar.f3383b;
        this.mApi = iVar;
    }

    public abstract void doExecute(com.google.android.gms.common.api.b bVar);

    public final com.google.android.gms.common.api.i getApi() {
        return this.mApi;
    }

    public final com.google.android.gms.common.api.c getClientKey() {
        return this.mClientKey;
    }

    public void onSetFailedResult(com.google.android.gms.common.api.s sVar) {
    }

    public final void run(com.google.android.gms.common.api.b bVar) throws DeadObjectException {
        try {
            doExecute(bVar);
        } catch (DeadObjectException e) {
            setFailedResult(new Status(1, 8, e.getLocalizedMessage(), null, null));
            throw e;
        } catch (RemoteException e4) {
            setFailedResult(new Status(1, 8, e4.getLocalizedMessage(), null, null));
        }
    }

    public final void setFailedResult(Status status) {
        com.google.android.gms.common.internal.F.a("Failed result must not be success", !status.b());
        com.google.android.gms.common.api.s sVarCreateFailedResult = createFailedResult(status);
        setResult(sVarCreateFailedResult);
        onSetFailedResult(sVarCreateFailedResult);
    }
}
