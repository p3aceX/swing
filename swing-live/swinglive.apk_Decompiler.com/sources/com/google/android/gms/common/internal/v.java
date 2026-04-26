package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class v extends A0.a {
    public static final Parcelable.Creator<v> CREATOR = new O.O(11);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3606a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public List f3607b;

    public v(int i4, List list) {
        this.f3606a = i4;
        this.f3607b = list;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3606a);
        AbstractC0184a.l0(parcel, 2, this.f3607b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
