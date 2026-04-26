package com.google.android.gms.auth.api.signin;

import A0.a;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import x0.e;

/* JADX INFO: loaded from: classes.dex */
public class SignInAccount extends a implements ReflectedParcelable {
    public static final Parcelable.Creator<SignInAccount> CREATOR = new e(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f3357a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final GoogleSignInAccount f3358b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f3359c;

    public SignInAccount(String str, GoogleSignInAccount googleSignInAccount, String str2) {
        this.f3358b = googleSignInAccount;
        F.e(str, "8.3 and 8.4 SDKs require non-null email");
        this.f3357a = str;
        F.e(str2, "8.3 and 8.4 SDKs require non-null userId");
        this.f3359c = str2;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 4, this.f3357a, false);
        AbstractC0184a.h0(parcel, 7, this.f3358b, i4, false);
        AbstractC0184a.i0(parcel, 8, this.f3359c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
