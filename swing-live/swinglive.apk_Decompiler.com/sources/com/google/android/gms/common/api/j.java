package com.google.android.gms.common.api;

/* JADX INFO: loaded from: classes.dex */
public class j extends Exception {

    @Deprecated
    protected final Status mStatus;

    /* JADX WARN: Illegal instructions before constructor call */
    public j(Status status) {
        int i4 = status.f3378b;
        String str = status.f3379c;
        super(i4 + ": " + (str == null ? "" : str));
        this.mStatus = status;
    }

    public Status getStatus() {
        return this.mStatus;
    }

    public int getStatusCode() {
        return this.mStatus.f3378b;
    }

    @Deprecated
    public String getStatusMessage() {
        return this.mStatus.f3379c;
    }
}
