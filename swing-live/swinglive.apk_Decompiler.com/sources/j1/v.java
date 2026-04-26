package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class v extends AbstractC0458c {
    public static final Parcelable.Creator<v> CREATOR = new O(26);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5213a;

    public v(String str) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5213a = str;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "playgames.google.com";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5213a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
