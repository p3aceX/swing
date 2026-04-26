package com.google.android.gms.common.api;

import O.O;
import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import java.util.Arrays;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class Status extends A0.a implements s, ReflectedParcelable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3377a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3378b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f3379c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final PendingIntent f3380d;
    public final C0771b e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final Status f3372f = new Status(0, null);

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final Status f3373m = new Status(14, null);

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final Status f3374n = new Status(8, null);

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final Status f3375o = new Status(15, null);

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final Status f3376p = new Status(16, null);
    public static final Parcelable.Creator<Status> CREATOR = new O(10);

    public Status(int i4, int i5, String str, PendingIntent pendingIntent, C0771b c0771b) {
        this.f3377a = i4;
        this.f3378b = i5;
        this.f3379c = str;
        this.f3380d = pendingIntent;
        this.e = c0771b;
    }

    public final boolean b() {
        return this.f3378b <= 0;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof Status)) {
            return false;
        }
        Status status = (Status) obj;
        return this.f3377a == status.f3377a && this.f3378b == status.f3378b && F.j(this.f3379c, status.f3379c) && F.j(this.f3380d, status.f3380d) && F.j(this.e, status.e);
    }

    @Override // com.google.android.gms.common.api.s
    public final Status getStatus() {
        return this;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(this.f3377a), Integer.valueOf(this.f3378b), this.f3379c, this.f3380d, this.e});
    }

    public final String toString() {
        com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r(this);
        String strL = this.f3379c;
        if (strL == null) {
            strL = AbstractC0184a.L(this.f3378b);
        }
        rVar.v(strL, "statusCode");
        rVar.v(this.f3380d, "resolution");
        return rVar.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3378b);
        AbstractC0184a.i0(parcel, 2, this.f3379c, false);
        AbstractC0184a.h0(parcel, 3, this.f3380d, i4, false);
        AbstractC0184a.h0(parcel, 4, this.e, i4, false);
        AbstractC0184a.o0(parcel, 1000, 4);
        parcel.writeInt(this.f3377a);
        AbstractC0184a.n0(iM0, parcel);
    }

    public Status(int i4, String str) {
        this(1, i4, str, null, null);
    }
}
