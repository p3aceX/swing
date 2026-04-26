package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class m extends AbstractC0458c {
    public static final Parcelable.Creator<m> CREATOR = new O(22);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5202a;

    public m(String str) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5202a = str;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "github.com";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5202a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
