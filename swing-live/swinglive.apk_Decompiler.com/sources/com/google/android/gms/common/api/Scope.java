package com.google.android.gms.common.api;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;

/* JADX INFO: loaded from: classes.dex */
public final class Scope extends A0.a implements ReflectedParcelable {
    public static final Parcelable.Creator<Scope> CREATOR = new O(9);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3370a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3371b;

    public Scope(int i4, String str) {
        F.e(str, "scopeUri must not be null or empty");
        this.f3370a = i4;
        this.f3371b = str;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof Scope)) {
            return false;
        }
        return this.f3371b.equals(((Scope) obj).f3371b);
    }

    public final int hashCode() {
        return this.f3371b.hashCode();
    }

    public final String toString() {
        return this.f3371b;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3370a);
        AbstractC0184a.i0(parcel, 2, this.f3371b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
