package com.google.android.gms.auth;

import A0.a;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import j1.C0454D;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public class TokenData extends a implements ReflectedParcelable {
    public static final Parcelable.Creator<TokenData> CREATOR = new C0454D(8);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3310a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3311b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Long f3312c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f3313d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ArrayList f3314f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f3315m;

    public TokenData(int i4, String str, Long l2, boolean z4, boolean z5, ArrayList arrayList, String str2) {
        this.f3310a = i4;
        F.d(str);
        this.f3311b = str;
        this.f3312c = l2;
        this.f3313d = z4;
        this.e = z5;
        this.f3314f = arrayList;
        this.f3315m = str2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof TokenData)) {
            return false;
        }
        TokenData tokenData = (TokenData) obj;
        return TextUtils.equals(this.f3311b, tokenData.f3311b) && F.j(this.f3312c, tokenData.f3312c) && this.f3313d == tokenData.f3313d && this.e == tokenData.e && F.j(this.f3314f, tokenData.f3314f) && F.j(this.f3315m, tokenData.f3315m);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f3311b, this.f3312c, Boolean.valueOf(this.f3313d), Boolean.valueOf(this.e), this.f3314f, this.f3315m});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3310a);
        AbstractC0184a.i0(parcel, 2, this.f3311b, false);
        AbstractC0184a.g0(parcel, 3, this.f3312c);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f3313d ? 1 : 0);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e ? 1 : 0);
        AbstractC0184a.j0(parcel, 6, this.f3314f);
        AbstractC0184a.i0(parcel, 7, this.f3315m, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
