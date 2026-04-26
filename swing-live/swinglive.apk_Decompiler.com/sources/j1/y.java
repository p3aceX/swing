package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class y extends AbstractC0458c {
    public static final Parcelable.Creator<y> CREATOR = new O(28);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5218a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5219b;

    public y(String str, String str2) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5218a = str;
        com.google.android.gms.common.internal.F.d(str2);
        this.f5219b = str2;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "twitter.com";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5218a, false);
        AbstractC0184a.i0(parcel, 2, this.f5219b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
