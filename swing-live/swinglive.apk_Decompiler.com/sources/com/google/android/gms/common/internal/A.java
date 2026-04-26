package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.accounts.Account;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;

/* JADX INFO: loaded from: classes.dex */
public final class A extends A0.a {
    public static final Parcelable.Creator<A> CREATOR = new O.O(13);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3505a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Account f3506b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3507c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final GoogleSignInAccount f3508d;

    public A(int i4, Account account, int i5, GoogleSignInAccount googleSignInAccount) {
        this.f3505a = i4;
        this.f3506b = account;
        this.f3507c = i5;
        this.f3508d = googleSignInAccount;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3505a);
        AbstractC0184a.h0(parcel, 2, this.f3506b, i4, false);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f3507c);
        AbstractC0184a.h0(parcel, 4, this.f3508d, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
