package androidx.versionedparcelable;

import O.O;
import android.annotation.SuppressLint;
import android.os.Parcel;
import android.os.Parcelable;
import d0.C0323b;
import d0.InterfaceC0324c;

/* JADX INFO: loaded from: classes.dex */
@SuppressLint({"BanParcelableUsage"})
public class ParcelImpl implements Parcelable {
    public static final Parcelable.Creator<ParcelImpl> CREATOR = new O(21);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0324c f3197a;

    public ParcelImpl(Parcel parcel) {
        this.f3197a = new C0323b(parcel).g();
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        new C0323b(parcel).i(this.f3197a);
    }
}
