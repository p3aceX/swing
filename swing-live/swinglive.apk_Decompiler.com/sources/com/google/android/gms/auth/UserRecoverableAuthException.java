package com.google.android.gms.auth;

import B2.a;
import android.content.Intent;
import com.google.android.gms.common.annotation.KeepName;

/* JADX INFO: loaded from: classes.dex */
@KeepName
public class UserRecoverableAuthException extends a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Intent f3316a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3317b;

    public UserRecoverableAuthException(String str, Intent intent, int i4) {
        super(str);
        this.f3316a = intent;
        if (i4 == 0) {
            throw new NullPointerException("null reference");
        }
        this.f3317b = i4;
    }
}
