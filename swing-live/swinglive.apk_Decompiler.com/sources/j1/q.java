package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

/* JADX INFO: loaded from: classes.dex */
public final class q extends AbstractC0458c implements Cloneable {
    public static final Parcelable.Creator<q> CREATOR = new O(24);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5205a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5206b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f5207c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f5208d;
    public final String e;

    public q(String str, String str2, String str3, String str4, boolean z4) {
        com.google.android.gms.common.internal.F.a("Cannot create PhoneAuthCredential without either sessionInfo + smsCode or temporary proof + phoneNumber.", ((TextUtils.isEmpty(str) || TextUtils.isEmpty(str2)) && (TextUtils.isEmpty(str3) || TextUtils.isEmpty(str4))) ? false : true);
        this.f5205a = str;
        this.f5206b = str2;
        this.f5207c = str3;
        this.f5208d = z4;
        this.e = str4;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "phone";
    }

    public final Object clone() {
        boolean z4 = this.f5208d;
        return new q(this.f5205a, this.f5206b, this.f5207c, this.e, z4);
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5205a, false);
        AbstractC0184a.i0(parcel, 2, this.f5206b, false);
        AbstractC0184a.i0(parcel, 4, this.f5207c, false);
        boolean z4 = this.f5208d;
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(z4 ? 1 : 0);
        AbstractC0184a.i0(parcel, 6, this.e, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
