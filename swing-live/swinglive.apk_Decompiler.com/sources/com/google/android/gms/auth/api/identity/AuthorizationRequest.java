package com.google.android.gms.auth.api.identity;

import A0.a;
import a.AbstractC0184a;
import android.accounts.Account;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import j1.C0454D;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public class AuthorizationRequest extends a implements ReflectedParcelable {
    public static final Parcelable.Creator<AuthorizationRequest> CREATOR = new C0454D(14);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f3318a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3319b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f3320c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f3321d;
    public final Account e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f3322f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f3323m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final boolean f3324n;

    public AuthorizationRequest(ArrayList arrayList, String str, boolean z4, boolean z5, Account account, String str2, String str3, boolean z6) {
        boolean z7 = false;
        if (arrayList != null && !arrayList.isEmpty()) {
            z7 = true;
        }
        F.a("requestedScopes cannot be null or empty", z7);
        this.f3318a = arrayList;
        this.f3319b = str;
        this.f3320c = z4;
        this.f3321d = z5;
        this.e = account;
        this.f3322f = str2;
        this.f3323m = str3;
        this.f3324n = z6;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof AuthorizationRequest)) {
            return false;
        }
        AuthorizationRequest authorizationRequest = (AuthorizationRequest) obj;
        ArrayList arrayList = this.f3318a;
        return arrayList.size() == authorizationRequest.f3318a.size() && arrayList.containsAll(authorizationRequest.f3318a) && this.f3320c == authorizationRequest.f3320c && this.f3324n == authorizationRequest.f3324n && this.f3321d == authorizationRequest.f3321d && F.j(this.f3319b, authorizationRequest.f3319b) && F.j(this.e, authorizationRequest.e) && F.j(this.f3322f, authorizationRequest.f3322f) && F.j(this.f3323m, authorizationRequest.f3323m);
    }

    public final int hashCode() {
        Boolean boolValueOf = Boolean.valueOf(this.f3320c);
        Boolean boolValueOf2 = Boolean.valueOf(this.f3324n);
        Boolean boolValueOf3 = Boolean.valueOf(this.f3321d);
        return Arrays.hashCode(new Object[]{this.f3318a, this.f3319b, boolValueOf, boolValueOf2, boolValueOf3, this.e, this.f3322f, this.f3323m});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.l0(parcel, 1, this.f3318a, false);
        AbstractC0184a.i0(parcel, 2, this.f3319b, false);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f3320c ? 1 : 0);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f3321d ? 1 : 0);
        AbstractC0184a.h0(parcel, 5, this.e, i4, false);
        AbstractC0184a.i0(parcel, 6, this.f3322f, false);
        AbstractC0184a.i0(parcel, 7, this.f3323m, false);
        AbstractC0184a.o0(parcel, 8, 4);
        parcel.writeInt(this.f3324n ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
