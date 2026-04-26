package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class n extends AbstractC0458c {
    public static final Parcelable.Creator<n> CREATOR = new O(23);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5203a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5204b;

    public n(String str, String str2) {
        if (str == null && str2 == null) {
            throw new IllegalArgumentException("Must specify an idToken or an accessToken.");
        }
        if (str != null && str.length() == 0) {
            throw new IllegalArgumentException("idToken cannot be empty");
        }
        if (str2 != null && str2.length() == 0) {
            throw new IllegalArgumentException("accessToken cannot be empty");
        }
        this.f5203a = str;
        this.f5204b = str2;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "google.com";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5203a, false);
        AbstractC0184a.i0(parcel, 2, this.f5204b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
